import 'package:disabilitymne/app/app_manager.dart';
import 'package:disabilitymne/core/di/external_service_di.dart';
import 'package:disabilitymne/core/di/internal_service_di.dart';
import 'package:disabilitymne/core/theme/app_theme.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_lifecycle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:disabilitymne/core/common/background_image.dart';
import 'package:disabilitymne/app/splash_view.dart';
/*
[12:16 pm, 03/03/2026] Younus Akon: aliulakon8@gmail.com
[12:16 pm, 03/03/2026] Younus Akon: bbbbbbbb
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  externalServiceDI();
  initServices();
  runApp(const MyApp());

  // new commite
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppManager appManager;
  late final ChatSocketLifecycleObserver _socketLifecycle;

  @override
  void initState() {
    super.initState();
    appManager = Get.find<AppManager>();
    _socketLifecycle = ChatSocketLifecycleObserver();
    WidgetsBinding.instance.addObserver(_socketLifecycle);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_socketLifecycle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Disability Fitness Center',
      theme: AppTheme.light,
      builder: (context, child) => GlobalAppBackground(child: child),
      home: const SplashView(),
    );
  }
}
