import 'package:disabilitymne/features/auth/model/user_model.dart';

const Set<String> _premiumPlanKeys = {'premium', 'premium_plan'};

/// Mirrors backend [isPremiumActiveUser] in disabilitymne-backend/src/utils/access.js.
bool isPremiumActiveUser(UserModel? user) {
  if (user == null) return false;

  final plan = (user.selectedPlan ?? '').trim().toLowerCase();
  if (!_premiumPlanKeys.contains(plan)) return false;

  if (user.subscriptionStatus != 'active') return false;

  final endsAt = user.subscriptionEndsAt;
  if (endsAt != null && endsAt.isNotEmpty) {
    final end = DateTime.tryParse(endsAt);
    if (end != null && !end.isAfter(DateTime.now())) return false;
  }

  return true;
}
