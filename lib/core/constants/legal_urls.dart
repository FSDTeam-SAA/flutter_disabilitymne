/// Central place for the legal document links required by App Review
/// (Guideline 3.1.2 – auto-renewable subscriptions).
///
/// These MUST match what you enter in App Store Connect:
///   * Privacy Policy URL  -> App Store Connect > App Privacy > Privacy Policy URL
///   * Terms of Use (EULA) -> App Description (standard EULA) OR the custom
///     License Agreement field in App Store Connect.
class LegalUrls {
  LegalUrls._();

  /// Apple's standard Terms of Use (EULA). This link is always accepted by
  /// App Review. If you host a custom EULA, replace this with its https URL.
  static const String termsOfUseUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  /// Publicly hosted Privacy Policy URL. It MUST be the same URL you enter in
  /// App Store Connect. Leave empty to fall back to the in-app privacy screen.
  static const String privacyPolicyUrl =
      'https://www.termsfeed.com/live/9cf2c46c-f3a3-49d5-8759-2a6b2a7efdfb';
}
