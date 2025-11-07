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
  final Map<String, String> _assetPaths = {}; // Store actual file paths with extensions

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _player.setReleaseMode(ReleaseMode.stop);
    await _backgroundPlayer.setReleaseMode(ReleaseMode.stop);

    // Check which audio files are available
    await _checkAvailableAssets();

    _isInitialized = true;
  }

  /// Check which audio assets exist and store their paths
  Future<void> _checkAvailableAssets() async {
    final notes = ['c', 'd', 'e', 'f', 'g', 'a', 'b'];
    final extensions = ['wav', 'ogg', 'mp3'];

    // Check notes
    for (final note in notes) {
      final key = 'notes/$note';
      for (final ext in extensions) {
        final path = 'assets/audio/notes/$note.$ext';
        if (await _assetExists(path)) {
          _assetPaths[key] = 'audio/notes/$note.$ext';
          break;
        }
      }
    }

    // Check drum
    for (final ext in extensions) {
      final path = 'assets/audio/drums/drum_hit.$ext';
      if (await _assetExists(path)) {
        _assetPaths['drums/hit'] = 'audio/drums/drum_hit.$ext';
        break;
      }
    }

    // Check instruments
    final instruments = ['piano', 'guitar', 'flute', 'drum'];
    for (final instrument in instruments) {
      for (final note in notes) {
        final key = 'instruments/${instrument}_$note';
        for (final ext in extensions) {
          final path = 'assets/audio/instruments/${instrument}_$note.$ext';
          if (await _assetExists(path)) {
            _assetPaths[key] = 'audio/instruments/${instrument}_$note.$ext';
            break;
          }
        }
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
    return _assetPaths[key];
  }

  /// Play a musical note (C, D, E, F, G, A, B)
  Future<void> playNote(String note, {String? instrument, double pitchModifier = 1.0}) async {
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
        // Set playback rate to change pitch (range: 0.5 to 2.0)
        await _player.setPlaybackRate(pitchModifier.clamp(0.5, 2.0));
        // Use AssetSource with the path (already includes 'audio/')
        await _player.play(AssetSource(path));
        print('Playing note: $note from $path with pitch: $pitchModifier'); // Debug
      } catch (e) {
        print('Error playing note $note: $e');
      }
    } else {
      print('Audio file not found for: $key');
      print('Available assets: ${_assetPaths.keys.toList()}'); // Debug
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
        print('Playing drum from: $path'); // Debug
      } catch (e) {
        print('Error playing drum: $e');
      }
    } else {
      print('Drum audio file not found');
      print('Available assets: ${_assetPaths.keys.toList()}'); // Debug
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
    return _assetPaths.containsKey(key);
  }

  /// Check if drum is available
  bool isDrumAvailable() {
    return _assetPaths.containsKey('drums/hit');
  }

  /// Check if any audio assets are available
  bool hasAnyAssets() {
    return _assetPaths.isNotEmpty;
  }

  /// Dispose of resources
  void dispose() {
    _player.dispose();
    _backgroundPlayer.dispose();
  }
}
