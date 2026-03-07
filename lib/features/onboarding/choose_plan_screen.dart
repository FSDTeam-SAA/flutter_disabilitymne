import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/features/onboarding/congratulations_screen.dart';
import 'package:disabilitymne/features/onboarding/select_payment_method_screen.dart';

/// Payment package selection: Free Trial, Monthly, Six Month, Premium.
/// Shown when user taps Continue on Fitness experience screen.
class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  int _selectedIndex = 0;

  static double _parseAmount(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static const Color _darkBlue = Color(0xFF1A2B3A);
  static const Color _green = Color(0xFF34C759);
  static const Color _greenFill = Color(0x3334C759); // 20% opacity
  /// Monthly plan: #0088FF
  static const Color _monthlyBlue = Color(0xFF0088FF);
  static const Color _monthlyBlueFill = Color(0x330088FF);
  /// Six month plan: #FFCC00
  static const Color _sixMonthYellow = Color(0xFFFFCC00);
  static const Color _sixMonthYellowFill = Color(0x33FFCC00);
  /// Premium: #FF8D28
  static const Color _premiumOrange = Color(0xFFFF8D28);
  static const Color _premiumOrangeFill = Color(0x33FF8D28);

  static const List<PlanItem> _plans = [
    PlanItem(
      id: 'free_trial',
      title: 'Free Trial',
      description: '7 days free',
      price: '00.00\$',
      accentColor: _green,
      accentFill: _greenFill,
      isPremium: false,
      features: [
        'Full Home Workout Program',
        'Recipes',
      ],
    ),
    PlanItem(
      id: 'monthly',
      title: 'Monthly Plan',
      description: 'Per month',
      price: '29.99\$',
      accentColor: _monthlyBlue,
      accentFill: _monthlyBlueFill,
      isPremium: false,
      features: [
        'Full Exercise Library Access',
        'Adaptive Training Plans',
        'Recipes',
        'Calorie Calculator',
      ],
    ),
    PlanItem(
      id: 'six_month',
      title: 'Six Month Plan',
      description: 'Per 6 month',
      price: '149.99\$',
      accentColor: _sixMonthYellow,
      accentFill: _sixMonthYellowFill,
      isPremium: false,
      features: [
        'Full Exercise Library Access',
        'Adaptive Training Plans',
        'Recipes',
        'Calorie Calculator',
      ],
    ),
    PlanItem(
      id: 'premium',
      title: 'Premium',
      description: 'Per month • save 38%',
      price: '150.00\$',
      accentColor: _premiumOrange,
      accentFill: _premiumOrangeFill,
      isPremium: true,
      mostPopular: true,
      features: [
        'Full Exercise Library Access',
        'Personalized Training Plan',
        'Recipes',
        'Calorie Calculator',
        'Weekly Check-In with the Coach',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, color: Color(0xFF4FC3F7), size: 28),
                    SizedBox(width: 4),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose your plan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Start your disability fitness journey',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...List.generate(_plans.length, (index) {
                    final plan = _plans[index];
                    final isSelected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(
                        plan: plan,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedIndex = index),
                      ),
                    );
                  }),
                ],
              ),
            ),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomButton(
                onPressed: () {
                  if (_selectedIndex == 0) {
                    Get.to(() => const CongratulationsScreen(planName: 'Free Trial'));
                  } else {
                    final plan = _plans[_selectedIndex];
                    final amount = _parseAmount(plan.price);
                    final planName = plan.title
                        .replaceFirst(' Plan', '')
                        .replaceFirst(' plan', '');
                    Get.to(() => SelectPaymentMethodScreen(
                      amount: amount,
                      planName: planName,
                    ));
                  }
                },
                text: _selectedIndex == 0
                    ? 'Continue 7 days free Trial'
                    : 'Continue to payment',
              ),
      )
        
       , SizedBox(height: 8.0),
        
          ],
        ),
      ),
    );
  }
}

class PlanItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final Color accentColor;
  final Color accentFill;
  final bool isPremium;
  final bool mostPopular;
  final List<String> features;

  const PlanItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.accentColor,
    required this.accentFill,
    this.isPremium = false,
    this.mostPopular = false,
    required this.features,
  });
}

class _PlanCard extends StatelessWidget {
  final PlanItem plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _cardBg = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final priceColor = isSelected && plan.mostPopular
        ? Colors.white
        : plan.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: isSelected ? plan.accentFill : _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? plan.accentColor : _cardBg.withValues(alpha: 0.6),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.15),
                  blurRadius: isSelected ? 8 : 4,
                  offset: Offset(0, isSelected ? 3 : 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      plan.price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: priceColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...plan.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/image/check_icon.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          if (plan.mostPopular)
            Positioned(
              top: -8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: plan.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Most popular',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
