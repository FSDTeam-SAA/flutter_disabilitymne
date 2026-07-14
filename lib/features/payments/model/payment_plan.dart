/// Models for Payment Plans API (`GET /payments/plans`).
library;

class PaymentPlan {
  final String key;
  final String name;
  final double price;
  final String currency;
  final int durationMonths;
  final String durationLabel;
  final int trialDays;
  final List<String> features;
  final bool isPopular;

  PaymentPlan({
    required this.key,
    required this.name,
    required this.price,
    required this.currency,
    required this.durationMonths,
    required this.durationLabel,
    required this.trialDays,
    required this.features,
    required this.isPopular,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) {
    return PaymentPlan(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? '',
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
      durationLabel: json['durationLabel']?.toString() ?? '',
      trialDays: (json['trialDays'] as num?)?.toInt() ?? 0,
      features: (json['features'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      isPopular: (json['isPopular'] as bool?) ?? false,
    );
  }
}

