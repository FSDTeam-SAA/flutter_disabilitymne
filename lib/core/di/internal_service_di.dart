import 'package:disabilitymne/core/notifiers/snackbar_notifier.dart';
import 'package:disabilitymne/features/auth/controller/signin_controller.dart';
import 'package:disabilitymne/features/auth/controller/signup_controller.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/auth/services/auth_interface_impl.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import '../../app/app_manager.dart';

void initServices() {
  Get.put<AppManager>(AppManager(), permanent: true);

  Get.lazyPut<AuthInterface>(() => AuthInterfaceImpl(Get.find()));
  Get.lazyPut(() => SnackbarNotifier(context: Get.context!), fenix: true);
  Get.lazyPut(() => LoginController(Get.find()), fenix: true);
  Get.lazyPut(() => ProfileController(), fenix: true);
  Get.put(SignupController(Get.find<AuthInterface>()));
}
