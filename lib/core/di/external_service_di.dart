import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/auth/access_token_holder.dart';
import 'package:disabilitymne/core/auth/onboarding_state_holder.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/auth/services/auth_interface_impl.dart';
import 'package:disabilitymne/features/chat/repository/chat_repository.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:disabilitymne/features/daily_tracker/repository/daily_tracker_repository.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_interface.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_repository.dart';
import 'package:disabilitymne/features/progress/repository/progress_repository.dart';
import 'package:disabilitymne/features/calculator/services/calculator_interface.dart';
import 'package:disabilitymne/features/calculator/services/calculator_interface_impl.dart';
import 'package:get/get.dart';
import '../constants/api_endpoints.dart';

void externalServiceDI() {
  Get.put<AccessTokenHolder>(AccessTokenHolder(), permanent: true);
  Get.put<OnboardingStateHolder>(OnboardingStateHolder(), permanent: true);

  // Initialize other external services here
  final appPigeon = AuthorizedPigeon(
    BasicRefreshTokenManager(ApiEndpoints.refreshToken),
    baseUrl: ApiEndpoints.baseUrl,
  );
  Get.put<AuthorizedPigeon>(appPigeon);
  Get.put<AppPigeon>(appPigeon);

  // Auth Interface Implementation
  Get.lazyPut<AuthInterface>(
    () => AuthInterfaceImpl(Get.find()),
    fenix: true,
  );

  // Daily Tracker Repository (put so it's available before first use)
  Get.put<DailyTrackerRepository>(
    DailyTrackerRepository(Get.find<AuthorizedPigeon>()),
    permanent: true,
  );

  // Progress Repository
  Get.lazyPut<ProgressRepository>(
    () => ProgressRepository(Get.find<AuthorizedPigeon>()),
    fenix: true,
  );

  // Payment Plans
  Get.lazyPut<PaymentPlansInterface>(
    () => PaymentPlansRepository(Get.find<AuthorizedPigeon>()),
    fenix: true,
  );

  // Chat
  Get.lazyPut<ChatRepository>(
    () => ChatRepository(Get.find<AuthorizedPigeon>()),
    fenix: true,
  );
  Get.lazyPut<ChatSocketService>(
    () => ChatSocketService(socketUrl: ApiEndpoints.socketUrl),
    fenix: true,
  );

  // Calculator
  Get.lazyPut<CalculatorInterface>(
    () => CalculatorInterfaceImpl(appPigeon: Get.find<AuthorizedPigeon>()),
    fenix: true,
  );
}

class MyRefreshTokenManager implements RefreshTokenManagerInterface {
  @override
  Future<RefreshTokenResponse> refreshToken({
    required String refreshToken,
    required Dio dio,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> shouldRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    throw UnimplementedError();
  }

  @override
  String get url => ApiEndpoints.refreshToken;
}
