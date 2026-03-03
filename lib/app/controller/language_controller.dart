import 'package:get/get.dart';

enum AppLanguage { english, serbian }

class LanguageController extends GetxController {
  final Rx<AppLanguage> selectedLanguage = AppLanguage.english.obs;

  void selectLanguage(AppLanguage lang) {
    selectedLanguage.value = lang;
  }

  bool isSelected(AppLanguage lang) => selectedLanguage.value == lang;
}
