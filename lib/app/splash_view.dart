import 'dart:async';
import 'package:app_pigeon/app_pigeon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/app/guest_ground.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/nabber_screen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final auth = await Get.find<AuthorizedPigeon>().getCurrentAuthRecord();
    if (!mounted) return;

    if (auth != null) {
      // Logged-in users go straight to the main app (no language/onboarding delay).
      Get.offAll(() => AppGround());
      return;
    }

    // Guests browse the app without signing in (Apple App Store requirement).
    Get.offAll(() => GuestGround());
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
