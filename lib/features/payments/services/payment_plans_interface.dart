import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/payments/model/checkout_response.dart';
import 'package:disabilitymne/features/payments/model/payment_plan.dart';

abstract base class PaymentPlansInterface extends BaseRepository {
  /// GET /payments/plans
  FutureRequest<List<PaymentPlan>> fetchPlans();

  /// POST /payments/checkout with body { "planKey": planKey }. Token applied by client.
  FutureRequest<CheckoutResponse> checkout(String planKey);

  /// POST or GET /payments/checkout/confirm with sessionId. Syncs Stripe session and returns payment/user.
  FutureRequest<CheckoutResponse> confirmCheckout(String sessionId);

  /// POST /payments/apple/verify — iOS App Store purchase verification.
  FutureRequest<CheckoutResponse> verifyApplePurchase({
    required String receiptData,
    required String planKey,
    String? productId,
    String? transactionId,
  });

  /// POST /payments/apple/restore — restore previous App Store subscriptions.
  FutureRequest<CheckoutResponse> restoreApplePurchase(String receiptData);
}

