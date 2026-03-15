/// Response for POST /payments/checkout and POST /payments/checkout/confirm.
library;

class CheckoutResponse {
  final String? checkoutUrl;
  final String? sessionId;
  final Map<String, dynamic>? payment;
  final Map<String, dynamic>? user;

  CheckoutResponse({
    this.checkoutUrl,
    this.sessionId,
    this.payment,
    this.user,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      checkoutUrl: json['checkoutUrl'] as String?,
      sessionId: json['sessionId'] as String?,
      payment: json['payment'] as Map<String, dynamic>?,
      user: json['user'] as Map<String, dynamic>?,
    );
  }

  bool get isFreePlan => checkoutUrl == null || (checkoutUrl?.isEmpty ?? true);
}
