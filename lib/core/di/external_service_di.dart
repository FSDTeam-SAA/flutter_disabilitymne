import 'package:app_pigeon/app_pigeon.dart';
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
