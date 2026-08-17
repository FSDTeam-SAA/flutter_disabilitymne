import 'package:disabilitymne/core/helpers/premium_access.dart';
import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/onboarding/choose_plan_screen.dart';
import 'package:disabilitymne/nabber_screen.dart';
import 'package:flutter/widgets.dart';

/// Paid users enter the app. Everyone else is locked to the subscription page.
Widget screenForAuthenticatedUser(UserModel? user) {
  if (isPaidSubscriber(user)) {
    return const AppGround();
  }
  return const ChoosePlanScreen(isPaywall: true);
}
