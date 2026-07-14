import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/payments/model/checkout_response.dart';
import 'package:disabilitymne/features/payments/model/payment_plan.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_interface.dart';

base class PaymentPlansRepository extends PaymentPlansInterface {
  PaymentPlansRepository(this._pigeon);

  final AuthorizedPigeon _pigeon;

  @override
  FutureRequest<List<PaymentPlan>> fetchPlans() async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.get(ApiEndpoints.paymentPlans);
        final data = extractBodyData(response) as List<dynamic>?;
        if (data == null) {
          throw Exception('Invalid plans response');
        }
        return data
            .map((e) => PaymentPlan.fromJson(e as Map<String, dynamic>? ?? const {}))
            .toList();
      },
    );
  }

  @override
  FutureRequest<CheckoutResponse> checkout(String planKey) async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.post(
          ApiEndpoints.paymentCheckout,
          data: {'planKey': planKey},
        );
        final body = response.data as Map<String, dynamic>?;
        if (body == null) throw Exception('Invalid checkout response');
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return CheckoutResponse.fromJson(data);
      },
    );
  }

  @override
  FutureRequest<CheckoutResponse> confirmCheckout(String sessionId) async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.post(
          ApiEndpoints.paymentConfirmCheckout,
          data: {'sessionId': sessionId},
        );
        final body = response.data as Map<String, dynamic>?;
        if (body == null) throw Exception('Invalid confirm response');
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return CheckoutResponse.fromJson(data);
      },
    );
  }

  @override
  FutureRequest<CheckoutResponse> verifyApplePurchase({
    required String receiptData,
    required String planKey,
    String? productId,
    String? transactionId,
  }) async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.post(
          ApiEndpoints.paymentAppleVerify,
          data: {
            'receiptData': receiptData,
            'planKey': planKey,
            if (productId != null && productId.isNotEmpty) 'productId': productId,
            if (transactionId != null && transactionId.isNotEmpty)
              'transactionId': transactionId,
          },
        );
        final body = response.data as Map<String, dynamic>?;
        if (body == null) throw Exception('Invalid Apple verify response');
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return CheckoutResponse.fromJson(data);
      },
    );
  }

  @override
  FutureRequest<CheckoutResponse> restoreApplePurchase(String receiptData) async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.post(
          ApiEndpoints.paymentAppleRestore,
          data: {'receiptData': receiptData},
        );
        final body = response.data as Map<String, dynamic>?;
        if (body == null) throw Exception('Invalid Apple restore response');
        final data = body['data'] as Map<String, dynamic>? ?? body;
        return CheckoutResponse.fromJson(data);
      },
    );
  }
}

