import 'dart:async';
import 'package:app_pigeon/app_pigeon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/features/language/language_screen.dart';
import 'package:disabilitymne/nabber_screen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _navigateNext);
  }

  void _navigateNext() async {
    if (!mounted) return;

    final auth = await Get.find<AuthorizedPigeon>().getCurrentAuthRecord();
    if (!mounted) return;

    if (auth != null) {
      Get.offAll(() => AppGround());
      return;
    }

    Get.offAll(() => const LanguageScreen());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.width * 0.52;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset(
                ImagePath.appLogo,
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 2),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 48),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
