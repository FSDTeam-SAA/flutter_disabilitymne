import 'package:disabilitymne/features/auth/model/user_model.dart';

const Set<String> _premiumPlanKeys = {'premium', 'premium_plan'};

const String premiumMembershipFullMessage =
    'Premium memberships are currently full. Please check back later for availability.';

const String premiumAwaitingCoachMessage =
    'Your coach is preparing your personalized plan. You can use the Nutrition Calculator and Exercise Library in the meantime.';

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

bool premiumHasAssignedWorkout(UserModel? user) =>
    isPremiumActiveUser(user) && user?.hasAssignedProgram == true;

bool premiumHasAssignedNutrition(UserModel? user) =>
    isPremiumActiveUser(user) && user?.hasAssignedNutritionPlan == true;

/// Premium users should not see the shared Explore catalog.
bool premiumShouldHideExplore(UserModel? user) => isPremiumActiveUser(user);
