import 'dart:async';

import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/auth/access_token_holder.dart';
import 'package:disabilitymne/core/auth/onboarding_state_holder.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/auth_role.dart';
import 'package:disabilitymne/app/controller/app_ground_controller.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:disabilitymne/app/guest_ground.dart';
import 'package:disabilitymne/features/welcome/welcome_screen.dart';
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
      // Only navigate on real logout. Cold-start guests are routed by SplashView
      // (first install: splash → onboarding; returning: Welcome).
      final wasAuthenticated = _authStatus is Authenticated;
      _authStatus = authStatus;
      _disconnectSockets();
      _clearProfileController();

      // Logout → guest shell if they browsed as guest before; else Welcome
      if (wasAuthenticated) {
        final holder = Get.isRegistered<OnboardingStateHolder>()
            ? Get.find<OnboardingStateHolder>()
            : null;
        holder?.setIntroSeen();
        if (holder?.isGuestMode == true) {
          Get.offAll(() => const GuestGround());
        } else {
          Get.offAll(() => const WelcomeScreen());
        }
      }
      update();
      return;
    }

    if (authStatus is Authenticated) {
      debugPrint(
        "currentAuthStatus: $_authStatus, beforeAuthStatus: $authStatus",
      );
      final userId = authStatus.auth.userId.trim();
      // Guard: never open nav without a real logged-in session.
      if (userId.isEmpty) {
        _authStatus = UnAuthenticated();
        update();
        return;
      }

      // Keep guest flag so logout can return to GuestGround.
      _authStatus = authStatus;
      await _initializeControllers();
      await _refreshProfileAfterLogin();

      if (Get.isRegistered<AppGroundController>()) {
        Get.find<AppGroundController>().resetToHome();
      }
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
    await _syncChatAccessToken();

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

  /// Populate [AccessTokenHolder] (used by the live-chat Socket.IO client) with
  /// the current access token. `AccessTokenHolder.setToken` is otherwise only
  /// called from the fresh-login flow, so on app restart with an already
  /// persisted session the chat socket never had a token and stayed stuck on
  /// "Connecting" forever. This runs on every Authenticated event, covering
  /// both fresh logins and restored sessions.
  Future<void> _syncChatAccessToken() async {
    if (!Get.isRegistered<AccessTokenHolder>()) return;
    try {
      final auth = await Get.find<AuthorizedPigeon>().getCurrentAuthRecord();
      final token = auth?.toJson()['access_token'] as String?;
      final trimmed = token?.trim();
      Get.find<AccessTokenHolder>().setToken(trimmed);

      if (trimmed != null &&
          trimmed.isNotEmpty &&
          Get.isRegistered<ChatSocketService>()) {
        unawaited(Get.find<ChatSocketService>().ensureConnected(trimmed));
      }
    } catch (e, st) {
      debugPrint("AppManager: _syncChatAccessToken error: $e");
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
