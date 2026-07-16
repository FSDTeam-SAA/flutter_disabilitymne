class PremiumAvailability {
  final bool available;
  final int maxPremiumUsers;
  final int currentPremiumUsers;
  final int spotsRemaining;
  final String? message;

  const PremiumAvailability({
    required this.available,
    required this.maxPremiumUsers,
    required this.currentPremiumUsers,
    required this.spotsRemaining,
    this.message,
  });

  factory PremiumAvailability.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return PremiumAvailability(
      available: map['available'] == true,
      maxPremiumUsers: _asInt(map['maxPremiumUsers'], 20),
      currentPremiumUsers: _asInt(map['currentPremiumUsers'], 0),
      spotsRemaining: _asInt(map['spotsRemaining'], 0),
      message: map['message']?.toString(),
    );
  }

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
