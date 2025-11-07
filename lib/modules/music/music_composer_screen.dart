import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
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

  // List of notes with their properties
  final List<Map<String, dynamic>> _notes = [
    {'nameHe': 'דו', 'nameEn': 'Do', 'letter': 'C', 'color': Colors.red, 'pitch': 0.7},
    {'nameHe': 'רה', 'nameEn': 'Re', 'letter': 'D', 'color': Colors.orange, 'pitch': 0.8},
    {'nameHe': 'מי', 'nameEn': 'Mi', 'letter': 'E', 'color': Colors.yellow.shade700, 'pitch': 0.9},
    {'nameHe': 'פה', 'nameEn': 'Fa', 'letter': 'F', 'color': Colors.green, 'pitch': 1.0},
    {'nameHe': 'סול', 'nameEn': 'Sol', 'letter': 'G', 'color': Colors.blue, 'pitch': 1.2},
    {'nameHe': 'לה', 'nameEn': 'La', 'letter': 'A', 'color': Colors.purple, 'pitch': 1.4},
    {'nameHe': 'סי', 'nameEn': 'Si', 'letter': 'B', 'color': Colors.pink, 'pitch': 1.6},
  ];

  // Available instruments
  final List<Map<String, dynamic>> _instruments = [
    {'nameHe': 'פסנתר', 'nameEn': 'Piano', 'icon': '🎹', 'id': 'piano'},
    {'nameHe': 'גיטרה', 'nameEn': 'Guitar', 'icon': '🎸', 'id': 'guitar'},
    {'nameHe': 'חליל', 'nameEn': 'Flute', 'icon': '🎶', 'id': 'flute'},
    {'nameHe': 'תוף', 'nameEn': 'Drum', 'icon': '🥁', 'id': 'drum'},
  ];

  int _selectedInstrument = 0;
  List<Map<String, dynamic>> _recordedNotes = [];
  final int _maxNotes = 20;

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
    final instrument = _instruments[_selectedInstrument]['id'];
    final noteLetter = note['letter'] as String;

    // Play the note with the selected instrument
    await _audioService.playNote(noteLetter, instrument: instrument);
  }

  void _onNoteTap(int index) async {
    if (_isPlaying) return;

    final note = _notes[index];

    // Add to recorded sequence if not at max
    if (_recordedNotes.length < _maxNotes) {
      setState(() {
        _recordedNotes.add({...note});
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

    final instrument = _instruments[_selectedInstrument]['id'];

    for (int i = 0; i < _recordedNotes.length; i++) {
      if (!_isPlaying) break; // Allow stopping

      await _playNote(_recordedNotes[i]);
      await Future.delayed(const Duration(milliseconds: 400));
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

  void _stopPlaying() {
    setState(() {
      _isPlaying = false;
    });
    _audioService.stop();
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
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.purple.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isHebrew ? 'יוצר מוזיקה' : 'Music Composer',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Instrument selector
              SizedBox(
                height: 70,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.purple.shade300,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              instrument['icon'],
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isHebrew ? instrument['nameHe'] : instrument['nameEn'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: responsive.spacing(12)),

              // Recorded sequence display
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isHebrew
                          ? 'המוזיקה שלך ($_recordedNotes.length/$_maxNotes)'
                          : 'Your Music ($_recordedNotes.length/$_maxNotes)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _recordedNotes.isEmpty
                          ? Center(
                              child: Text(
                                _isHebrew
                                    ? 'לחץ על התווים כדי ליצור מוזיקה!'
                                    : 'Tap notes to create music!',
                                style: TextStyle(
                                  fontSize: 12,
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
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: note['color'],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      note['letter'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Clear button
                    Expanded(
                      child: KidButton(
                        text: _isHebrew ? 'נקה 🗑️' : 'Clear 🗑️',
                        icon: Icons.delete,
                        onPressed: _recordedNotes.isEmpty ? null : _clearSequence,
                        color: Colors.red.shade400,
                        height: 60,
                      ),
                    ),
                    SizedBox(width: responsive.spacing(12)),
                    // Play/Stop button
                    Expanded(
                      child: KidButton(
                        text: _isPlaying
                            ? (_isHebrew ? 'עצור ⏹️' : 'Stop ⏹️')
                            : (_isHebrew ? 'נגן ▶️' : 'Play ▶️'),
                        icon: _isPlaying ? Icons.stop : Icons.play_arrow,
                        onPressed: _recordedNotes.isEmpty
                            ? null
                            : (_isPlaying ? _stopPlaying : _playSequence),
                        color: _isPlaying ? Colors.orange : Colors.green,
                        height: 60,
                      ),
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
