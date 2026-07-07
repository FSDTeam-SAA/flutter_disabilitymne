import 'package:disabilitymne/features/profile/model/notification_model.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';

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
        AppSnackbar.show("Error", failure.uiMessage);
      },
      (success) {
        notifications.value = success.data ?? [];
        isLoading.value = false;
      },
    );
  }

  Future<void> markAsRead(int index) async {
    if (notifications[index].read == false) {
      final item = notifications[index];
      final result = await profileInterface.markNotificationAsRead(item);
      result.fold(
        (failure) => AppSnackbar.show("Error", failure.uiMessage),
        (success) {
          notifications[index].read = true;
          notifications.refresh();
        },
      );
    }
  }

  Future<void> markAllAsRead() async {
    final result =
        await profileInterface.markAllNotificationsAsRead(NotificationModel());
    result.fold(
      (failure) => AppSnackbar.show("Error", failure.uiMessage),
      (success) {
        for (var notification in notifications) {
          notification.read = true;
        }
        notifications.refresh();
      },
    );
  }

  void toggleExpansion(int index) {
    notifications[index].isExpanded = !notifications[index].isExpanded;
    notifications.refresh();
  }
}