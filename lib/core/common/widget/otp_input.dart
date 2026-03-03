import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 6-digit OTP input with individual boxes.
class OtpInput extends StatelessWidget {
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OtpInputStateful(
      onCompleted: onCompleted,
      onChanged: onChanged,
    );
  }
}

class _OtpInputStateful extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const _OtpInputStateful({
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<_OtpInputStateful> createState() => _OtpInputStatefulState();
}

class _OtpInputStatefulState extends State<_OtpInputStateful> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  static const Color _border = Color(0xFF4A5568);
  static const Color _focusedBorder = Color(0xFF89C9E6);

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _notifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(otp);
    if (otp.length == 6) widget.onCompleted(otp);
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('').take(6).toList();
      for (int i = 0; i < digits.length && index + i < 6; i++) {
        _controllers[index + i].text = digits[i];
      }
      if (index + digits.length < 6) {
        _focusNodes[index + digits.length].requestFocus();
      } else {
        _focusNodes[5].unfocus();
      }
    } else if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[5].unfocus();
      }
    }
    _notifyOtp();
  }

  KeyEventResult _onKeyEvent(int index, FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 44,
          height: 52,
          child: Focus(
            onKeyEvent: (node, event) => _onKeyEvent(index, node, event),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: index == 0 ? 6 : 1,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              onChanged: (v) => _onChanged(index, v),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFF1A2A3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _focusedBorder, width: 2),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        );
      }),
    );
  }
}
