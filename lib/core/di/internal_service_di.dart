import 'package:disabilitymne/core/notifiers/snackbar_notifier.dart';
import 'package:disabilitymne/features/auth/controller/signin_controller.dart';
import 'package:get/get.dart';
import '../../app/app_manager.dart';

void initServices() {
  Get.put<AppManager>(AppManager(), permanent: true);

  Get.lazyPut(() => SnackbarNotifier(context: Get.context!));
  Get.lazyPut(() => LoginController(Get.find()));
}
