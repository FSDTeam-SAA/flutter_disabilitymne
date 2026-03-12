import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/profile/model/change_password_model.dart';
import 'package:disabilitymne/features/profile/model/notification_model.dart';
import 'package:disabilitymne/features/profile/model/update_profile_model.dart';

abstract base class ProfileInterface extends BaseRepository {
  FutureRequest<Success<UserModel>> getProfile(UserModel params);
  FutureRequest<Success<UserProfileUpdateModel>> updateProfile(
    UserProfileUpdateModel params,
  );
  FutureRequest<Success<void>> changePassword(ChangePasswordModel params);

  FutureRequest<Success<List<NotificationModel>>> getNotifications(NotificationModel params);
}
