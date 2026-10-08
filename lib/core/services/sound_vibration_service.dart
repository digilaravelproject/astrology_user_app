import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

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
      if (await Vibration.hasVibrator() ?? false) {
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

  /// Helper to start both sound and vibration (e.g. for incoming/outgoing ringtones)
  Future<void> startRingtone(String soundName, {bool loop = true, bool vibrate = true}) async {
    await playSound(soundName, loop: loop);
    if (vibrate) {
      await startVibration(pattern: const [500, 1000, 500, 1000], repeat: 0);
    }
  }

  /// Helper to stop both sound and vibration
  Future<void> stopRingtone() async {
    await stopSound();
    await stopVibration();
  }
}
