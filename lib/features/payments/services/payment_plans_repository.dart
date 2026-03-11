import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
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
}

