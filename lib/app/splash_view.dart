import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/app/guest_ground.dart';
import 'package:disabilitymne/core/auth/onboarding_state_holder.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/features/onboarding/onboarding_screen.dart';
import 'package:disabilitymne/features/welcome/welcome_screen.dart';
import 'package:disabilitymne/nabber_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Branded splash — logo + spinner, then routes by auth / guest / intro.
///
/// Fresh install: Onboarding → Welcome (login / guest)
/// Logged in: Home nav
/// Guest chosen: GuestGround
/// Logged out: Welcome (login / guest)
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  static const Color backgroundColor = Color(0xFF0D1B2A);
  static const Duration _minDisplay = Duration(milliseconds: 1800);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    final next = await _resolveNextScreen();

    final remaining = SplashView._minDisplay - DateTime.now().difference(started);
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    if (!mounted) return;

    Get.offAll(() => next);
  }

  Future<Widget> _resolveNextScreen() async {
    final auth = await Get.find<AuthorizedPigeon>().getCurrentAuthRecord();

    if (auth != null) {
      return AppGround();
    }

    final holder = Get.isRegistered<OnboardingStateHolder>()
        ? Get.find<OnboardingStateHolder>()
        : null;

    if (holder?.isGuestMode == true) {
      return const GuestGround();
    }

    if (holder?.hasSeenIntro == true) {
      return const WelcomeScreen();
    }

    return const OnboardingScreen();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = MediaQuery.sizeOf(context).width * 0.55;

    return Scaffold(
      backgroundColor: SplashView.backgroundColor,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Image.asset(
                ImagePath.splashBadge,
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: const CupertinoActivityIndicator(
                radius: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
