import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/model/signin_model.dart';

abstract base class AuthInterface extends BaseRepository {
  FutureRequest<Success> login(SigninModel params);
}