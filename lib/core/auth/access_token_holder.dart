import 'package:get/get.dart';

/// Holds the current JWT access token for use by Socket.IO and other clients.
/// Set after login, clear on logout. Chat socket uses this to connect with auth.
class AccessTokenHolder extends GetxController {
  final Rx<String?> _token = Rx<String?>(null);
  String? get token => _token.value;
  void setToken(String? value) => _token.value = value;
  void clear() => _token.value = null;
}
