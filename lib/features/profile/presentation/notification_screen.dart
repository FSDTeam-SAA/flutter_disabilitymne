import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/notification_controller.dart';
import '../model/notification_model.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.put(
    NotificationController(profileInterface: Get.find()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BackgroundImage(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (controller.notifications.isEmpty) {
            return const Center(
              child: Text(
                "No notifications found",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchNotifications,
            color: const Color(0xFF4B7FA8),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final item = controller.notifications[index];
                return _buildNotificationCard(item, index);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item, int index) {
    return GestureDetector(
      onTap: () => controller.markAsRead(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.read == true
              ? Colors.transparent
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF5B6475)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF152033),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4B7FA8)),
              ),
              child: Icon(Icons.notifications, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.timeAgo ?? "",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
