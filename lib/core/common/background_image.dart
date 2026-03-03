import 'package:flutter/material.dart';

/// Wraps the entire app with splash_bg.png - use in MaterialApp builder for full-app background
class GlobalAppBackground extends StatelessWidget {
  final Widget? child;
  final String imagePath;

  const GlobalAppBackground({
    super.key,
    this.child,
    this.imagePath = "assets/image/splash_bg.png",
  });

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(child: content),
      ],
    );
  }
}

class AuthBackgroundImage extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const AuthBackgroundImage({
    super.key,
    required this.child,
    this.imagePath = "assets/image/splash_bg.png",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class OnboardingBackgroundImage extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const OnboardingBackgroundImage({
    super.key,
    required this.child,
    this.imagePath = "assets/image/splash_bg.png",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class AppBackgroundImage extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const AppBackgroundImage({
    super.key,
    required this.child,
    this.imagePath = "assets/image/splash_bg.png",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        // Optional: Add dark overlay to make UI more readable
        // decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
        child: child,
      ),
    );
  }
}

class ProfileBackgroundImage extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const ProfileBackgroundImage({
    super.key,
    required this.child,
    this.imagePath = "assets/image/splash_bg.png",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        // Optional: Add dark overlay to make UI more readable
        // decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
        child: child,
      ),
    );
  }
}
