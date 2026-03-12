import 'dart:async';
import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/auth_role.dart';
import 'package:disabilitymne/features/auth/presentation/screens/sign_in_screen.dart';

import 'package:disabilitymne/nabber_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class AppManager extends GetxController {
  AuthStatus _authStatus = AuthLoading();
  AuthStatus get currentAuthStatus => _authStatus;
  Debouncer authDebouncer = Debouncer(delay: const Duration(milliseconds: 100));

  /// Socket connection status
  final RxBool socketConnected = false.obs;

  StreamSubscription<dynamic>? _socketConnectSub;
  StreamSubscription<dynamic>? _socketDisconnectSub;
  StreamSubscription<dynamic>? _socketErrorSub;

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
    if (authStatus is UnAuthenticated) {
      _authStatus = authStatus;
      Get.offAll(() => SignInScreen());
      // navigatorKey.currentState?.pushNamedAndRemoveUntil(
      //   RouteNames.login,
      //   (route) => false,
      // );
    } else if (authStatus is Authenticated) {
      debugPrint(
        "currentAuthStatus: $_authStatus, beforeAuthStatus: $authStatus",
      );
      debugPrint(
        "New auth:: ${!(currentAuthStatus is Authenticated && (authStatus).auth.userId != (currentAuthStatus as Authenticated).auth.userId)}",
      );
      _authStatus = authStatus;
      await _initializeControllers();

      // Get.offAll(() => GenderSelectionScreen());//home screen  AppGround
      Get.offAll(() => AppGround());
      // Get.offAll(ChoosePlanScreen());
      // Get.offAll(HomeScreen(isPremiumUser: true,));



// Get.offAll(PremiumHomeScreen());
    }
    update();
    // if (authStatus != null && authStatus != _authStatus) {
    //   debugPrint("(In Appmanager)Auth status: $authStatus");

    // }
  }

  // initiate controllers on auth change[Authenticated]
  Future<void> _initializeControllers() async {
    if ((currentAuthStatus as Authenticated).auth.userId.isNotEmpty) {
      await Get.find<AppPigeon>()
          .socketInit(
            SocketConnetParamX(
              token: null,
              socketUrl: ApiEndpoints.socketUrl,
              joinId: (currentAuthStatus as Authenticated).auth.userId,
            ),
          )
          .then((_) async {
            Get.find<AppPigeon>().emit(
              "joinChatRoom",
              ((currentAuthStatus as Authenticated).auth.userId),
            );
            _bindSocketStatus();
            // if (Get.isRegistered<AppGlobalControllers>()) {
            //   await Get.delete<AppGlobalControllers>();
            // }

            // Get.put<AppGlobalControllers>(
            //   AppGlobalControllers(),
            // );
          });
    }
  }

  void _bindSocketStatus() {
    _socketConnectSub?.cancel();
    _socketDisconnectSub?.cancel();
    _socketErrorSub?.cancel();

    final appPigeon = Get.find<AppPigeon>();
    _socketConnectSub = appPigeon.listen("connect").listen((_) {
      socketConnected.value = true;
    });
    _socketDisconnectSub = appPigeon.listen("disconnect").listen((_) {
      socketConnected.value = false;
    });
    _socketErrorSub = appPigeon.listen("connect_error").listen((_) {
      socketConnected.value = false;
    });
  }

  @override
  void onClose() {
    _socketConnectSub?.cancel();
    _socketDisconnectSub?.cancel();
    _socketErrorSub?.cancel();
    super.onClose();
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
