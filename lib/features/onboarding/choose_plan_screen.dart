import 'package:disabilitymne/core/auth/onboarding_state_holder.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/core/constants/legal_urls.dart';
import 'package:disabilitymne/core/helpers/premium_access.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/payments/constants/iap_product_ids.dart';
import 'package:disabilitymne/features/payments/model/payment_plan.dart';
import 'package:disabilitymne/features/payments/model/premium_availability.dart';
import 'package:disabilitymne/features/payments/services/apple_iap_service.dart';
import 'package:disabilitymne/features/payments/services/payment_plans_interface.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
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
/// When [isPaywall] is true, unpaid users cannot leave until they subscribe.
class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key, this.isPaywall = false});

  final bool isPaywall;

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
  bool _iapProductsLoading = false;
  String? _iapProductsError;

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
    final result = await Get.find<PaymentPlansInterface>()
        .fetchPremiumAvailability();
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
    if (!AppleIapService.isSupported) return;

    setState(() {
      _iapProductsLoading = true;
      _iapProductsError = null;
    });

    try {
      await _appleIapService?.initialize();
      final products = await _appleIapService?.loadProducts() ?? {};
      if (!mounted) return;
      setState(() {
        _storeProducts = {for (final product in products) product.id: product};
        _iapProductsLoading = false;
        _iapProductsError = products.isEmpty
            ? 'Subscription products could not be loaded from the App Store. Please try again.'
            : null;
      });
    } catch (error) {
      debugPrint('Apple IAP init failed: $error');
      if (!mounted) return;
      setState(() {
        _iapProductsLoading = false;
        _iapProductsError = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  bool _isStoreProductReady(String planKey) {
    if (!AppleIapService.isSupported) return true;
    final productId = IapProductIds.forPlanKey(planKey);
    if (productId == null) return false;
    return _storeProducts.containsKey(productId);
  }

  void _retry() {
    setState(() {
      _plansFuture = Get.find<PaymentPlansInterface>().fetchPlans();
      _selectedIndex = 0;
    });
    _loadPremiumAvailability();
    if (AppleIapService.isSupported) {
      _initializeAppleIap();
    }
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
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (selectedPlan.price <= 0) {
      if (widget.isPaywall) {
        AppSnackbar.error(
          'Subscription required',
          'Please choose a paid plan to continue.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      Get.to(() => CongratulationsScreen(planName: selectedUiPlan.title));
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
      AppSnackbar.error(
        'Error',
        'Invalid subscription plan.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_iapProductsLoading) {
      AppSnackbar.show(
        'Please wait',
        'Loading App Store subscription products…',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final product = _storeProducts[productId];
    if (product == null) {
      AppSnackbar.error(
        'Error',
        _iapProductsError ??
            'This subscription is temporarily unavailable. Tap Retry and try again.',
        snackPosition: SnackPosition.TOP,
      );
      await _initializeAppleIap();
      return;
    }

    setState(() => _checkoutLoading = true);
    try {
      final checkout = await _appleIapService?.purchasePlan(
        planKey: selectedPlan.key,
        product: product,
      );
      if (!mounted) return;
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().applyUserJson(checkout?.user);
      }
      await _enterAppAfterPayment(selectedUiPlan.title);
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        'Purchase failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
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
          snackPosition: SnackPosition.TOP,
        );
      },
      (checkoutResponse) {
        if (checkoutResponse.isFreePlan) {
          if (widget.isPaywall) {
            AppSnackbar.error(
              'Subscription required',
              'Please choose a paid plan to continue.',
              snackPosition: SnackPosition.TOP,
            );
            return;
          }
          Get.to(() => CongratulationsScreen(planName: selectedUiPlan.title));
          return;
        }
        final url = checkoutResponse.checkoutUrl?.trim();
        if (url == null || url.isEmpty) {
          AppSnackbar.show(
            'Error',
            'No checkout URL received.',
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
        Get.to(
          () => StripeCheckoutWebViewScreen(
            checkoutUrl: url,
            planName: selectedUiPlan.title,
            onSuccess: () {
              _enterAppAfterPayment(selectedUiPlan.title);
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
      final checkout = await _appleIapService?.restorePurchases();
      if (!mounted) return;
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().applyUserJson(checkout?.user);
        await Get.find<ProfileController>().getProfile();
      }
      if (!mounted) return;
      final user = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>().user.value
          : null;
      if (isPaidSubscriber(user)) {
        await _enterAppAfterPayment('your');
        return;
      }
      AppSnackbar.show(
        'Restored',
        'Your subscription was restored successfully.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        'Restore failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) setState(() => _restoreLoading = false);
    }
  }

  Future<void> _enterAppAfterPayment(String planName) async {
    if (Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().getProfile();
    }
    if (!mounted) return;

    final user = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().user.value
        : null;

    // Only leave the paywall when backend confirms an active membership.
    if (!isPaidSubscriber(user)) {
      AppSnackbar.error(
        'Subscription pending',
        'Purchase completed, but membership is not active yet. Tap Restore Purchases or try again.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Get.offAll(() => CongratulationsScreen(planName: planName));
  }

  Future<void> _signOutFromPaywall() async {
    if (Get.isRegistered<OnboardingStateHolder>()) {
      Get.find<OnboardingStateHolder>().routeToLoginOnLogout = false;
      Get.find<OnboardingStateHolder>().suppressAuthNavigation = false;
    }
    if (Get.isRegistered<AuthInterface>()) {
      await Get.find<AuthInterface>().logout();
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
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
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

  /// Always display catalog prices in USD ($) — never localize to EUR/other.
  static String _formatUsd(double amount) {
    if (amount <= 0) return '00.00\$';
    final fixed = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '$fixed\$';
  }

  static String _formatPrice(PaymentPlan plan) {
    // Global app: show backend/catalog USD amounts on Choose Your Plan.
    // (StoreKit may still charge the user's local App Store currency.)
    return _formatUsd(plan.price);
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

  /// Price per month for multi-month plans (e.g. "≈ 20$/month").
  /// Returned as null when a per-unit price is not meaningful.
  static String? _formatPerUnitPrice(PaymentPlan plan) {
    final months = _monthsForPlan(plan);
    if (plan.price <= 0 || months <= 1) return null;
    final perMonth = plan.price / months;
    return '≈ ${_formatUsd(perMonth)}/month';
  }

  PlanItem _toPlanItem(PaymentPlan p) {
    final colors = _colorsForKey(p.key);
    return PlanItem(
      id: p.key,
      title: p.name,
      description: _formatDescription(p),
      price: _formatPrice(p),
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
    return PopScope(
      canPop: !widget.isPaywall,
      child: Scaffold(
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
                    final selected = _selectedIndex.clamp(
                      0,
                      uiPlans.length - 1,
                    );
                    final selectedPlan = plans[selected];
                    final selectedUiPlan = uiPlans[selected];
                    final isFreePlan = selectedPlan.price <= 0;
                    final premiumBlocked =
                        selectedPlan.key == 'premium' && _isPremiumFull;
                    final storeProductMissing =
                        AppleIapService.isSupported &&
                        !isFreePlan &&
                        !_iapProductsLoading &&
                        !_isStoreProductReady(selectedPlan.key);
                    final subscribeBlocked =
                        _checkoutLoading ||
                        _premiumAvailabilityLoading ||
                        (AppleIapService.isSupported && _iapProductsLoading) ||
                        premiumBlocked ||
                        storeProductMissing;
                    final buttonText =
                        _checkoutLoading ||
                            _premiumAvailabilityLoading ||
                            (AppleIapService.isSupported && _iapProductsLoading)
                        ? 'Loading...'
                        : premiumBlocked
                        ? 'Premium Full'
                        : storeProductMissing
                        ? 'Unavailable'
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
                            onTap: widget.isPaywall
                                ? _signOutFromPaywall
                                : () => Get.back(),
                            child: Row(
                              children: [
                                Icon(
                                  widget.isPaywall
                                      ? Icons.logout
                                      : Icons.chevron_left,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.isPaywall ? 'Sign out' : 'Back',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (AppleIapService.isSupported &&
                            (_iapProductsError != null || storeProductMissing))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _iapProductsError ??
                                        'Some App Store subscription products are unavailable right now.',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _iapProductsLoading
                                        ? null
                                        : _initializeAppleIap,
                                    child: Text(
                                      _iapProductsLoading
                                          ? 'Retrying...'
                                          : 'Retry loading products',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
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
                                widget.isPaywall
                                    ? 'Subscribe to unlock the app. You can use Disability Fitness after your plan is active.'
                                    : 'Start your disability fitness journey',
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
                            opacity: subscribeBlocked ? 0.5 : 1,
                            child: CustomButton(
                              onPressed: subscribeBlocked
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
                            onPressed: _restoreLoading
                                ? null
                                : _handleRestorePurchases,
                            child: Text(
                              _restoreLoading
                                  ? 'Restoring...'
                                  : 'Restore Purchases',
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            Text(
                              '·',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _openLegalLink(
                                url: LegalUrls.privacyPolicyUrl,
                                fallbackScreen: const PrivacyLegalScreen(),
                              ),
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
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
