import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 0.7;
  double _musicVolume = 0.5;

  // Initialize audio service
  Future<void> initialize() async {
    await _loadSettings();
    await _preloadSounds();
  }

  // Load sound settings from preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
    _soundVolume = prefs.getDouble('sound_volume') ?? 0.7;
    _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
  }

  // Save sound settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('music_enabled', _musicEnabled);
    await prefs.setDouble('sound_volume', _soundVolume);
    await prefs.setDouble('music_volume', _musicVolume);
  }

  // Preload sound effects for better performance
  Future<void> _preloadSounds() async {
    try {
      // Note: These would be actual sound files in assets/sounds/
      // For now, we'll use system sounds as fallback
    } catch (e) {
      print('Failed to preload sounds: $e');
    }
  }

  // Sound Effects
  Future<void> playPiecePlaced() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/piece_placed.mp3'));
    } catch (e) {
      // Fallback to system sound
      _playSystemSound();
    }
  }

  Future<void> playLineClear() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/line_clear.mp3'));
    } catch (e) {
      _playSystemSound();
    }
  }

  Future<void> playCombo() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/combo.mp3'));
    } catch (e) {
      _playSystemSound();
    }
  }

  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/level_up.mp3'));
    } catch (e) {
      _playSystemSound();
    }
  }

  Future<void> playGameOver() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/game_over.mp3'));
    } catch (e) {
      _playSystemSound();
    }
  }

  Future<void> playButtonClick() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/button_click.mp3'));
    } catch (e) {
      _playSystemSound();
    }
  }

  Future<void> playPieceRotate() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/piece_rotate.mp3'));
    } catch (e) {
      _playSystemSound();
    }
  }

  Future<void> playWordReveal() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/word_reveal.mp3'));
    } catch (e) {
      _playSystemSound();
    }
  }

  // Background Music
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(AssetSource('sounds/background_music.mp3'));
    } catch (e) {
      print('Failed to play background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    await _musicPlayer.resume();
  }

  // System sound fallback
  void _playSystemSound() {
    // This would trigger device's system sound
    // For now, just a placeholder
  }

  // Getters and Setters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
    if (!enabled) {
      await _sfxPlayer.stop();
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await _saveSettings();
    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    await _sfxPlayer.setVolume(_soundVolume);
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
    await _musicPlayer.setVolume(_musicVolume);
  }

  // Dispose resources
  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
  }
}