import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Plays tick / beep / done tones as a timed exercise counts down.
class CountdownSoundPlayer {
  AudioPool? _tick;
  AudioPool? _beep;
  AudioPool? _done;
  Future<void>? _initFuture;

  Future<void> init() {
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    final ctx = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();
    await AudioPlayer.global.setAudioContext(ctx);

    _tick = await AudioPool.create(
      source: AssetSource('sounds/countdown_tick.wav'),
      maxPlayers: 2,
      audioContext: ctx,
    );
    _beep = await AudioPool.create(
      source: AssetSource('sounds/countdown_beep.wav'),
      maxPlayers: 2,
      audioContext: ctx,
    );
    _done = await AudioPool.create(
      source: AssetSource('sounds/countdown_done.wav'),
      maxPlayers: 1,
      audioContext: ctx,
    );
  }

  /// Re-apply mix so countdown ticks stay audible over exercise video.
  Future<void> prepareSession() async {
    await AudioPlayer.global.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
    );
  }

  /// [remainingSeconds] is the value currently shown on the timer.
  Future<void> playForRemaining(int remainingSeconds) async {
    try {
      await _initFuture;
      if (remainingSeconds <= 0) {
        HapticFeedback.heavyImpact();
        await _done?.start();
      } else if (remainingSeconds <= 3) {
        HapticFeedback.mediumImpact();
        await _beep?.start();
      } else {
        HapticFeedback.selectionClick();
        await _tick?.start();
      }
    } catch (_) {
      // Sound should never block the workout timer.
    }
  }

  Future<void> dispose() async {
    await Future.wait([
      if (_tick != null) _tick!.dispose(),
      if (_beep != null) _beep!.dispose(),
      if (_done != null) _done!.dispose(),
    ]);
    _tick = null;
    _beep = null;
    _done = null;
  }
}
