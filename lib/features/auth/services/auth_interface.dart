import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/model/forget_password_model.dart';
import 'package:disabilitymne/features/auth/model/reset_password_model.dart';
import 'package:disabilitymne/features/auth/model/signin_model.dart';
import 'package:disabilitymne/features/auth/model/signup_model.dart';
import 'package:disabilitymne/features/auth/model/verify_otp_model.dart';

abstract base class AuthInterface extends BaseRepository {
  FutureRequest<Success> login(SigninModel params);
  FutureRequest<Success> logout();
  FutureRequest<Success> signup(SignupModel params);
  FutureRequest<Success> forgetPassword(ForgetPasswordModel params);
  FutureRequest<Success> verifyOtp(VerifyOtpModel params);
  FutureRequest<Success> resetPassword(ResetPasswordModel params);
}
