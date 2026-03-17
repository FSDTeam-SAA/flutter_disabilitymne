import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/onboarding/choose_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Plan keys matching backend subscriptionPlans.js
const String kPlanFreeTrial = 'free_trial';
const String kPlanSixMonth = 'six_month_plan';
const String kPlanPremium = 'premium_plan';

const int _daysThreshold = 6;

const String _storageKeyTrialPopup = 'upgrade_popup_trial_shown';
const String _storageKeySubEndPrefix = 'upgrade_popup_sub_end_';

/// Returns days until [isoDate]; negative if in the past.
int _daysUntil(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return 999;
  final end = DateTime.tryParse(isoDate);
  if (end == null) return 999;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final endDay = DateTime(end.year, end.month, end.day);
  return endDay.difference(today).inDays;
}

/// True if we should show the trial popup (free_trial plan or trialEndsAt set; ends within 6 days or ended), and we haven't shown it once yet.
bool shouldShowTrialPopup(UserModel user) {
  final plan = user.selectedPlan;
  final trialEndsAt = user.trialEndsAt;
  final isTrialUser = plan == kPlanFreeTrial || trialEndsAt != null;
  if (!isTrialUser) return false;
  final endsAt = trialEndsAt ?? user.subscriptionEndsAt;
  if (endsAt == null || endsAt.isEmpty) return false;
  final days = _daysUntil(endsAt);
  if (days > _daysThreshold) return false;
  final box = GetStorage();
  return box.read<bool>(_storageKeyTrialPopup) != true;
}

void markTrialPopupShown() {
  GetStorage().write(_storageKeyTrialPopup, true);
}

/// True if user is on six_month_plan or premium_plan and subscription ends within 6 days or ended, and we haven't shown for this end date.
bool shouldShowSubscriptionEndPopup(UserModel user) {
  final plan = user.selectedPlan;
  if (plan != kPlanSixMonth && plan != kPlanPremium) return false;
  final endsAt = user.subscriptionEndsAt;
  if (endsAt == null || endsAt.isEmpty) return false;
  final days = _daysUntil(endsAt);
  if (days > _daysThreshold) return false;
  final key = '$_storageKeySubEndPrefix${user.id}_$endsAt';
  return GetStorage().read<bool>(key) != true;
}

void markSubscriptionEndPopupShown(UserModel user) {
  final endsAt = user.subscriptionEndsAt;
  if (endsAt == null) return;
  GetStorage().write('$_storageKeySubEndPrefix${user.id}_$endsAt', true);
}

/// Builds the message: "Your free trial has been finished with in X Days" or "Your subscription ends in X days".
String messageTitle(UserModel user, {required bool isTrial}) {
  final isoDate = isTrial ? (user.trialEndsAt ?? user.subscriptionEndsAt) : user.subscriptionEndsAt;
  final days = _daysUntil(isoDate);
  if (days < 0) {
    return isTrial
        ? 'Your free trial has finished.'
        : 'Your subscription has finished.';
  }
  if (days == 0) {
    return isTrial
        ? 'Your free trial finishes today.'
        : 'Your subscription finishes today.';
  }
  return isTrial
      ? 'Your free trial has been finished with in $days Days'
      : 'Your subscription has been finished with in $days Days';
}

/// Dialog shown on home when trial or subscription is ending (within 6 days). Dark blue modal, "Not now" / "Upgrade Plan".
void showUpgradePlanDialog({
  required String title,
  required VoidCallback onUpgrade,
}) {
  Get.dialog(
    _UpgradePlanDialog(
      title: title,
      subtitle: 'Click on Upgrade to upgrade plan',
      onNotNow: () => Get.back(),
      onUpgrade: () {
        Get.back();
        onUpgrade();
      },
    ),
    barrierDismissible: false,
  );
}

class _UpgradePlanDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onNotNow;
  final VoidCallback onUpgrade;

  const _UpgradePlanDialog({
    required this.title,
    required this.subtitle,
    required this.onNotNow,
    required this.onUpgrade,
  });

  static const Color _bgDark = Color(0xFF1A233A);
  static const Color _accentCyan = Color(0xFF89C9E6);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _bgDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNotNow,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: _accentCyan),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onUpgrade,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentCyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Upgrade Plan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Call from HomeScreen when profile user is available: shows popup once for trial, or when subscription ends in 6 days for six_month/premium.
void maybeShowUpgradePopup(UserModel user) {
  if (shouldShowTrialPopup(user)) {
    markTrialPopupShown();
    showUpgradePlanDialog(
      title: messageTitle(user, isTrial: true),
      onUpgrade: () => Get.to(() => const ChoosePlanScreen()),
    );
    return;
  }
  if (shouldShowSubscriptionEndPopup(user)) {
    markSubscriptionEndPopupShown(user);
    showUpgradePlanDialog(
      title: messageTitle(user, isTrial: false),
      onUpgrade: () => Get.to(() => const ChoosePlanScreen()),
    );
  }
}
