import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';

/// One recurring character shown in phrase photos (EN + Urdu from [AppStrings]).
class MeetActorDef {
  const MeetActorDef({
    required this.nameEn,
    required this.bioEn,
    required this.nameUr,
    required this.bioUr,
    required this.imageFileName,
    this.portraitScale = 1.0,
    this.portraitNudge = Offset.zero,
    this.portraitAlignment = Alignment.center,
  });

  final String nameEn;
  final String bioEn;
  final String nameUr;
  final String bioUr;

  /// File under [characters/] (e.g. `potato.png`).
  final String imageFileName;

  /// >1 zooms in inside the circular clip.
  final double portraitScale;

  /// Pixels to shift the bitmap (e.g. positive dx moves content right).
  final Offset portraitNudge;

  /// [Image.alignment] for [BoxFit.cover] crop.
  final Alignment portraitAlignment;

  String get imageAssetPath => 'characters/$imageFileName';
}

/// Keep EN bios in sync with Urdu in [AppStrings].
class MeetActorsCatalog {
  MeetActorsCatalog._();

  static const List<MeetActorDef> entries = <MeetActorDef>[
    MeetActorDef(
      nameEn: 'Grumpy Potato',
      bioEn:
          'A round, lumpy potato with a permanently unimpressed face and tiny arms. '
          'Great for scenes about stubbornness, feeling worthless, or being overlooked.',
      nameUr: AppStrings.meetActorGrumpyPotatoNameUr,
      bioUr: AppStrings.meetActorGrumpyPotatoBioUr,
      imageFileName: 'potato.png',
      portraitScale: 1.22,
    ),
    MeetActorDef(
      nameEn: 'Wobbly Egg',
      bioEn:
          'A nervous, wide-eyed egg who is always slightly cracked. '
          'Great for scenes about fragility, anxiety, or surprise.',
      nameUr: AppStrings.meetActorWobblyEggNameUr,
      bioUr: AppStrings.meetActorWobblyEggBioUr,
      imageFileName: 'egg.png',
      portraitScale: 1.2,
    ),
    MeetActorDef(
      nameEn: 'Big Mustache Uncle',
      bioEn:
          'A short, round, traditionally dressed uncle with an enormous mustache '
          'and a chai cup always in hand. Great for wisdom, authority, life lessons, or cultural settings.',
      nameUr: AppStrings.meetActorUncleNameUr,
      bioUr: AppStrings.meetActorUncleBioUr,
      imageFileName: 'uncle.png',
    ),
    MeetActorDef(
      nameEn: 'Tiny Dragon',
      bioEn:
          'A very small, harmless-looking dragon who thinks he is terrifying. '
          'Great for false threats, ego, or exaggeration.',
      nameUr: AppStrings.meetActorTinyDragonNameUr,
      bioUr: AppStrings.meetActorTinyDragonBioUr,
      imageFileName: 'dragon.png',
    ),
    MeetActorDef(
      nameEn: 'Sad Broom',
      bioEn:
          'A broom with a droopy face. Great for being used, dismissed, or cleaning up someone else\'s mess.',
      nameUr: AppStrings.meetActorSadBroomNameUr,
      bioUr: AppStrings.meetActorSadBroomBioUr,
      imageFileName: 'broom.png',
    ),
    MeetActorDef(
      nameEn: 'Overconfident Rooster',
      bioEn:
          'A cocky rooster in a tiny waistcoat. Great for pride, showing off, or overestimating oneself.',
      nameUr: AppStrings.meetActorRoosterNameUr,
      bioUr: AppStrings.meetActorRoosterBioUr,
      imageFileName: 'rooster.png',
      portraitScale: 1.08,
    ),
  ];
}
