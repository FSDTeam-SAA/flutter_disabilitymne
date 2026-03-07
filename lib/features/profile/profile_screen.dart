import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:flutter/material.dart';

/// Profile screen matching the design: dark theme, bordered cards, menu list, sign out, bottom nav.

const double _profileCardRadius = 10.0;
const double _profileBorderWidth = 1.0;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatsCards(),
              const SizedBox(height: 24),
              _buildMenuList(),
              const SizedBox(height: 24),
              _buildSignOut(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLightBlue40, width: _profileBorderWidth),
            boxShadow: [
              BoxShadow(
                color: AppColors.profileActiveTab.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              ImagePath.profilepic,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.person, color: AppColors.profileTextPrimary, size: 32),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.profileTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    const TextSpan(text: 'Welcome Evan '),
                    TextSpan(
                      text: '👋',
                      style: TextStyle(
                        color: AppColors.profileEmojiAccent,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Good morning!',
                style: TextStyle(
                  color: AppColors.profileTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Streak', value: '7', icon: Icons.local_fire_department_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Workouts', value: '9', icon: Icons.fitness_center)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Calories', value: '0%', icon: Icons.show_chart)),
      ],
    );
  }

  Widget _buildMenuList() {
    final items = [
      _MenuItem(icon: Icons.person_outline, iconAsset: ImagePath.profileMyProfile, title: 'My Profile', subtitle: 'View personal details'),
      _MenuItem(icon: Icons.book_outlined, iconAsset: ImagePath.profileDailyNotes, title: 'Daily Notes', subtitle: 'View notes you have added daily'),
      _MenuItem(icon: Icons.workspace_premium_outlined, iconAsset: ImagePath.profileSubscriptionCrown, title: 'Subscription & Billing', subtitle: 'Manage your plan'),
      _MenuItem(icon: Icons.language_outlined, iconAsset: ImagePath.profileLanguageGlobe, title: 'Language & Accessibility', subtitle: 'English/Serbian'),
      _MenuItem(icon: Icons.notifications_outlined, iconAsset: ImagePath.profileNotificationsBell, title: 'Notification Settings', subtitle: 'Manage alerts'),
      _MenuItem(icon: Icons.headphones_outlined, iconAsset: ImagePath.profileHelpHeadset, title: 'Help & Support', subtitle: 'FAQs and contact'),
      _MenuItem(icon: Icons.shield_outlined, iconAsset: ImagePath.profilePrivacyShield, title: 'Privacy & Legal', subtitle: 'Privacy policy & data'),
      _MenuItem(icon: Icons.description_outlined, iconAsset: ImagePath.profileTermsDocument, title: 'Terms of Service', subtitle: 'App usage terms and conditions'),
      _MenuItem(icon: Icons.lock_outline, iconAsset: ImagePath.profilePrivacySecurity, title: 'Privacy & Security', subtitle: 'View personal details'),
    ];
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _MenuTile(item: item),
      )).toList(),
    );
  }

  Widget _buildSignOut(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: sign out
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_forward, color: AppColors.profileSignOutRed, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.profileSignOutRed,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.profileCardBackground,
        borderRadius: BorderRadius.circular(_profileCardRadius),
        border: Border.all(color: AppColors.borderLightBlue40, width: _profileBorderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.profileTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.profileTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Icon(icon, color: AppColors.profileTextPrimary, size: 20),

              // Image.asset()
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String? iconAsset;
  final String title;
  final String subtitle;

  _MenuItem({required this.icon, this.iconAsset, required this.title, required this.subtitle});
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuTile({required this.item});

  Widget _buildMenuIcon(_MenuItem item) {
    const double iconSize = 44;
    if (item.iconAsset != null && item.iconAsset!.isNotEmpty) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: Image.asset(
          item.iconAsset!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(item.icon, color: AppColors.profileTextPrimary, size: iconSize),
        ),
      );
    }
    return Icon(item.icon, color: AppColors.profileTextPrimary, size: iconSize);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(_profileCardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.profileCardBackground,
            borderRadius: BorderRadius.circular(_profileCardRadius),
            border: Border.all(color: AppColors.borderLightBlue40, width: _profileBorderWidth),
          ),
          child: Row(
            children: [
              _buildMenuIcon(item),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.profileTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: AppColors.profileTextSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.profileTextPrimary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

