import 'package:get/get.dart';

class AppGroundController extends GetxController {
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
