import 'package:disabilitymne/features/home/presentation/home_screen.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Congratulations screen after payment: shows plan name, trophy, features, and "Start Your Journey".
/// Monthly/Quarterly/Annual: one message. Premium: coach contact in 24h.
class CongratulationsScreen extends StatelessWidget {
  final String planName;

  const CongratulationsScreen({super.key, required this.planName});

  static const Color _bgDark = Color(0xFF0C1821);
  static const Color _golden = Color(0xFFFFD700);
  static const Color _cardBg = Color(0xFF1A2B43);

  static const List<String> _features = [
    'Full Workout Library Access',
    'Adaptive Training Plans',
    'Recipes',
    'Calorie Calculator',
  ];

  bool get _isPremium => planName.toLowerCase() == 'premium';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scaleW = (media.size.width / 375).clamp(0.8, 1.2);
    final scaleH = (media.size.height / 812).clamp(0.8, 1.2);

    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      child: Material(
        color: _bgDark,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: (20 * scaleW).clamp(16, 28),
                    top: (8 * scaleH).clamp(4, 12),
                    bottom: (4 * scaleH).clamp(0, 8),
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Get.back(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.back, color: Colors.white, size: 26),
                        SizedBox(width: 6),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: (17 * scaleW).clamp(16, 19),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: (12 * scaleH).clamp(8, 18)),
              Center(
                child: Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: (28 * scaleW).clamp(24, 32),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: (16 * scaleH).clamp(12, 20)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (24 * scaleW).clamp(20, 32)),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: (16 * scaleW).clamp(15, 18),
                        color: Colors.white,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Your '),
                        TextSpan(
                          text: planName,
                          style: TextStyle(
                            color: _golden,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' plan is now active.'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: (8 * scaleH).clamp(4, 12)),
              Center(
                child: Text(
                  "Let's build strength together.",
                  style: TextStyle(
                    fontSize: (16 * scaleW).clamp(15, 18),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: (16 * scaleH).clamp(12, 22)),
              Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    final side = (w < h ? w : h).clamp(220.0, 320.0);
                    return Image.asset(
                      'assets/image/congratulations_2.png',
                      width: side,
                      height: side,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.emoji_events,
                        size: side * 0.6,
                        color: _golden,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: (12 * scaleH).clamp(8, 18)),
              if (_isPremium) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (28 * scaleW).clamp(22, 36)),
                  child: Center(
                    child: Text(
                      'Thank you for joining disability app. Your coach will contact you within 24 hours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (14 * scaleW).clamp(13, 16),
                        color: Colors.white.withValues(alpha:0.9),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: (20 * scaleH).clamp(14, 26)),
              ],
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: (24 * scaleW).clamp(20, 32)),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.12),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _features
                          .map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/image/check_icon.png',
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      f,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  (20 * scaleW).clamp(16, 28),
                  16,
                  (20 * scaleW).clamp(16, 28),
                  media.padding.bottom + (24 * scaleH).clamp(16, 32),
                ),
                child: _StartJourneyButton(scale: scaleW),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartJourneyButton extends StatelessWidget {
  final double scale;

  const _StartJourneyButton({this.scale = 1.0});

  static const Color _green = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final height = (54 * scale).clamp(50.0, 58.0);
    final fontSize = (17 * scale).clamp(16.0, 18.0);
    return GestureDetector(
      onTap: () async {
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().getProfile();
        }
        Get.offAll(HomeScreen());
      },
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular((14 * scale).clamp(12, 16)),
        ),
        alignment: Alignment.center,
        child: Text(
          'Start Your Journey',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
