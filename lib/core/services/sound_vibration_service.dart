import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundVibrationService {
  static final SoundVibrationService _instance = SoundVibrationService._internal();
  factory SoundVibrationService() => _instance;
  SoundVibrationService._internal();

  AudioPlayer? _audioPlayer;

  int _playId = 0;

  /// Play a sound from assets.
  /// Example: [soundName] = 'incoming_ring' (resolves to 'audio/incoming_ring.mp3')
  Future<void> playSound(String soundName, {bool loop = false}) async {
    try {
      await stopSound();
      
      _playId++;
      final int currentPlayId = _playId;
      
      final player = AudioPlayer();
      _audioPlayer = player;
      
      String assetPath = soundName;
      if (!soundName.contains('/') && !soundName.contains('.')) {
        assetPath = 'audio/$soundName.mp3';
      }

      await player.play(AssetSource(assetPath));
      
      if (_playId != currentPlayId || _audioPlayer != player) {
        // stopSound() was called while we were waiting for native play to start
        await player.stop();
        await player.dispose();
        return;
      }
      
      if (loop) {
        await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer?.setReleaseMode(ReleaseMode.release);
      }
      
      debugPrint('SoundVibrationService: Playing sound $assetPath (loop: $loop)');
    } catch (e) {
      debugPrint('SoundVibrationService error playing sound: $e');
    }
  }

  /// Stop the playing sound.
  Future<void> stopSound() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer?.stop();
        await _audioPlayer?.dispose();
        _audioPlayer = null;
        debugPrint('SoundVibrationService: Sound stopped');
      }
    } catch (e) {
      debugPrint('SoundVibrationService error stopping sound: $e');
    }
  }

  /// Start device vibration.
  Future<void> startVibration({List<int> pattern = const [500, 1000, 500, 1000], int repeat = 0}) async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(pattern: pattern, repeat: repeat);
        debugPrint('SoundVibrationService: Vibration started');
      }
    } catch (e) {
      debugPrint('SoundVibrationService error starting vibration: $e');
    }
  }

  /// Stop device vibration.
  Future<void> stopVibration() async {
    try {
      await Vibration.cancel();
      debugPrint('SoundVibrationService: Vibration stopped');
    } catch (e) {
      debugPrint('SoundVibrationService error stopping vibration: $e');
    }
  }

  bool _isRinging = false;

  /// Trigger a single subtle soft haptic tap (bilkul na ke barabar)
  Future<void> triggerSoftTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
    try {
      if (await Vibration.hasVibrator()) {
        if (await Vibration.hasAmplitudeControl()) {
          await Vibration.vibrate(duration: 30, amplitude: 25);
        } else {
          await Vibration.vibrate(duration: 25);
        }
      }
    } catch (e) {
      debugPrint('SoundVibrationService error in triggerSoftTap: $e');
    }
  }

  /// Helper to start both sound and vibration (e.g. for incoming/outgoing ringtones)
  /// [continuousVibrate]: If false (default), only triggers a single subtle soft tap on start,
  /// preventing heavy, aggressive continuous phone vibrations while waiting for a request.
  Future<void> startRingtone(
    String soundName, {
    bool loop = true,
    bool vibrate = true,
    bool continuousVibrate = false,
  }) async {
    _isRinging = true;
    await playSound(soundName, loop: loop);
    if (vibrate && _isRinging) {
      if (continuousVibrate) {
        await startVibration(pattern: const [500, 1000, 500, 1000], repeat: 0);
      } else {
        await triggerSoftTap();
      }
    }
  }

  /// Helper to stop both sound and vibration
  Future<void> stopRingtone() async {
    _isRinging = false;
    await stopSound();
    await stopVibration();
  }
}
