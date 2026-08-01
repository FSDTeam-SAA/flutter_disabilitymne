import 'package:disabilitymne/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:disabilitymne/features/onboarding/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';

/// Step 7 of 8: Your mobility type — list of options, green selected state, radio indicators.
class MobilityTypeSelectionScreen extends StatefulWidget {
  const MobilityTypeSelectionScreen({super.key});

  @override
  State<MobilityTypeSelectionScreen> createState() => _MobilityTypeSelectionScreenState();
}

class _MobilityTypeSelectionScreenState extends State<MobilityTypeSelectionScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 7;

  int? _selectedIndex; // null = none or "Other" selected
  final TextEditingController _otherController = TextEditingController();
  final FocusNode _otherFocusNode = FocusNode();

  static const Color _darkBlue = Color(0xFF0D1B2A);
  static const Color _accentBlue = Color(0xFF89C9E6);
  static const Color _trackInactive = Color(0xFF6B7280);

  static const List<String> _options = [
    'Wheelchair User',
    'Limited Mobility',
    'Amputee (Leg)',
    'Amputee (Arm)',
    'Neurological Condition',
    'Chronic Pain',
    'Visual Impairment',
  ];

  @override
  void dispose() {
    _otherController.dispose();
    _otherFocusNode.dispose();
    super.dispose();
  }

  void _selectIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _otherController.clear();
    });
  }

  bool get _hasSelection => _selectedIndex != null || (_otherController.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chevron_left, color: _accentBlue, size: 28),
                            const SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: _accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Step $_currentStep of $_totalSteps',
                        style: TextStyle(
                          fontSize: 14,
                          color: _accentBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _currentStep / _totalSteps,
                      minHeight: 6,
                      backgroundColor: _trackInactive.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(_accentBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Your mobility type',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...List.generate(_options.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MobilityOptionCard(
                        label: _options[index],
                        isSelected: isSelected,
                        onTap: () => _selectIndex(index),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // "Other" input field
                  TextField(
                    controller: _otherController,
                    focusNode: _otherFocusNode,
                    onChanged: (_) => setState(() {}),
                    onTap: () => setState(() => _selectedIndex = null),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Other',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A2D42),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFF1A2D42).withValues(alpha: 0.6),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFF1A2D42).withValues(alpha: 0.6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF36D04C), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () {
                  if (!_hasSelection) return;
                  final c = Get.find<OnboardingController>();
                  if (_selectedIndex != null) {
                    c.setMobilityType(_selectedIndex!, '');
                  } else {
                    c.setMobilityType(7, _otherController.text.trim());
                  }
                  // Create Account comes before Fitness Experience.
                  Get.to(() => SignUpScreen(fromOnboarding: true));
                },
                text: 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobilityOptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobilityOptionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _cardUnselected = Color(0xFF1A2D42);
  static const Color _selectedBg = Color(0xFF1E5948);
  static const Color _selectedBorder = Color(0xFF36D04C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : null,
          gradient: isSelected
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _cardUnselected,
                    Color.lerp(_cardUnselected, Colors.black, 0.08)!,
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _selectedBorder : _cardUnselected.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.15),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 3 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            // Radio: filled green circle when selected, outline when not
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _selectedBorder : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _selectedBorder : Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
