import 'package:disabilitymne/core/notifiers/snackbar_notifier.dart';
import 'package:disabilitymne/features/auth/controller/signin_controller.dart';
import 'package:disabilitymne/features/auth/controller/signup_controller.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:disabilitymne/features/profile/services/profile_interface_impl.dart';
import 'package:disabilitymne/features/onboarding/controller/onboarding_controller.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:disabilitymne/features/programs/services/program_interface_impl.dart';
import 'package:disabilitymne/features/calculator/controller/calculator_controller.dart';
import 'package:disabilitymne/features/home/controller/home_banner_controller.dart';
import 'package:disabilitymne/features/home/services/home_banner_repository.dart';
import 'package:disabilitymne/features/recipies/controller/recipe_conreoller.dart';
import 'package:get/get.dart';
import '../../app/app_manager.dart';

void initServices() {
  Get.put<AppManager>(AppManager(), permanent: true);
  Get.lazyPut(() => SnackbarNotifier(context: Get.context!), fenix: true);
  Get.lazyPut(() => LoginController(Get.find()), fenix: true);
  Get.lazyPut<ProfileInterface>(
    () => ProfileInterfaceImpl(appPigeon: Get.find()),
    fenix: true,
  );
  Get.lazyPut(
    () => ProfileController(profileInterface: Get.find<ProfileInterface>()),
    fenix: true,
  );
  Get.lazyPut<OnboardingController>(
    () => OnboardingController(profileInterface: Get.find<ProfileInterface>()),
    fenix: true,
  );
  Get.put(SignupController(Get.find<AuthInterface>()));
  Get.lazyPut<ProgramInterface>(
    () => ProgramInterfaceImpl(appPigeon: Get.find()),
    fenix: true,
  );
  Get.lazyPut(
    () => CalculatorController(calculatorInterface: Get.find()),
    fenix: true,
  );
  Get.lazyPut(
    () => RecipeController(),
    fenix: true,
  );
  Get.lazyPut(
    () => HomeBannerController(
      repository: Get.find<HomeBannerRepository>(),
    ),
    fenix: true,
  );
}
