import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/auth/services/auth_interface_impl.dart';
import 'package:disabilitymne/features/daily_tracker/repository/daily_tracker_repository.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_interface.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_repository.dart';
import 'package:disabilitymne/features/progress/repository/progress_repository.dart';
import 'package:get/get.dart';
import '../constants/api_endpoints.dart';

void externalServiceDI() {
  // Initialize other external services here
  final appPigeon = AuthorizedPigeon(
    BasicRefreshTokenManager(ApiEndpoints.refreshToken),
    baseUrl: ApiEndpoints.baseUrl,
  );
  Get.put<AuthorizedPigeon>(appPigeon);
  Get.put<AppPigeon>(appPigeon);

  // Auth Interface Implementation
  Get.lazyPut<AuthInterface>(() => AuthInterfaceImpl(Get.find()));

  // Daily Tracker Repository
  Get.lazyPut<DailyTrackerRepository>(
    () => DailyTrackerRepository(Get.find<AuthorizedPigeon>()),
  );

  // Progress Repository
  Get.lazyPut<ProgressRepository>(
    () => ProgressRepository(Get.find<AuthorizedPigeon>()),
  );

  // Payment Plans
  Get.lazyPut<PaymentPlansInterface>(
    () => PaymentPlansRepository(Get.find<AuthorizedPigeon>()),
  );
}

class MyRefreshTokenManager implements RefreshTokenManagerInterface {
  @override
  Future<RefreshTokenResponse> refreshToken({
    required String refreshToken,
    required Dio dio,
  }) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<bool> shouldRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // TODO: implement shouldRefresh
    throw UnimplementedError();
  }

  @override
  // TODO: implement url
  String get url => ApiEndpoints.refreshToken;
}
