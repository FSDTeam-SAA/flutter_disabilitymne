import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Listens to app lifecycle and disconnects socket on pause, reconnects on resume.
/// Add in your root State's initState and remove in dispose.
///
/// Example in MyApp State:
///   late final ChatSocketLifecycleObserver _socketLifecycle;
///   @override void initState() {
///     super.initState();
///     _socketLifecycle = ChatSocketLifecycleObserver();
///     WidgetsBinding.instance.addObserver(_socketLifecycle);
///   }
///   @override void dispose() {
///     WidgetsBinding.instance.removeObserver(_socketLifecycle);
///     super.dispose();
///   }
class ChatSocketLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Get.isRegistered<ChatSocketService>()) return;
    final service = Get.find<ChatSocketService>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        service.disconnectOnPause();
        break;
      case AppLifecycleState.resumed:
        service.reconnectOnResume();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
