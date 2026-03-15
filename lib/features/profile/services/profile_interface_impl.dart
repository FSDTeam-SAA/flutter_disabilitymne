import 'dart:io';

import 'package:app_pigeon/app_pigeon.dart';
import 'package:dio/dio.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/profile/model/change_password_model.dart';
import 'package:disabilitymne/features/profile/model/help_and_support_model.dart';
import 'package:disabilitymne/features/profile/model/notification_model.dart';
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
  FutureRequest<Success<UserModel>> updateMyProfileImage(File imageFile) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final fileName = imageFile.path.split(RegExp(r'[/\\]')).last;
        final formData = FormData.fromMap({
          'profileImage': await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName.isEmpty ? 'image.jpg' : fileName,
          ),
        });

        final response = await appPigeon.patch(
          ApiEndpoints.updateProfileImage,
          data: formData,
        );

        debugPrint("UPDATE PROFILE IMAGE RESPONSE => ${response.data}");

        final user = UserModel.fromJson(response.data['data']);
        return Success(data: user, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<void>> changePassword(
    ChangePasswordModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.changePassword,
          data: params.toJson(),
        );

        debugPrint("CHANGE PASSWORD RESPONSE => ${response.data}");

        return Success(data: null, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<List<NotificationModel>>> getNotifications(
    NotificationModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          ApiEndpoints.getAllNotifications,
          data: params.toJson(),
        );

        debugPrint("GET NOTIFICATIONS RESPONSE => ${response.data}");

        final List<dynamic> list = response.data['data'] ?? [];
        final notifications = list
            .map((e) => NotificationModel.fromJson(e))
            .toList();

        return Success(
          data: notifications,
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<void>> markAllNotificationsAsRead(
    NotificationModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.patch(
          ApiEndpoints.markAllAsRead,
          data: params.toJson(),
        );

        debugPrint(
          "MARK ALL NOTIFICATIONS AS READ RESPONSE => ${response.data}",
        );

        return Success(data: null, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<void>> markNotificationAsRead(
    NotificationModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.patch(
          ApiEndpoints.markNotificationAsRead(notificationId: params.id ?? ''),
          data: params.toJson(),
        );

        debugPrint("MARK NOTIFICATION AS READ RESPONSE => ${response.data}");

        return Success(data: null, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<void>> submitHelpSupport(HelpAndSupportModel params) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.helpAndSupport,
          data: params.toJson(),
        );

        debugPrint("SUBMIT HELP SUPPORT RESPONSE => ${response.data}");
        return Success(data: null, message: extractSuccessMessage(response));
      },
    );
  }
}
