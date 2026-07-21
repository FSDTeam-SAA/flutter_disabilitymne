import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const String _keyOnboardingCompleted = 'onboarding_completed';
const String _keyIntroSeen = 'intro_onboarding_seen';
const String _keyGuestMode = 'guest_mode_chosen';

/// Persists onboarding completion from login API response so AppManager can
/// route to Gender screen (onboarding) vs AppGround. Set from login; clear on logout.
/// Also tracks first-install intro slides (Splash → Onboarding → Welcome/login)
/// and guest browse preference (Splash → GuestGround when logged out).
/// Intro / guest flags survive logout so slides do not repeat; tokens clear on reinstall.
class OnboardingStateHolder extends GetxController {
  final GetStorage _box = GetStorage();

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

  /// True after user chose "Continue as Guest" (restored on next cold start).
  bool get isGuestMode {
    final stored = _box.read<bool>(_keyGuestMode);
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

  /// Persist guest browse choice so Splash can reopen GuestGround when logged out.
  void setGuestMode() {
    _box.write(_keyGuestMode, true);
  }

  /// Clear guest preference (e.g. after a successful login).
  void clearGuestMode() {
    _box.remove(_keyGuestMode);
  }

  /// Clear API onboarding flag on logout. Intro / guest flags stay so slides don't repeat.
  void clear() {
    _box.remove(_keyOnboardingCompleted);
  }
}
