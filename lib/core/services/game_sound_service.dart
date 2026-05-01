import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSoundService {
  GameSoundService() : _sfxPlayer = AudioPlayer(), _tickPlayer = AudioPlayer() {
    unawaited(_sfxPlayer.setReleaseMode(ReleaseMode.stop));
    unawaited(_tickPlayer.setReleaseMode(ReleaseMode.stop));
  }

  final AudioPlayer _sfxPlayer;
  final AudioPlayer _tickPlayer;

  Future<bool> _isSoundEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_enabled') ?? true;
  }

  Future<void> playCorrect() async {
    if (!await _isSoundEnabled()) return;
    await _play(_sfxPlayer, 'sounds/correct.wav');
  }

  Future<void> playWrong() async {
    if (!await _isSoundEnabled()) return;
    await _play(_sfxPlayer, 'sounds/wrong.wav');
  }

  Future<void> playWin() async {
    if (!await _isSoundEnabled()) return;
    await _play(_sfxPlayer, 'sounds/win.wav');
  }

  Future<void> playTick() async {
    if (!await _isSoundEnabled()) return;
    await _play(_tickPlayer, 'sounds/tick.wav');
  }

  Future<void> startAmbientLoop() async {
    // Disabled by request: no continuous app song for now.
  }

  Future<void> startTensionLoop() async {
    // Disabled by request: no continuous app song for now.
  }

  Future<void> stopAmbientLoop() async {
    // No-op while loops are disabled.
  }

  Future<void> _play(AudioPlayer player, String assetPath) async {
    try {
      await player.stop();
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('sound-playback-error: $e');
    }
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _tickPlayer.dispose();
  }
}

final Provider<GameSoundService> gameSoundServiceProvider =
    Provider<GameSoundService>((Ref ref) {
      final GameSoundService service = GameSoundService();
      ref.onDispose(() {
        unawaited(service.dispose());
      });
      return service;
    });
