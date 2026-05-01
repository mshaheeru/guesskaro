import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.labelHome = 'Home',
    this.labelProfile = 'Profile',
    this.labelSettings = 'Settings',
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final String labelHome;
  final String labelProfile;
  final String labelSettings;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          children: <Widget>[
            _NavItem(
              icon: Icons.home_rounded,
              label: labelHome,
              active: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: labelProfile,
              active: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.settings_rounded,
              label: labelSettings,
              active: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? AppColors.orange : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.enCaption.copyWith(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
