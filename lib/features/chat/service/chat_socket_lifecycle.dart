import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Listens to app lifecycle and disconnects socket on pause, reconnects on resume.
///
/// Important: do NOT disconnect on [AppLifecycleState.inactive]. On iOS that
/// fires for keyboard, control center, and navigation transitions — disconnecting
/// there leaves chat stuck on "Connecting" / "Socket is not connected".
class ChatSocketLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Get.isRegistered<ChatSocketService>()) return;
    final service = Get.find<ChatSocketService>();
    switch (state) {
      case AppLifecycleState.paused:
        service.disconnectOnPause();
        break;
      case AppLifecycleState.resumed:
        service.reconnectOnResume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
