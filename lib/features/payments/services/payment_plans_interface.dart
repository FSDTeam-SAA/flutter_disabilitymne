import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/payments/model/payment_plan.dart';

abstract base class PaymentPlansInterface extends BaseRepository {
  /// GET /payments/plans
  FutureRequest<List<PaymentPlan>> fetchPlans();
}

