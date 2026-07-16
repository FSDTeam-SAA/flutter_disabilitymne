import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/core/constants/legal_urls.dart';
import 'package:disabilitymne/core/helpers/premium_access.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/payments/constants/iap_product_ids.dart';
import 'package:disabilitymne/features/payments/model/payment_plan.dart';
import 'package:disabilitymne/features/payments/model/premium_availability.dart';
import 'package:disabilitymne/features/payments/services/apple_iap_service.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_interface.dart';
import 'package:disabilitymne/features/profile/presentation/privacy_legal_screen.dart';
import 'package:disabilitymne/features/profile/presentation/terms_condition_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';
import 'package:disabilitymne/features/onboarding/congratulations_screen.dart';
import 'package:disabilitymne/features/onboarding/stripe_checkout_webview_screen.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

/// Payment package selection: Monthly, Quarterly, Annual, Premium.
/// Shown when user taps Continue on Fitness experience screen.
class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  int _selectedIndex = 0;
  late FutureRequest<List<PaymentPlan>> _plansFuture;
  bool _checkoutLoading = false;
  bool _restoreLoading = false;
  AppleIapService? _appleIapService;
  Map<String, ProductDetails> _storeProducts = {};
  PremiumAvailability? _premiumAvailability;
  bool _premiumAvailabilityLoading = true;

  static const Color _green = Color(0xFF34C759);
  static const Color _greenFill = Color(0xFF204A47); // 20% opacity
  /// Monthly plan: #0088FF
  static const Color _monthlyBlue = Color(0xFF0088FF);
  static const Color _monthlyBlueFill = Color(0xFF163D67);

  /// Quarterly plan: #FFCC00
  static const Color _quarterlyYellow = Color(0xFFFFCC00);
  static const Color _quarterlyYellowFill = Color(0xFF484731);

  /// Premium: #FF8D28
  static const Color _premiumOrange = Color(0xFFFF8D28);
  static const Color _premiumOrangeFill = Color(0xFF5B402F);

  @override
  void initState() {
    super.initState();
    _plansFuture = Get.find<PaymentPlansInterface>().fetchPlans();
    _loadPremiumAvailability();
    if (AppleIapService.isSupported) {
      _appleIapService = AppleIapService(Get.find<PaymentPlansInterface>());
      _initializeAppleIap();
    }
  }

  Future<void> _loadPremiumAvailability() async {
    setState(() => _premiumAvailabilityLoading = true);
    final result =
        await Get.find<PaymentPlansInterface>().fetchPremiumAvailability();
    if (!mounted) return;
    result.fold(
      (_) {
        setState(() {
          _premiumAvailability = null;
          _premiumAvailabilityLoading = false;
        });
      },
      (availability) {
        setState(() {
          _premiumAvailability = availability;
          _premiumAvailabilityLoading = false;
        });
      },
    );
  }

  bool get _isPremiumFull =>
      _premiumAvailability != null && !_premiumAvailability!.available;

  @override
  void dispose() {
    _appleIapService?.dispose();
    super.dispose();
  }

  Future<void> _initializeAppleIap() async {
    try {
      await _appleIapService?.initialize();
      final products = await _appleIapService?.loadProducts() ?? {};
      if (!mounted) return;
      setState(() {
        _storeProducts = {
          for (final product in products) product.id: product,
        };
      });
    } catch (error) {
      debugPrint('Apple IAP init failed: $error');
    }
  }

  void _retry() {
    setState(() {
      _plansFuture = Get.find<PaymentPlansInterface>().fetchPlans();
      _selectedIndex = 0;
    });
    _loadPremiumAvailability();
  }

  Future<void> _handleContinue(
    PaymentPlan selectedPlan,
    PlanItem selectedUiPlan,
  ) async {
    if (_checkoutLoading || _restoreLoading) return;
    if (selectedPlan.key == 'premium' && _isPremiumFull) {
      AppSnackbar.error(
        'Premium Unavailable',
        _premiumAvailability?.message ?? premiumMembershipFullMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedPlan.price <= 0) {
      Get.to(
        () => CongratulationsScreen(planName: selectedUiPlan.title),
      );
      return;
    }

    if (AppleIapService.isSupported) {
      await _handleIosPurchase(selectedPlan, selectedUiPlan);
      return;
    }

    await _handleStripeCheckout(selectedPlan, selectedUiPlan);
  }

  Future<void> _handleIosPurchase(
    PaymentPlan selectedPlan,
    PlanItem selectedUiPlan,
  ) async {
    final productId = IapProductIds.forPlanKey(selectedPlan.key);
    if (productId == null) {
      AppSnackbar.error('Error', 'Invalid subscription plan.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final product = _storeProducts[productId];
    if (product == null) {
      AppSnackbar.error(
        'Error',
        'This plan is not available in the App Store yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _checkoutLoading = true);
    try {
      await _appleIapService?.purchasePlan(
        planKey: selectedPlan.key,
        product: product,
      );
      if (!mounted) return;
      Get.offAll(() => CongratulationsScreen(planName: selectedUiPlan.title));
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        'Purchase failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _checkoutLoading = false);
    }
  }

  Future<void> _handleStripeCheckout(
    PaymentPlan selectedPlan,
    PlanItem selectedUiPlan,
  ) async {
    setState(() => _checkoutLoading = true);
    final paymentInterface = Get.find<PaymentPlansInterface>();
    final result = await paymentInterface.checkout(selectedPlan.key);
    if (!mounted) return;
    setState(() => _checkoutLoading = false);

    result.fold(
      (failure) {
        AppSnackbar.error(
          'Error',
          failure.uiMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (checkoutResponse) {
        if (checkoutResponse.isFreePlan) {
          Get.to(
            () => CongratulationsScreen(planName: selectedUiPlan.title),
          );
          return;
        }
        final url = checkoutResponse.checkoutUrl?.trim();
        if (url == null || url.isEmpty) {
          AppSnackbar.show(
            'Error',
            'No checkout URL received.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        Get.to(
          () => StripeCheckoutWebViewScreen(
            checkoutUrl: url,
            planName: selectedUiPlan.title,
            onSuccess: () {
              Get.offAll(
                () => CongratulationsScreen(
                  planName: selectedUiPlan.title,
                ),
              );
            },
            onCancel: () => Get.back(),
          ),
        );
      },
    );
  }

  Future<void> _handleRestorePurchases() async {
    if (_checkoutLoading || _restoreLoading) return;
    setState(() => _restoreLoading = true);
    try {
      await _appleIapService?.restorePurchases();
      if (!mounted) return;
      AppSnackbar.show(
        'Restored',
        'Your subscription was restored successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        'Restore failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _restoreLoading = false);
    }
  }

  /// Opens a legal document. Prefers a functional external link (required by
  /// App Review); falls back to the in-app screen if the URL is missing or
  /// cannot be opened.
  Future<void> _openLegalLink({
    required String url,
    required Widget fallbackScreen,
  }) async {
    final uri = url.trim().isEmpty ? null : Uri.tryParse(url.trim());
    if (uri != null) {
      try {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      } catch (_) {
        // Fall through to the in-app screen below.
      }
    }
    if (!mounted) return;
    Get.to(() => fallbackScreen);
  }

  static ({Color accent, Color fill}) _colorsForKey(String key) {
    switch (key) {
      case 'annual':
        return (accent: _green, fill: _greenFill);
      case 'monthly':
        return (accent: _monthlyBlue, fill: _monthlyBlueFill);
      case 'quarterly':
        return (accent: _quarterlyYellow, fill: _quarterlyYellowFill);
      case 'premium':
        return (accent: _premiumOrange, fill: _premiumOrangeFill);
      default:
        return (accent: Colors.white, fill: Colors.white);
    }
  }

  static String _formatPrice(PaymentPlan plan, Map<String, ProductDetails> storeProducts) {
    if (plan.price <= 0) return '00.00\$';
    final productId = IapProductIds.forPlanKey(plan.key);
    final storePrice = productId != null ? storeProducts[productId]?.price : null;
    if (storePrice != null && storePrice.isNotEmpty) return storePrice;
    return '${plan.price.toStringAsFixed(2)}\$';
  }

  /// Number of months for a plan, falling back to the plan key when the
  /// backend does not send a duration (keeps the subscription length visible,
  /// which App Review requires for auto-renewable subscriptions).
  static int _monthsForPlan(PaymentPlan plan) {
    if (plan.durationMonths > 0) return plan.durationMonths;
    switch (plan.key) {
      case 'monthly':
        return 1;
      case 'quarterly':
        return 3;
      case 'annual':
        return 12;
      default:
        return 0;
    }
  }

  /// Human-readable subscription length. Always non-empty so the paid plans
  /// clearly disclose their duration.
  static String _formatDescription(PaymentPlan plan) {
    if (plan.durationLabel.trim().isNotEmpty) return plan.durationLabel;
    final months = _monthsForPlan(plan);
    if (months == 1) return '1 month';
    if (months > 1) return '$months months';
    return 'Auto-renewing subscription';
  }

  /// Price per month for multi-month plans (e.g. "≈ 9.99$/month").
  /// Returned as null when a per-unit price is not meaningful.
  static String? _formatPerUnitPrice(PaymentPlan plan) {
    final months = _monthsForPlan(plan);
    if (plan.price <= 0 || months <= 1) return null;
    final perMonth = plan.price / months;
    return '≈ ${perMonth.toStringAsFixed(2)}\$/month';
  }

  PlanItem _toPlanItem(PaymentPlan p) {
    final colors = _colorsForKey(p.key);
    return PlanItem(
      id: p.key,
      title: p.name,
      description: _formatDescription(p),
      price: _formatPrice(p, _storeProducts),
      perUnitPrice: _formatPerUnitPrice(p),
      accentColor: colors.accent,
      accentFill: colors.fill,
      isPremium: p.key == 'premium',
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
                    final isFreePlan = selectedPlan.price <= 0;
                    final premiumBlocked =
                        selectedPlan.key == 'premium' && _isPremiumFull;
                    final buttonText = _checkoutLoading || _premiumAvailabilityLoading
                        ? 'Loading...'
                        : premiumBlocked
                            ? 'Premium Full'
                            : isFreePlan
                                ? 'Continue'
                                : AppleIapService.isSupported
                                    ? 'Subscribe'
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

                        if (_isPremiumFull)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                _premiumAvailability?.message ??
                                    premiumMembershipFullMessage,
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
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
                          child: Opacity(
                            opacity: premiumBlocked ? 0.5 : 1,
                            child: CustomButton(
                              onPressed: premiumBlocked ||
                                      _checkoutLoading ||
                                      _premiumAvailabilityLoading
                                  ? () {}
                                  : () => _handleContinue(
                                        selectedPlan,
                                        selectedUiPlan,
                                      ),
                              text: buttonText,
                            ),
                          ),
                        ),
                        if (AppleIapService.isSupported) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _restoreLoading ? null : _handleRestorePurchases,
                            child: Text(
                              _restoreLoading ? 'Restoring...' : 'Restore Purchases',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: Text(
                              'Payment will be charged to your Apple ID. Subscription renews automatically unless canceled at least 24 hours before the end of the current period.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => _openLegalLink(
                                url: LegalUrls.termsOfUseUrl,
                                fallbackScreen: const TermsConditionScreen(),
                              ),
                              child: const Text(
                                'Terms of Use (EULA)',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ),
                            Text(
                              '·',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            ),
                            TextButton(
                              onPressed: () => _openLegalLink(
                                url: LegalUrls.privacyPolicyUrl,
                                fallbackScreen: const PrivacyLegalScreen(),
                              ),
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ),
                          ],
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
  final String? perUnitPrice;
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
    this.perUnitPrice,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.price,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: priceColor,
                          ),
                        ),
                        if (plan.perUnitPrice != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            plan.perUnitPrice!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
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
