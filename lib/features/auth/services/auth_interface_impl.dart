import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/model/signin_model.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:flutter/material.dart';

final class AuthInterfaceImpl extends AuthInterface {
  final AuthorizedPigeon appPigeon;
  AuthInterfaceImpl(this.appPigeon);

  Stream<AuthStatus> authStream() {
    return appPigeon.authStream;
  }

  @override
  FutureRequest<Success> login(SigninModel params) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.login,
          data: params.toJson(),
        );

        debugPrint("login response: ${response.data}");

        final body = response.data;

        final loginResponse = SigninResponseModel.fromJson(body);

        if (loginResponse.success != true || loginResponse.data == null) {
          throw Exception("Login failed");
        }

        final loginData = loginResponse.data!;

        await appPigeon.saveNewAuth(
          saveAuthParams: SaveNewAuthParams(
            uid: loginData.user?.id,
            accessToken: loginData.accessToken,
            refreshToken: loginData.refreshToken,
            data: {
              "userId": loginData.user?.id,
              "name":
                  "${loginData.user?.firstName ?? ""} ${loginData.user?.lastName ?? ""}",
              "email": loginData.user?.email,
              "role": loginData.user?.role,
            },
          ),
        );

        return Success(message: loginResponse.message ?? "Login successful");
      },
    );
  }
}
