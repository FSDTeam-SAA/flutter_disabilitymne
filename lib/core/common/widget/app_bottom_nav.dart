import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Public bottom navigation bar: dark rounded bar with glow, active pill, tab change via [onTap].
/// [currentIndex] 0=Home, 1=Programs, 2=Recipes, 3=Calculators, 4=Profile.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const int _tabCount = 5;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10 + bottomPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bottomNavBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderLightBlue40,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderLightBlue40,
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_tabCount, (index) {
            return _NavItem(
              icon: _iconFor(index),
              label: _labelFor(index),
              active: index == currentIndex,
              isProfile: index == 4,
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }

  static IconData _iconFor(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.assignment_outlined;
      case 2:
        return Icons.restaurant_outlined;
      case 3:
        return Icons.calculate_outlined;
      case 4:
        return Icons.person;
      default:
        return Icons.circle_outlined;
    }
  }

  static String _labelFor(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Programs';
      case 2:
        return 'Recipes';
      case 3:
        return 'Calculators';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool isProfile;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.isProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isProfile
        ? AppColors.bottomNavProfileIcon
        : AppColors.profileTextPrimary;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isProfile ? Icons.person : (active ? Icons.home_rounded : icon),
          color: iconColor,
          size: 22,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.profileTextPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    if (active) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bottomNavActiveBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderLightBlue40,
                width: 1,
              ),
            ),
            child: content,
          ),
        ),
      );
    }
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: content,
      ),
    );
  }
}
