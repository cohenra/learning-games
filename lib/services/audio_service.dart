import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service for playing music and sound effects
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();

  bool _isInitialized = false;
  final Map<String, bool> _availableAssets = {};

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _player.setReleaseMode(ReleaseMode.stop);
    await _backgroundPlayer.setReleaseMode(ReleaseMode.stop);

    // Check which audio files are available
    await _checkAvailableAssets();

    _isInitialized = true;
  }

  /// Check which audio assets exist
  Future<void> _checkAvailableAssets() async {
    final notes = ['c', 'd', 'e', 'f', 'g', 'a', 'b'];

    // Check notes
    for (final note in notes) {
      _availableAssets['notes/$note'] = await _assetExists('assets/audio/notes/$note.ogg') ||
          await _assetExists('assets/audio/notes/$note.wav') ||
          await _assetExists('assets/audio/notes/$note.mp3');
    }

    // Check drum
    _availableAssets['drums/hit'] = await _assetExists('assets/audio/drums/drum_hit.ogg') ||
        await _assetExists('assets/audio/drums/drum_hit.wav') ||
        await _assetExists('assets/audio/drums/drum_hit.mp3');

    // Check instruments
    final instruments = ['piano', 'guitar', 'flute', 'drum'];
    for (final instrument in instruments) {
      for (final note in notes) {
        final key = 'instruments/${instrument}_$note';
        _availableAssets[key] = await _assetExists('assets/audio/instruments/${instrument}_$note.ogg') ||
            await _assetExists('assets/audio/instruments/${instrument}_$note.wav') ||
            await _assetExists('assets/audio/instruments/${instrument}_$note.mp3');
      }
    }
  }

  /// Check if an asset file exists
  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the full path for an audio asset
  String? _getAssetPath(String key) {
    final extensions = ['ogg', 'wav', 'mp3'];

    for (final ext in extensions) {
      final path = 'audio/$key.$ext';
      // Check if we've confirmed this asset exists
      if (_availableAssets[key] == true) {
        return path;
      }
    }

    return null;
  }

  /// Play a musical note (C, D, E, F, G, A, B)
  Future<void> playNote(String note, {String? instrument}) async {
    await initialize();

    String key;
    if (instrument != null && instrument != 'piano') {
      key = 'instruments/${instrument}_${note.toLowerCase()}';
    } else {
      key = 'notes/${note.toLowerCase()}';
    }

    final path = _getAssetPath(key);

    if (path != null) {
      try {
        await _player.stop();
        await _player.play(AssetSource(path));
      } catch (e) {
        print('Error playing note $note: $e');
      }
    } else {
      print('Audio file not found for: $key');
    }
  }

  /// Play drum sound
  Future<void> playDrum() async {
    await initialize();

    final path = _getAssetPath('drums/hit');

    if (path != null) {
      try {
        await _player.stop();
        await _player.play(AssetSource(path));
      } catch (e) {
        print('Error playing drum: $e');
      }
    } else {
      print('Drum audio file not found');
    }
  }

  /// Play a sequence of notes
  Future<void> playSequence(List<Map<String, dynamic>> notes, {String? instrument, int delayMs = 400}) async {
    for (final noteData in notes) {
      final note = noteData['letter'] as String;
      await playNote(note, instrument: instrument);
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    await _player.stop();
    await _backgroundPlayer.stop();
  }

  /// Check if a note is available
  bool isNoteAvailable(String note, {String? instrument}) {
    String key;
    if (instrument != null && instrument != 'piano') {
      key = 'instruments/${instrument}_${note.toLowerCase()}';
    } else {
      key = 'notes/${note.toLowerCase()}';
    }
    return _availableAssets[key] == true;
  }

  /// Check if drum is available
  bool isDrumAvailable() {
    return _availableAssets['drums/hit'] == true;
  }

  /// Check if any audio assets are available
  bool hasAnyAssets() {
    return _availableAssets.values.any((available) => available);
  }

  /// Dispose of resources
  void dispose() {
    _player.dispose();
    _backgroundPlayer.dispose();
  }
}
