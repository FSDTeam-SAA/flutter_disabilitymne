import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const String _keyOnboardingCompleted = 'onboarding_completed';

/// Persists onboarding completion from login API response so AppManager can
/// route to Gender screen (onboarding) vs AppGround. Set from login; clear on logout.
class OnboardingStateHolder extends GetxController {
  final GetStorage _box = GetStorage();

  /// Save onboarding state from login API user. Call after successful login.
  void saveFromLogin(UserModel? user) {
    if (user == null) return;
    final completed = user.onboardingCompleted == true;
    _box.write(_keyOnboardingCompleted, completed);
  }

  /// Mark onboarding as completed (e.g. after PATCH /users/me in onboarding flow).
  void setOnboardingCompleted() {
    _box.write(_keyOnboardingCompleted, true);
  }

  /// True only if we have a stored value of true (user completed onboarding).
  bool get isOnboardingCompleted => _box.read<bool>(_keyOnboardingCompleted) == true;

  /// Clear on logout.
  void clear() {
    _box.remove(_keyOnboardingCompleted);
  }
}
