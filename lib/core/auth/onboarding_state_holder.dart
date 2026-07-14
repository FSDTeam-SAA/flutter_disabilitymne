import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const String _keyOnboardingCompleted = 'onboarding_completed';

/// Persists onboarding completion from login API response so AppManager can
/// route to Gender screen (onboarding) vs AppGround. Set from login; clear on logout.
class OnboardingStateHolder extends GetxController {
  final GetStorage _box = GetStorage();

  /// True if user finished onboarding (API flag or final step).
  bool get isOnboardingCompleted {
    final stored = _box.read<bool>(_keyOnboardingCompleted);
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

  /// Clear on logout.
  void clear() {
    _box.remove(_keyOnboardingCompleted);
  }
}
