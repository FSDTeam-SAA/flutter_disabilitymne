import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/background_image.dart';
import 'package:disabilitymne/app/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Disability Fitness Center',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      builder: (context, child) => GlobalAppBackground(child: child),
      home: const SplashView(),
    );
  }
}

