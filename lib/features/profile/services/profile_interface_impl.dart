import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/profile/model/update_profile_model.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:flutter/material.dart';

final class ProfileInterfaceImpl extends ProfileInterface {
  ProfileInterfaceImpl({required this.appPigeon});
  final AppPigeon appPigeon;

  @override
  FutureRequest<Success<UserModel>> getProfile(UserModel params) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          ApiEndpoints.getProfile,
          data: params.toJson(),
        );

        debugPrint("GET PROFILE RESPONSE => ${response.data}");
        final user = UserModel.fromJson(response.data['data']);
        return Success(data: user, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<UserProfileUpdateModel>> updateProfile(
    UserProfileUpdateModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.patch(
          ApiEndpoints.updateProfile,
          data: params.toJson(),
        );

        debugPrint("UPDATE PROFILE RESPONSE => ${response.data}");

        final user = UserProfileUpdateModel.fromJson(response.data['data']);

        return Success(data: user, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<dynamic>> changePassword() {
    // TODO: implement changePassword
    throw UnimplementedError();
  }
}
