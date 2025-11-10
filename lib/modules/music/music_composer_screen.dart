import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/kid_back_button.dart';
import '../../utils/responsive_helper.dart';
import '../../services/audio_service.dart';

/// מסך יצירת מוזיקה - פסנתר לילדים
class MusicComposerScreen extends StatefulWidget {
  const MusicComposerScreen({super.key});

  @override
  State<MusicComposerScreen> createState() => _MusicComposerScreenState();
}

class _MusicComposerScreenState extends State<MusicComposerScreen> {
  final AudioService _audioService = AudioService();
  bool _isHebrew = true;
  bool _isPlaying = false;
  double _tempo = 120; // BPM (beats per minute)

  // 8 notes from C4 to C5 with exact frequencies from React code
  final List<Map<String, dynamic>> _notes = [
    {'nameHe': 'דו', 'nameEn': 'C4', 'letter': 'C', 'color': const Color(0xFFFF6B6B), 'frequency': 261.63, 'pitch': 0.7},
    {'nameHe': 'רה', 'nameEn': 'D4', 'letter': 'D', 'color': const Color(0xFFFFA500), 'frequency': 293.66, 'pitch': 0.8},
    {'nameHe': 'מי', 'nameEn': 'E4', 'letter': 'E', 'color': const Color(0xFFFFD93D), 'frequency': 329.63, 'pitch': 0.9},
    {'nameHe': 'פה', 'nameEn': 'F4', 'letter': 'F', 'color': const Color(0xFF6BCB77), 'frequency': 349.23, 'pitch': 1.0},
    {'nameHe': 'סול', 'nameEn': 'G4', 'letter': 'G', 'color': const Color(0xFF4D96FF), 'frequency': 392.00, 'pitch': 1.2},
    {'nameHe': 'לה', 'nameEn': 'A4', 'letter': 'A', 'color': const Color(0xFF9D4EDD), 'frequency': 440.00, 'pitch': 1.4},
    {'nameHe': 'סי', 'nameEn': 'B4', 'letter': 'B', 'color': const Color(0xFFFF6BCB), 'frequency': 493.88, 'pitch': 1.6},
    {'nameHe': 'דו גבוה', 'nameEn': 'C5', 'letter': 'C5', 'color': const Color(0xFFE63946), 'frequency': 523.25, 'pitch': 1.8},
  ];

  // 4 instruments matching React code - Piano (sine), Flute (sine), Guitar (triangle), Drum (square)
  final List<Map<String, dynamic>> _instruments = [
    {'nameHe': 'פסנתר', 'nameEn': 'Piano', 'icon': '🎹', 'id': 'piano', 'pitchMod': 1.0, 'wave': 'sine'},
    {'nameHe': 'חליל', 'nameEn': 'Flute', 'icon': '🎶', 'id': 'flute', 'pitchMod': 1.6, 'wave': 'sine'},
    {'nameHe': 'גיטרה', 'nameEn': 'Guitar', 'icon': '🎸', 'id': 'guitar', 'pitchMod': 1.3, 'wave': 'triangle'},
    {'nameHe': 'תופים', 'nameEn': 'Drum', 'icon': '🥁', 'id': 'drum', 'pitchMod': 0.8, 'wave': 'square'},
  ];

  int _selectedInstrument = 0;
  List<Map<String, dynamic>> _recordedNotes = [];
  final int _maxNotes = 30; // Increased max notes

  // Example melodies
  final Map<String, List<String>> _exampleMelodies = {
    'twinkle': ['C', 'C', 'G', 'G', 'A', 'A', 'G', 'F', 'F', 'E', 'E', 'D', 'D', 'C'],
    'happy': ['C', 'C', 'D', 'E', 'D', 'C', 'E', 'D', 'D', 'C'],
  };

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  Future<void> _playNote(Map<String, dynamic> note) async {
    final noteLetter = note['letter'] as String;
    final instrumentId = _instruments[_selectedInstrument]['id'] as String;
    final pitchMod = _instruments[_selectedInstrument]['pitchMod'] as double;

    // Clean the note letter (C5 -> C, etc.)
    final cleanNote = noteLetter.replaceAll(RegExp(r'[0-9]'), '');

    // Play the note with the selected instrument
    await _audioService.playNote(
      cleanNote,
      instrument: instrumentId,
      pitchModifier: pitchMod,
    );
  }

  void _onNoteTap(int index) async {
    if (_isPlaying) return;

    final note = _notes[index];

    // Add to recorded sequence if not at max (store only essential data)
    if (_recordedNotes.length < _maxNotes) {
      setState(() {
        _recordedNotes.add({
          'letter': note['letter'],
          'color': note['color'],
          'pitch': note['pitch'],
        });
      });
    }

    // Play the note
    await _playNote(note);
  }

  Future<void> _playSequence() async {
    if (_recordedNotes.isEmpty || _isPlaying) return;

    setState(() {
      _isPlaying = true;
    });

    // Calculate delay based on tempo (BPM)
    // 60 BPM = 1 beat per second = 1000ms
    // delay = 60000 / BPM
    final delayMs = (60000 / _tempo).round();

    for (int i = 0; i < _recordedNotes.length; i++) {
      if (!_isPlaying) break; // Allow stopping

      await _playNote(_recordedNotes[i]);
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    setState(() {
      _isPlaying = false;
    });
  }

  void _clearSequence() {
    if (_isPlaying) return;

    setState(() {
      _recordedNotes.clear();
    });
  }

  void _removeLastNote() {
    if (_isPlaying || _recordedNotes.isEmpty) return;

    setState(() {
      _recordedNotes.removeLast();
    });
  }

  void _loadExampleMelody(String melodyKey) {
    if (_isPlaying) return;

    final melody = _exampleMelodies[melodyKey];
    if (melody == null) return;

    setState(() {
      _recordedNotes.clear();

      for (final noteLetter in melody) {
        // Find the note in our notes list
        final note = _notes.firstWhere(
          (n) => n['letter'] == noteLetter || n['letter'].toString().startsWith(noteLetter),
          orElse: () => _notes[0],
        );
        _recordedNotes.add({
          'letter': note['letter'],
          'color': note['color'],
          'pitch': note['pitch'],
        });
      }
    });
  }

  void _stopPlaying() {
    setState(() {
      _isPlaying = false;
    });
    _audioService.stop();
  }

  Widget _buildExampleButton(String melodyKey, String label) {
    return ElevatedButton(
      onPressed: _isPlaying ? null : () => _loadExampleMelody(melodyKey),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade100,
        foregroundColor: Colors.purple.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    _isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Stack(
                  children: [
                    // Centered title
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          _isHebrew ? 'יוצר מוזיקה 🎵' : 'Music Composer 🎵',
                          style: TextStyle(
                            fontSize: responsive.titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      right: _isHebrew ? 0 : null,
                      left: _isHebrew ? null : 0,
                      child: KidBackButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.purple.shade600,
                        isHebrew: _isHebrew,
                      ),
                    ),
                  ],
                ),
              ),

              // Instrument selector
              SizedBox(
                height: 65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                  itemCount: _instruments.length,
                  itemBuilder: (context, index) {
                    final instrument = _instruments[index];
                    final isSelected = _selectedInstrument == index;

                    return GestureDetector(
                      onTap: () {
                        if (!_isPlaying) {
                          setState(() {
                            _selectedInstrument = index;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.purple.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              instrument['icon'],
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isHebrew ? instrument['nameHe'] : instrument['nameEn'],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.purple.shade700,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: responsive.spacing(8)),

              // Tempo control
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Row(
                  children: [
                    Text(
                      _isHebrew ? 'מהירות: ${_tempo.round()} BPM' : 'Tempo: ${_tempo.round()} BPM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _tempo,
                        min: 60,
                        max: 180,
                        divisions: 12,
                        activeColor: Colors.purple,
                        inactiveColor: Colors.purple.shade100,
                        onChanged: _isPlaying
                            ? null
                            : (value) {
                                setState(() {
                                  _tempo = value;
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ),

              // Example melodies
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                  children: [
                    _buildExampleButton('twinkle', _isHebrew ? 'נצנץ נצנץ ⭐' : 'Twinkle ⭐'),
                    const SizedBox(width: 8),
                    _buildExampleButton('happy', _isHebrew ? 'שמח 😊' : 'Happy 😊'),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(8)),

              // Recorded sequence display
              Container(
                height: 78,
                margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isHebrew
                          ? 'המוזיקה שלך ($_recordedNotes.length/$_maxNotes)'
                          : 'Your Music ($_recordedNotes.length/$_maxNotes)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: _recordedNotes.isEmpty
                          ? Center(
                              child: Text(
                                _isHebrew
                                    ? 'לחץ על התווים כדי ליצור מוזיקה!'
                                    : 'Tap notes to create music!',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _recordedNotes.length,
                              itemBuilder: (context, index) {
                                final note = _recordedNotes[index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: note['color'],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      note['letter'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(16)),

              // Note buttons
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight;
                    final buttonHeight = (availableHeight * 0.7).clamp(60.0, 100.0);

                    return Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: List.generate(_notes.length, (index) {
                          final note = _notes[index];
                          return GestureDetector(
                            onTap: () => _onNoteTap(index),
                            child: Container(
                              width: 80,
                              height: buttonHeight,
                              decoration: BoxDecoration(
                                color: note['color'],
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: note['color'].withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    note['letter'],
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isHebrew ? note['nameHe'] : note['nameEn'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),

              // Control buttons
              Padding(
                padding: EdgeInsets.all(responsive.spacing(16)),
                child: Column(
                  children: [
                    // First row: Remove last and Clear
                    Row(
                      children: [
                        Expanded(
                          child: KidButton(
                            text: _isHebrew ? 'הסר אחרון ⬅️' : 'Remove Last ⬅️',
                            icon: Icons.backspace,
                            onPressed: _recordedNotes.isEmpty ? null : _removeLastNote,
                            color: Colors.orange.shade400,
                            height: 55,
                          ),
                        ),
                        SizedBox(width: responsive.spacing(8)),
                        Expanded(
                          child: KidButton(
                            text: _isHebrew ? 'נקה הכל 🗑️' : 'Clear All 🗑️',
                            icon: Icons.delete_forever,
                            onPressed: _recordedNotes.isEmpty ? null : _clearSequence,
                            color: Colors.red.shade400,
                            height: 55,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.spacing(8)),
                    // Second row: Play/Stop button (full width)
                    KidButton(
                      text: _isPlaying
                          ? (_isHebrew ? 'עצור ⏹️' : 'Stop ⏹️')
                          : (_isHebrew ? 'נגן ▶️' : 'Play ▶️'),
                      icon: _isPlaying ? Icons.stop : Icons.play_arrow,
                      onPressed: _recordedNotes.isEmpty
                          ? null
                          : (_isPlaying ? _stopPlaying : _playSequence),
                      color: _isPlaying ? Colors.orange : Colors.green,
                      height: 65,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
