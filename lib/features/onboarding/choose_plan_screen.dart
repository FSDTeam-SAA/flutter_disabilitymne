import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/payments/model/payment_plan.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_interface.dart';
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
  late FutureRequest<List<PaymentPlan>> _plansFuture;

  static double _parseAmount(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static const Color _green = Color(0xFF34C759);
  static const Color _greenFill = Color(0xFF204A47); // 20% opacity
  /// Monthly plan: #0088FF
  static const Color _monthlyBlue = Color(0xFF0088FF);
  static const Color _monthlyBlueFill = Color(0xFF163D67);

  /// Six month plan: #FFCC00
  static const Color _sixMonthYellow = Color(0xFFFFCC00);
  static const Color _sixMonthYellowFill = Color(0xFF484731);

  /// Premium: #FF8D28
  static const Color _premiumOrange = Color(0xFFFF8D28);
  static const Color _premiumOrangeFill = Color(0xFF5B402F);

  @override
  void initState() {
    super.initState();
    _plansFuture = Get.find<PaymentPlansInterface>().fetchPlans();
  }

  void _retry() {
    setState(() {
      _plansFuture = Get.find<PaymentPlansInterface>().fetchPlans();
      _selectedIndex = 0;
    });
  }

  static ({Color accent, Color fill}) _colorsForKey(String key) {
    switch (key) {
      case 'free_trial':
        return (accent: _green, fill: _greenFill);
      case 'monthly_plan':
        return (accent: _monthlyBlue, fill: _monthlyBlueFill);
      case 'six_month_plan':
        return (accent: _sixMonthYellow, fill: _sixMonthYellowFill);
      case 'premium_plan':
        return (accent: _premiumOrange, fill: _premiumOrangeFill);
      default:
        return (accent: Colors.white, fill: Colors.white);
    }
  }

  static String _formatPrice(PaymentPlan plan) {
    if (plan.price <= 0) return '00.00\$';
    return '${plan.price.toStringAsFixed(2)}\$';
  }

  static String _formatDescription(PaymentPlan plan) {
    if (plan.trialDays > 0) return '${plan.trialDays} days free';
    if (plan.durationLabel.trim().isNotEmpty) return plan.durationLabel;
    if (plan.durationMonths > 0) return '${plan.durationMonths} month';
    return '';
  }

  static PlanItem _toPlanItem(PaymentPlan p) {
    final colors = _colorsForKey(p.key);
    return PlanItem(
      id: p.key,
      title: p.name,
      description: _formatDescription(p),
      price: _formatPrice(p),
      accentColor: colors.accent,
      accentFill: colors.fill,
      isPremium: p.key == 'premium_plan',
      mostPopular: p.isPopular,
      features: p.features,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: FutureBuilder<Request<List<PaymentPlan>>>(
            future: _plansFuture,
            builder: (context, snapshot) {
              final body = () {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final either = snapshot.data;
                if (either == null) {
                  return Center(
                    child: Text(
                      'Failed to load plans',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                return either.fold(
                  (failure) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            failure.uiMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 180,
                            child: CustomButton(
                              onPressed: _retry,
                              text: 'Retry',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  (plans) {
                    final uiPlans = plans.map(_toPlanItem).toList();
                    if (uiPlans.isEmpty) {
                      return Center(
                        child: Text(
                          'No plans found',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    final selected = _selectedIndex.clamp(0, uiPlans.length - 1);
                    final selectedPlan = plans[selected];
                    final selectedUiPlan = uiPlans[selected];
                    final isTrial = selectedPlan.trialDays > 0 || selectedPlan.price <= 0;
                    final buttonText = isTrial
                        ? (selectedPlan.trialDays > 0
                            ? 'Continue ${selectedPlan.trialDays} days free Trial'
                            : 'Continue free Trial')
                        : 'Continue to payment';

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// SCROLLABLE CONTENT
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                'Choose your plan',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start your disability fitness journey',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ...List.generate(uiPlans.length, (index) {
                                final plan = uiPlans[index];
                                final isSelected = selected == index;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _PlanCard(
                                    plan: plan,
                                    isSelected: isSelected,
                                    onTap: () =>
                                        setState(() => _selectedIndex = index),
                                  ),
                                );
                              }),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        /// BUTTON (FIXED BOTTOM)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CustomButton(
                            onPressed: () {
                              if (isTrial) {
                                Get.to(
                                  () => CongratulationsScreen(
                                    planName: selectedUiPlan.title,
                                  ),
                                );
                                return;
                              }

                              final amount = _parseAmount(selectedUiPlan.price);
                              Get.to(
                                () => SelectPaymentMethodScreen(
                                  amount: amount,
                                  planName: selectedUiPlan.title,
                                ),
                              );
                            },
                            text: buttonText,
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              }();

              return body;
            },
          ),
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

  @override
  Widget build(BuildContext context) {
    final priceColor = plan.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? plan.accentFill.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: plan.accentColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: plan.accentColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      plan.price,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: priceColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...plan.features.map(
                  (f) => Padding(
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
                  ),
                ),
              ],
            ),
          ),
          if (plan.mostPopular)
            Positioned(
              top: -8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8D28),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Most popular',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
