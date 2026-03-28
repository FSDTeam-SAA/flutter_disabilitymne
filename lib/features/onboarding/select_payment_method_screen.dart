import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/features/onboarding/payment_details_screen.dart';

/// Select Payment Method — shown after user selects Monthly, Quarterly, Annual, or Premium plan.
/// Displays "Bank account" option and "Continue to Pay $X.XX" button.
class SelectPaymentMethodScreen extends StatefulWidget {
  /// Amount to pay (e.g. 29.99 monthly, 149.99 quarterly, 144 annual, 150 premium).
  final double amount;
  /// Plan name for Payment Details screen (e.g. "Monthly", "Quarterly", "Annual", "Premium").
  final String planName;

  const SelectPaymentMethodScreen({
    super.key,
    required this.amount,
    required this.planName,
  });

  @override
  State<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  static const Color _bgDark = Color(0xFF1A2B43);

  int _selectedMethod = 0; // 0 = Bank account

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scaleW = (media.size.width / 375).clamp(0.8, 1.2);
    final scaleH = (media.size.height / 812).clamp(0.8, 1.2);

    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button + Back text — top left
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    (20 * scaleW).clamp(16, 28),
                    (12 * scaleH).clamp(8, 16),
                    20,
                    8,
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Get.back(),
                    minimumSize: Size(0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.back,
                          color: Colors.white,
                          size: 26,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: (17 * scaleW).clamp(16, 19),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Title — prominent, under Back
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (24 * scaleW).clamp(20, 32)),
                child: Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: (22 * scaleW).clamp(22, 30),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: (28 * scaleH).clamp(20, 36)),
              // Payment method list
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: (20 * scaleW).clamp(16, 28)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PaymentMethodCard(
                        iconAsset: 'assets/image/bank.png',
                        label: 'Bank account',
                        isSelected: _selectedMethod == 0,
                        onTap: () => setState(() => _selectedMethod = 0),
                      ),
                      // Placeholder for more methods later (e.g. Credit card, PayPal)
                    ],
                  ),
                ),
              ),
              // Continue to Pay $X.XX
              Padding(
                padding: EdgeInsets.fromLTRB(
                  (20 * scaleW).clamp(16, 28),
                  16,
                  (20 * scaleW).clamp(16, 28),
                  media.padding.bottom + (24 * scaleH).clamp(16, 32),
                ),
                child: _ContinueToPayButton(
                  amount: widget.amount,
                  onPressed: () => Get.to(() => PaymentDetailsScreen(
                    planName: widget.planName,
                    amount: widget.amount,
                  )),
                  scale: scaleW,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String? iconAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    this.iconAsset,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _cardBg = Color(0xFF253544);
  static const Color _cardBgSelected = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? _cardBgSelected : _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5B9BD5).withOpacity(0.5)
                : Colors.white.withOpacity(0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (iconAsset != null)
              Image.asset(
                iconAsset!,
                width: 28,
                height: 28,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
                fit: BoxFit.contain,
              )
            else
              Icon(Icons.credit_card, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            // Radio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1A2B43),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueToPayButton extends StatelessWidget {
  final double amount;
  final VoidCallback onPressed;
  final double scale;

  const _ContinueToPayButton({
    required this.amount,
    required this.onPressed,
    this.scale = 1.0,
  });

  static const Color _btnTop = Color(0xFF5B9BD5);
  static const Color _btnBottom = Color(0xFF3A7BB5);

  @override
  Widget build(BuildContext context) {
    final height = (54 * scale).clamp(50.0, 58.0);
    final fontSize = (17 * scale).clamp(16.0, 18.0);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_btnTop, _btnBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular((14 * scale).clamp(12, 16)),
        ),
        alignment: Alignment.center,
        child: Text(
          'Continue to Pay \$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
