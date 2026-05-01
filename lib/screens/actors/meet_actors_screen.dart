import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../../core/locale/ui_strings.dart';
import '../../data/meet_actors_catalog.dart';
import '../../widgets/common/game_pop_scope.dart';
import '../../widgets/common/urdu_text.dart';
import '../../widgets/jp_card.dart';

class MeetActorsScreen extends ConsumerWidget {
  const MeetActorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiStrings s = UiStrings.watch(ref);

    return GamePopScope(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: s.isEnglish
              ? Text(
                  s.meetActorsAppBarTitle,
                  style: AppTextStyles.enTitle.copyWith(fontSize: 18),
                )
              : UrduText(
                  s.meetActorsAppBarTitle,
                  style: AppTextStyles.urduHeadline.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInsetGap(context)),
          children: <Widget>[
            JpCard(
              child: s.isEnglish
                  ? Text(
                      s.meetActorsIntroEn,
                      style: AppTextStyles.enBody.copyWith(height: 1.5),
                    )
                  : UrduText(
                      AppStrings.meetActorsIntroUr,
                      style: AppTextStyles.urduBody,
                      textAlign: TextAlign.right,
                    ),
            ),
            const SizedBox(height: 14),
            ...MeetActorsCatalog.entries.map(
              (MeetActorDef a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActorCard(actor: a, strings: s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActorCard extends StatelessWidget {
  const _ActorCard({required this.actor, required this.strings});

  static const double _avatarDiameter = 132;

  final MeetActorDef actor;
  final UiStrings strings;

  @override
  Widget build(BuildContext context) {
    return JpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              width: _avatarDiameter,
              height: _avatarDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.45),
                  width: 3,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Transform.translate(
                offset: actor.portraitNudge,
                child: Transform.scale(
                  scale: actor.portraitScale,
                  alignment: Alignment.center,
                  child: Image.asset(
                    actor.imageAssetPath,
                    width: _avatarDiameter,
                    height: _avatarDiameter,
                    fit: BoxFit.cover,
                    alignment: actor.portraitAlignment,
                    gaplessPlayback: true,
                    errorBuilder:
                        (BuildContext _, Object __, StackTrace? ___) =>
                            ColoredBox(
                              color: AppColors.bgElevated,
                              child: Center(
                                child: strings.isEnglish
                                    ? Text(
                                        strings.meetActorsPortraitSoon,
                                        style: AppTextStyles.enCaption,
                                        textAlign: TextAlign.center,
                                      )
                                    : UrduText(
                                        strings.meetActorsPortraitSoon,
                                        style: AppTextStyles.urduCaption,
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          strings.isEnglish
              ? Text(
                  actor.nameEn,
                  style: AppTextStyles.enTitle.copyWith(fontSize: 17),
                )
              : UrduText(
                  actor.nameUr,
                  style: AppTextStyles.urduHeadline.copyWith(fontSize: 20),
                  textAlign: TextAlign.right,
                ),
          const SizedBox(height: 8),
          strings.isEnglish
              ? Text(
                  actor.bioEn,
                  style: AppTextStyles.enBody.copyWith(height: 1.45),
                )
              : UrduText(
                  actor.bioUr,
                  style: AppTextStyles.urduBody,
                  textAlign: TextAlign.right,
                ),
        ],
      ),
    );
  }
}
