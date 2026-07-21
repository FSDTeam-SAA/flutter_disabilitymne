import 'package:app_pigeon/app_pigeon.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// GetStorage / SharedPreferences are wiped on uninstall.
/// iOS Keychain (flutter_secure_storage) often is NOT — so a reinstall can
/// still look "logged in". This clears secure auth when prefs say fresh install.
const String _kInstallMarkerKey = 'app_prefs_install_marker';

Future<void> clearAuthIfFreshInstall() async {
  final box = GetStorage();
  if (box.read<bool>(_kInstallMarkerKey) == true) {
    return;
  }

  debugPrint(
    'Fresh install detected (prefs marker missing) — clearing secure auth tokens',
  );

  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  try {
    await storage.deleteAll();
  } catch (e, st) {
    debugPrint('clearAuthIfFreshInstall deleteAll error: $e');
    debugPrint('$st');
  }

  // Marker lives in GetStorage → gone after uninstall → next install clears again.
  await box.write(_kInstallMarkerKey, true);
}
