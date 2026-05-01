import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_config.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../core/services/game_sound_service.dart';
import '../../data/local/cache_service.dart';
import '../../data/repositories/local_profile_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/local_guest_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/urdu_text.dart';
import '../../widgets/custom_toggle_switch.dart';
import '../../widgets/jp_button_ghost.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sound = true;
  bool _haptic = true;
  bool _timedModeEnabled = false;
  String _version = '-';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadVersion();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sound = prefs.getBool('sound_enabled') ?? true;
      _haptic = prefs.getBool('haptic_enabled') ?? true;
      _timedModeEnabled = prefs.getBool('timed_mode_enabled') ?? false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _sound);
    await prefs.setBool('haptic_enabled', _haptic);
    await prefs.setBool('timed_mode_enabled', _timedModeEnabled);
  }

  Future<void> _loadVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() => _version = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final UiStrings s = UiStrings.watch(ref);
    final AppLang lang = ref.watch(appLangNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 16, 0, bottomInsetGap(context)),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              MediaQuery.of(context).padding.top + 2,
              12,
              4,
            ),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Text(
              'Settings',
              style: AppTextStyles.enTitle.copyWith(fontSize: 26),
            ),
          ),
          _SettingsSection(
            title: 'Language',
            rows: <Widget>[
              _SettingsRow(
                label: s.uiLanguage,
                right: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _LangPill(
                      label: 'اردو',
                      active: lang == AppLang.ur,
                      onTap:
                          () => ref
                              .read(appLangNotifierProvider.notifier)
                              .setLang(AppLang.ur),
                    ),
                    const SizedBox(width: 8),
                    _LangPill(
                      label: 'English',
                      active: lang == AppLang.en,
                      onTap:
                          () => ref
                              .read(appLangNotifierProvider.notifier)
                              .setLang(AppLang.en),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Gameplay',
            rows: <Widget>[
              _SettingsRow(
                label: s.sound,
                right: CustomToggleSwitch(
                  value: _sound,
                  onChanged: (v) async {
                    setState(() => _sound = v);
                    await _savePrefs();
                    if (v) {
                      await ref
                          .read(gameSoundServiceProvider)
                          .startAmbientLoop();
                    } else {
                      await ref
                          .read(gameSoundServiceProvider)
                          .stopAmbientLoop();
                    }
                  },
                ),
              ),
              _SettingsRow(
                label: s.haptic,
                right: CustomToggleSwitch(
                  value: _haptic,
                  onChanged: (v) async {
                    setState(() => _haptic = v);
                    await _savePrefs();
                  },
                ),
              ),
              _SettingsRow(
                label: 'Time based mode',
                sublabel: 'Show countdowns in game rounds',
                right: CustomToggleSwitch(
                  value: _timedModeEnabled,
                  onChanged: (v) async {
                    setState(() => _timedModeEnabled = v);
                    await _savePrefs();
                  },
                ),
                border: false,
              ),
            ],
          ),
          _SettingsSection(
            title: 'Account',
            rows: <Widget>[
              _SettingsRow(
                label: s.changeName,
                sublabel: profile?.displayName ?? '',
                right: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.textSecondary,
                ),
                onTap: profile == null ? null : () => _changeName(context, s),
              ),
              _SettingsRow(
                label: s.changeAvatar,
                right: const Text('😊', style: TextStyle(fontSize: 20)),
                onTap: profile == null ? null : () => _changeAvatar(context, s),
                border: false,
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
            rows: <Widget>[
              _SettingsRow(
                label: s.appVersion,
                right: Text(_version, style: AppTextStyles.enCaption),
              ),
              _SettingsRow(
                label: s.clearCache,
                right: const Icon(
                  Icons.cleaning_services_rounded,
                  color: AppColors.textSecondary,
                ),
                onTap: () => _clearCache(s),
                border: false,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: JpButtonGhost(
              label: s.signOut,
              onPressed: () => _signOut(s),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeName(BuildContext context, UiStrings strings) async {
    final current = ref.read(profileNotifierProvider).valueOrNull;
    if (current == null) return;
    final controller = TextEditingController(text: current.displayName);
    final ok =
        await showDialog<bool>(
          context: context,
          builder:
              (c) => Consumer(
                builder: (_, ref, _) {
                  final lang = ref.watch(appLangNotifierProvider);
                  return AlertDialog(
                    title: Text(strings.changeName),
                    content: TextField(
                      controller: controller,
                      textDirection:
                          lang == AppLang.en
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                      textAlign:
                          lang == AppLang.en ? TextAlign.start : TextAlign.end,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: Text(strings.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        child: Text(strings.save),
                      ),
                    ],
                  );
                },
              ),
        ) ??
        false;
    if (!ok) return;
    final String trimmed = controller.text.trim();
    if (!kAuthEnabled) {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateOfflineDisplayName(trimmed);
      return;
    }
    final repo = ref.read(profileRepositoryProvider);
    await repo.updateProfile(current.copyWith(displayName: trimmed));
    await ref.read(profileNotifierProvider.notifier).refreshProfile();
  }

  Future<void> _changeAvatar(BuildContext context, UiStrings strings) async {
    final current = ref.read(profileNotifierProvider).valueOrNull;
    if (current == null) return;
    int selected = current.avatarIndex;
    final ok =
        await showModalBottomSheet<bool>(
          context: context,
          showDragHandle: true,
          builder:
              (c) => StatefulBuilder(
                builder:
                    (c, setState) => Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        bottomInsetGap(c),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: List<Widget>.generate(6, (i) {
                              final avatar =
                                  ['😀', '😎', '🤩', '🧠', '🔥', '🌟'][i];
                              return ChoiceChip(
                                label: Text(avatar),
                                selected: selected == i,
                                onSelected: (_) => setState(() => selected = i),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => Navigator.of(c).pop(true),
                            child: Text(strings.save),
                          ),
                        ],
                      ),
                    ),
              ),
        ) ??
        false;
    if (!ok) return;
    if (!kAuthEnabled) {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateOfflineAvatar(selected);
      return;
    }
    final repo = ref.read(profileRepositoryProvider);
    await repo.updateProfile(current.copyWith(avatarIndex: selected));
    await ref.read(profileNotifierProvider.notifier).refreshProfile();
  }

  Future<void> _clearCache(UiStrings s) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder:
              (c) => AlertDialog(
                title: Text(s.clearCacheTitle),
                content: Text(s.clearCacheBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(c).pop(false),
                    child: Text(s.no),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(c).pop(true),
                    child: Text(s.yes),
                  ),
                ],
              ),
        ) ??
        false;
    if (!ok) return;
    final cache = ref.read(cacheServiceProvider);
    await cache.init();
    await cache.clearPhraseCacheOnly();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.cacheCleared)));
    }
  }

  Future<void> _signOut(UiStrings s) async {
    final bool ok =
        await showDialog<bool>(
          context: context,
          builder:
              (c) => AlertDialog(
                title: Text(s.signOutConfirmTitle),
                content: Text(s.signOutConfirmBody(remoteAuth: kAuthEnabled)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(c).pop(false),
                    child: Text(s.no),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(c).pop(true),
                    child: Text(s.yes),
                  ),
                ],
              ),
        ) ??
        false;
    if (!ok) return;

    if (kAuthEnabled) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) context.go('/sign-in');
    } else {
      await ref.read(localProfileRepositoryProvider).clearGuestData();
      await ref.read(cacheServiceProvider).init();
      await ref.read(cacheServiceProvider).clearPhraseCacheOnly();
      ref.invalidate(localGuestRegisteredProvider);
      ref.invalidate(profileNotifierProvider);
      if (mounted) context.go('/welcome');
    }
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title, style: AppTextStyles.enLabel),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.right,
    this.sublabel,
    this.border = true,
    this.onTap,
  });

  final String label;
  final String? sublabel;
  final Widget right;
  final bool border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          border:
              border
                  ? const Border(
                    bottom: BorderSide(color: AppColors.borderSubtle),
                  )
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTextStyles.enBody.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (sublabel != null && sublabel!.isNotEmpty)
                    Text(sublabel!, style: AppTextStyles.enCaption),
                ],
              ),
            ),
            right,
          ],
        ),
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              active
                  ? AppColors.orangeDim
                  : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color:
                active ? AppColors.orange : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child:
            label == 'اردو'
                ? UrduText(
                  label,
                  style: AppTextStyles.urduBody.copyWith(
                    color: active ? AppColors.orange : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
                : Text(
                  label,
                  style: AppTextStyles.enBody.copyWith(
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.orange : AppColors.textSecondary,
                  ),
                ),
      ),
    );
  }
}
