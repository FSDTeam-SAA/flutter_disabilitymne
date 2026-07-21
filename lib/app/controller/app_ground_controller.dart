import 'package:get/get.dart';

class AppGroundController extends GetxController {
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  /// Call after login / when opening AppGround so logout→login lands on Home.
  void resetToHome() {
    currentIndex.value = 0;
  }
}
