import 'package:flutter/material.dart';

import '../core/constants/app_borders.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_shadows.dart';
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
    if (AppColors.isSunny) {
      return _SunnyBottomNav(
        selectedIndex: selectedIndex,
        onTap: onTap,
        labels: <String>[labelHome, labelProfile, labelSettings],
        icons: <IconData>[
          Icons.home_rounded,
          Icons.person_rounded,
          Icons.settings_rounded,
        ],
      );
    }

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          children: <Widget>[
            _ClassicNavItem(
              icon: Icons.home_rounded,
              label: labelHome,
              active: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _ClassicNavItem(
              icon: Icons.person_rounded,
              label: labelProfile,
              active: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _ClassicNavItem(
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

class _SunnyBottomNav extends StatelessWidget {
  const _SunnyBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.labels,
    required this.icons,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Container(
          height: 60,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: AppBorders.ink(),
            boxShadow: AppShadows.lg,
          ),
          child: Row(
            children: List<Widget>.generate(icons.length, (int i) {
              final bool active = selectedIndex == i;
              return Expanded(
                flex: active ? 14 : 10,
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: active ? AppColors.marigold : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border:
                          active
                              ? AppBorders.ink(width: AppBorders.bThin)
                              : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          icons[i],
                          size: 22,
                          color: AppColors.ink,
                        ),
                        if (active) ...<Widget>[
                          const SizedBox(width: 6),
                          Text(
                            labels[i],
                            style: AppTextStyles.enLabel.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ClassicNavItem extends StatelessWidget {
  const _ClassicNavItem({
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
