import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const String _keyOnboardingCompleted = 'onboarding_completed';
const String _keyIntroSeen = 'intro_onboarding_seen';

/// Persists onboarding completion from login API response so AppManager can
/// route to Gender screen (onboarding) vs AppGround. Set from login; clear on logout.
/// Also tracks first-install intro slides (Splash → Onboarding → Welcome/login).
/// Intro flag survives logout so slides do not repeat; tokens clear on reinstall.
class OnboardingStateHolder extends GetxController {
  final GetStorage _box = GetStorage();

  /// When true, AppManager must not hijack navigation (signup → fitness → login).
  bool suppressAuthNavigation = false;

  /// After onboarding/signup logout, send the user to Sign In instead of Welcome.
  bool routeToLoginOnLogout = false;

  /// True if user finished onboarding (API flag or final step).
  bool get isOnboardingCompleted {
    final stored = _box.read<bool>(_keyOnboardingCompleted);
    return stored == true;
  }

  /// True after first-install intro slides were finished or skipped.
  bool get hasSeenIntro {
    final stored = _box.read<bool>(_keyIntroSeen);
    return stored == true;
  }

  /// Save onboarding state from login API user. Call before persisting auth.
  void saveFromLogin(UserModel? user) {
    if (user == null) return;
    final completed =
        user.onboardingCompleted == true || (user.onboardingStep ?? 0) >= 8;
    _box.write(_keyOnboardingCompleted, completed);
  }

  /// Mark onboarding as completed (e.g. after PATCH /users/me in onboarding flow).
  void setOnboardingCompleted() {
    _box.write(_keyOnboardingCompleted, true);
  }

  /// Mark first-install intro as seen (survives logout; cleared only on reinstall).
  void setIntroSeen() {
    _box.write(_keyIntroSeen, true);
  }

  /// Clear API onboarding flag on logout. Intro flag stays so slides don't repeat.
  /// [routeToLoginOnLogout] is left intact so AppManager can still send the user
  /// to Sign In after a post-signup logout.
  void clear() {
    _box.remove(_keyOnboardingCompleted);
    suppressAuthNavigation = false;
  }
}
