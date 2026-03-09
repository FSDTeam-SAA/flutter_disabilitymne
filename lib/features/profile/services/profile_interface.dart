import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/model/user_model.dart';

abstract base class ProfileInterface extends BaseRepository {
  FutureRequest<Success<UserModel>> getProfile(UserModel params);
  FutureRequest<Success> updateProfile();
  FutureRequest<Success> changePassword();
}
