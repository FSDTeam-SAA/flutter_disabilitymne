import 'dart:async';
import 'dart:io';

import 'package:disabilitymne/features/payments/constants/iap_product_ids.dart';
import 'package:disabilitymne/features/payments/model/checkout_response.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class AppleIapService {
  AppleIapService(this._paymentPlans);

  final PaymentPlansInterface _paymentPlans;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  Completer<CheckoutResponse>? _pendingPurchase;
  String? _pendingPlanKey;
  DateTime? _pendingStartedAt;

  static bool get isSupported => !kIsWeb && Platform.isIOS;

  Future<void> initialize() async {
    if (!isSupported) return;

    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('App Store purchases are not available on this device.');
    }

    // Clear any stuck in-memory purchase lock from a previous failed attempt.
    _clearPending();

    await _purchaseSub?.cancel();
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) {
        _pendingPurchase?.completeError(error);
        _clearPending();
      },
    );
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
    _clearPending();
  }

  Future<Set<ProductDetails>> loadProducts() async {
    if (!isSupported) return {};

    final response = await _iap.queryProductDetails(IapProductIds.all);
    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP products not found: ${response.notFoundIDs}');
    }

    return response.productDetails.toSet();
  }

  Future<CheckoutResponse> purchasePlan({
    required String planKey,
    required ProductDetails product,
  }) async {
    if (!isSupported) {
      throw Exception('Apple In-App Purchase is only available on iOS.');
    }

    // If a previous attempt got stuck without finishing, allow a new purchase.
    if (_pendingPurchase != null) {
      final startedAt = _pendingStartedAt;
      final isStale =
          startedAt == null || DateTime.now().difference(startedAt) > const Duration(seconds: 90);
      if (isStale) {
        debugPrint('Clearing stale Apple IAP purchase lock.');
        _clearPending();
      } else {
        throw Exception('Another purchase is already in progress. Please wait a moment and try again.');
      }
    }

    _pendingPlanKey = planKey;
    _pendingStartedAt = DateTime.now();
    _pendingPurchase = Completer<CheckoutResponse>();

    final param = PurchaseParam(productDetails: product);
    final started = await _iap.buyNonConsumable(purchaseParam: param);
    if (!started) {
      _clearPending();
      throw Exception('Unable to start App Store purchase.');
    }

    return _pendingPurchase!.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        _clearPending();
        throw Exception('Purchase timed out. Please try again.');
      },
    );
  }

  Future<CheckoutResponse> restorePurchases() async {
    if (!isSupported) {
      throw Exception('Restore purchases is only available on iOS.');
    }

    await _iap.restorePurchases();
    final receiptData = await _fetchReceiptData();
    if (receiptData == null || receiptData.isEmpty) {
      throw Exception('No App Store receipt found to restore.');
    }

    final result = await _paymentPlans.restoreApplePurchase(receiptData);
    return result.fold(
      (failure) => throw Exception(failure.uiMessage),
      (response) => response,
    );
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      try {
        if (purchase.status == PurchaseStatus.pending) {
          continue;
        }

        if (purchase.status == PurchaseStatus.error) {
          final message = purchase.error?.message ?? 'Purchase failed.';
          _pendingPurchase?.completeError(Exception(message));
          _clearPending();
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          continue;
        }

        if (purchase.status == PurchaseStatus.canceled) {
          _pendingPurchase?.completeError(Exception('Purchase was canceled.'));
          _clearPending();
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          continue;
        }

        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          final receiptData = await _resolveReceiptData(purchase);
          final planKey = _pendingPlanKey ?? _planKeyFromProduct(purchase.productID);

          if (planKey == null || receiptData == null || receiptData.isEmpty) {
            throw Exception('Unable to verify App Store purchase.');
          }

          final result = await _paymentPlans.verifyApplePurchase(
            receiptData: receiptData,
            planKey: planKey,
            productId: purchase.productID,
            transactionId: purchase.purchaseID,
          );

          final response = result.fold(
            (failure) => throw Exception(failure.uiMessage),
            (value) => value,
          );

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

          if (_pendingPurchase != null && !_pendingPurchase!.isCompleted) {
            _pendingPurchase!.complete(response);
            _clearPending();
          }
        }
      } catch (error) {
        if (_pendingPurchase != null && !_pendingPurchase!.isCompleted) {
          _pendingPurchase!.completeError(error);
        }
        _clearPending();
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<String?> _resolveReceiptData(PurchaseDetails purchase) async {
    final serverData = purchase.verificationData.serverVerificationData.trim();
    if (serverData.isNotEmpty) {
      return serverData;
    }

    return _fetchReceiptData();
  }

  Future<String?> _fetchReceiptData() async {
    final addition = _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    final verification = await addition.refreshPurchaseVerificationData();
    return verification?.serverVerificationData;
  }

  String? _planKeyFromProduct(String productId) {
    switch (productId) {
      case IapProductIds.monthly:
        return 'monthly';
      case IapProductIds.quarterly:
        return 'quarterly';
      case IapProductIds.annual:
        return 'annual';
      case IapProductIds.premium:
        return 'premium';
      default:
        return null;
    }
  }

  void _clearPending() {
    _pendingPurchase = null;
    _pendingPlanKey = null;
    _pendingStartedAt = null;
  }
}
