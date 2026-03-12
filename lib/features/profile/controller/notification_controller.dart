import 'package:disabilitymne/features/profile/model/notification_model.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  final ProfileInterface profileInterface;

  NotificationController({required this.profileInterface});

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    final result = await profileInterface.getNotifications(NotificationModel());
    result.fold(
      (failure) {
        isLoading.value = false;
        Get.snackbar("Error", failure.uiMessage);
      },
      (success) {
        notifications.value = success.data ?? [];
        isLoading.value = false;
      },
    );
  }

  void markAsRead(int index) {
    if (notifications[index].read == false) {
      notifications[index].read = true;
      notifications.refresh();
    }
  }
}