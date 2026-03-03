import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/features/welcome/welcome_screen.dart';

/// Single screen displaying all 3 onboarding slides in a swipeable PageView.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      imagePath: ImagePath.onboardingOne,
      title: 'Fitness For Every Ability',
      description:
          'AdaptFit is built for people with disabilities. Every workout is adapted to your specific needs.',
    ),
    _OnboardingPage(
      imagePath: ImagePath.onboardingTwo,
      title: 'Adaptive Workouts',
      description:
          'Seated exercises, upper body strength, flexibility and cardio all designed for your mobility level.',
    ),
    _OnboardingPage(
      imagePath: ImagePath.onboardingThree,
      title: 'Nutrition & Progress',
      description:
          'Personalized meal plans, calorie tracking, and progress charts to support your complete wellness journey.',
    ),
  ];

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAll(() => const WelcomeScreen());
    }
  }

  void _skip() => Get.offAll(() => const WelcomeScreen());

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _OnboardingSlide(page: _pages[index]),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: _BottomSection(
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                    title: _pages[_currentPage].title,
                    description: _pages[_currentPage].description,
                    onNext: _goToNext,
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  'Skip >>',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingSlide({required this.page});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        page.imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF19273C),
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported, size: 48, color: Colors.white54),
        ),
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final String title;
  final String description;
  final VoidCallback onNext;

  const _BottomSection({
    required this.currentPage,
    required this.totalPages,
    required this.title,
    required this.description,
    required this.onNext,
  });

  static const Color _darkNavy = Color(0xFF19273C);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 0),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: _darkNavy,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalPages,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 24,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index == currentPage
                        ? const Color(0xFF5A84AB)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: 120),
            CustomButton(
              text: 'Next',
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}


class _OnboardingPage {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}
