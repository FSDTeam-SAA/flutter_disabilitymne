import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/auth_role.dart';
import 'package:disabilitymne/app/guest_ground.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:disabilitymne/nabber_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class AppManager extends GetxController {
  AuthStatus _authStatus = AuthLoading();
  AuthStatus get currentAuthStatus => _authStatus;
  Debouncer authDebouncer = Debouncer(delay: const Duration(milliseconds: 100));

  /// Initializes the stream to listen to auth status
  AppManager() {
    _init();
  }

  // listen to auth change
  void _init() async {
    debugPrint("AppManager initialized");

    // await Get.find<AuthorizedPigeon>().getCurrentAuthRecord().then((initialAuthStatus) {
    //   _decideRoute(initialAuthStatus);
    // });

    // Start listening to the auth status changes
    Get.find<AuthorizedPigeon>().authStream.listen((authStatus) {
      _decideRoute(authStatus);
    });
  }

  void _decideRoute(AuthStatus? authStatus) async {
    if (authStatus == null || authStatus is AuthLoading) return;

    if (authStatus is UnAuthenticated) {
      _authStatus = authStatus;
      _disconnectSockets();
      _clearProfileController();
      Get.offAll(() => GuestGround());
      update();
      return;
    }

    if (authStatus is Authenticated) {
      debugPrint(
        "currentAuthStatus: $_authStatus, beforeAuthStatus: $authStatus",
      );
      _authStatus = authStatus;
      await _initializeControllers();
      await _refreshProfileAfterLogin();

      // Logged-in users go to the main app. Pre-login language/onboarding
      // (Splash → Language → Onboarding → Welcome) is only for guests.
      Get.offAll(() => AppGround());
    }

    update();
  }

  /// Tear down sockets before re-init or logout.
  ///
  /// app_pigeon's [SocketService.listen] can crash with
  /// "Cannot add new events after calling close" when socketInit/dispose runs
  /// while connect/disconnect handlers are still attached — so we disconnect
  /// cleanly and never subscribe to those lifecycle events from AppManager.
  void _disconnectSockets() {
    try {
      Get.find<AuthorizedPigeon>().disconnectSocket();
    } catch (e, st) {
      debugPrint("AppManager: disconnectSocket error: $e");
      debugPrint("$st");
    }

    if (Get.isRegistered<ChatSocketService>()) {
      try {
        Get.find<ChatSocketService>().disconnect();
      } catch (e, st) {
        debugPrint("AppManager: ChatSocketService disconnect error: $e");
        debugPrint("$st");
      }
    }
  }

  void _clearProfileController() {
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }
  }

  Future<void> _refreshProfileAfterLogin() async {
    try {
      await Get.find<ProfileController>().getProfile();
    } catch (e, st) {
      debugPrint("AppManager: profile refresh error: $e");
      debugPrint("$st");
    }
  }

  // initiate controllers on auth change[Authenticated]
  Future<void> _initializeControllers() async {
    if ((currentAuthStatus as Authenticated).auth.userId.isEmpty) return;

    final userId = (currentAuthStatus as Authenticated).auth.userId;

    _disconnectSockets();

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await Get.find<AppPigeon>().socketInit(
        SocketConnetParamX(
          token: null,
          socketUrl: ApiEndpoints.socketUrl,
          joinId: userId,
        ),
      );
      Get.find<AppPigeon>().emit("joinChatRoom", userId);
    } catch (e, st) {
      debugPrint("AppManager: socketInit error (continuing): $e");
      debugPrint("$st");
    }
  }
}
// class AppManager extends GetxController {
//   AuthStatus _authStatus = AuthLoading();
//   AuthStatus get currentAuthStatus => _authStatus;

//   final Debouncer authDebouncer =
//       Debouncer(delay: const Duration(milliseconds: 100));

//   @override
//   void onInit() {
//     super.onInit();
//     _init();
//   }

//   Future<void> _init() async {
//     debugPrint("AppManager initialized");

//     final initialAuthStatus =
//         await Get.find<AppPigeon>().currentAuth();

//     // ✅ WAIT until UI is ready
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _decideRoute(initialAuthStatus);
//     });
//   }

//   Future<void> _decideRoute(AuthStatus? authStatus) async {
//     if (authStatus is UnAuthenticated) {
//       _authStatus = authStatus;

//       Get.offAll(() => SignupScreen());

//     } else if (authStatus is Authenticated) {
//       _authStatus = authStatus;

//       await _initializeControllers();

//       if (Get.isRegistered<ProfileController>()) {
//         Get.delete<ProfileController>();
//       }

//       Get.put(ProfileController());

//       Get.offAll(() => AppGround());
//     }

//     update();
//   }

//   Future<void> _initializeControllers() async {
//     if (_authStatus is! Authenticated) return;

//     final userId =
//         (_authStatus as Authenticated).auth.userId;

//     if (userId.isEmpty) return;

//     await Get.find<AppPigeon>().socketInit(
//       SocketConnetParamX(
//         token: null,
//         socketUrl: ApiEndpoints.socketUrl,
//         joinId: userId,
//       ),
//     );

//     Get.find<AppPigeon>().emit("join", userId);
//   }
// }
