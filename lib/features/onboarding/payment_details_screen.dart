import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/features/onboarding/congratulations_screen.dart';

/// Payment Details — card number, expiry, CVV. Shown after Select Payment Method.
class PaymentDetailsScreen extends StatefulWidget {
  final String planName;
  final double amount;

  const PaymentDetailsScreen({
    super.key,
    required this.planName,
    required this.amount,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  static const Color _bgDark = Color(0xFF1A2B43);
  static const Color _planBarBg = Color(0xFF493A32); // dark brown
  static const Color _planBarBorder = Color(0xFFFF8F00); // orange border
  static const Color _planNameOrange = Color(0xFFFF8F00); // orange text

  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scaleW = (media.size.width / 375).clamp(0.8, 1.2);
    final scaleH = (media.size.height / 812).clamp(0.8, 1.2);

    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      child: Material(
        color: _bgDark,
        child: SafeArea(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button — top left only
            Padding(
              padding: EdgeInsets.fromLTRB(
                (20 * scaleW).clamp(16, 28),
                (12 * scaleH).clamp(8, 16),
                20,
                8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Get.back(),
                  minimumSize: Size(0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.back, color: Colors.white, size: 26),
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
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: (24 * scaleW).clamp(20, 32)),
              child: Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: (22 * scaleW).clamp(22, 30),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: (24 * scaleH).clamp(18, 30)),
            // Selected Plan bar — dark brown, orange border, pill shape
            Padding(
              padding: EdgeInsets.symmetric(horizontal: (20 * scaleW).clamp(16, 28)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: _planBarBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _planBarBorder, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Plan',
                      style: TextStyle(
                        fontSize: (14 * scaleW).clamp(15, 18),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.planName,
                      style: TextStyle(
                        fontSize: (15 * scaleW).clamp(16, 19),
                        fontWeight: FontWeight.w600,
                        color: _planNameOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: (28 * scaleH).clamp(22, 34)),
            // Form fields
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: (20 * scaleW).clamp(16, 28)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PaymentField(
                      label: 'Card Number',
                      hint: '1234 5678 9012 3456',
                      controller: _cardController,
                      focusNode: _cardFocus,
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
                      ],
                    ),
                    SizedBox(height: (20 * scaleH).clamp(16, 24)),
                    _PaymentField(
                      label: 'Expiry Date',
                      hint: 'DD/MM/YYYY',
                      controller: _expiryController,
                      focusNode: _expiryFocus,
                      keyboardType: TextInputType.datetime,
                      maxLength: 10,
                      inputFormatters: [_ExpiryDateFormatter()],
                    ),
                    SizedBox(height: (20 * scaleH).clamp(16, 24)),
                    _PaymentField(
                      label: 'Cvv',
                      hint: '***',
                      controller: _cvvController,
                      focusNode: _cvvFocus,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Continue to Payment button
            Padding(
              padding: EdgeInsets.fromLTRB(
                (20 * scaleW).clamp(16, 28),
                16,
                (20 * scaleW).clamp(16, 28),
                media.padding.bottom + (24 * scaleH).clamp(16, 32),
              ),
              child: _ContinueToPaymentButton(
                onPressed: () => Get.offAll(() => CongratulationsScreen(planName: widget.planName)),
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

class _PaymentField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _PaymentField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
  });

  static const Color _fieldBg = Color(0xFF253544);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha:0.4),
              fontSize: 16,
            ),
            filled: true,
            fillColor: _fieldBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha:0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha:0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5B9BD5), width: 1.5),
            ),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 8) return oldValue;
    if (text.length >= 2) {
      final dd = text.substring(0, 2);
      final rest = text.length > 2 ? '/${text.substring(2)}' : '';
      final out = '$dd$rest';
      if (text.length >= 4) {
        final mm = text.substring(2, 4);
        final yyyy = text.length > 4 ? '/${text.substring(4)}' : '';
        return TextEditingValue(
          text: '$dd/$mm$yyyy',
          selection: TextSelection.collapsed(offset: '$dd/$mm$yyyy'.length),
        );
      }
      return TextEditingValue(
        text: out,
        selection: TextSelection.collapsed(offset: out.length),
      );
    }
    return newValue;
  }
}

class _ContinueToPaymentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double scale;

  const _ContinueToPaymentButton({
    required this.onPressed,
    this.scale = 1.0,
  });

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
            colors: [Color(0xFF5B9BD5), Color(0xFF3A7BB5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular((14 * scale).clamp(12, 16)),
        ),
        alignment: Alignment.center,
        child: Text(
          'Continue to Payment',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
