/// Apple App Store product IDs for auto-renewable subscriptions.
class IapProductIds {
  IapProductIds._();

  static const monthly = 'com.disability.disabilitymn.plan.monthly';
  static const annual = 'com.disability.disabilitymn.plan.annual';
  static const quarterly = 'com.disability.disabilitymn.plan.quarterly';
  static const premium = 'com.disability.disabilitymn.plan.premium';

  static const all = <String>{
    monthly,
    annual,
    quarterly,
    premium,
  };

  static String? forPlanKey(String planKey) {
    switch (planKey) {
      case 'monthly':
        return monthly;
      case 'quarterly':
        return quarterly;
      case 'annual':
        return annual;
      case 'premium':
        return premium;
      default:
        return null;
    }
  }
}
