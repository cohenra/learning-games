import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../utils/responsive_helper.dart';

/// מסך שירי ילדים
class KidsSongsScreen extends StatefulWidget {
  const KidsSongsScreen({super.key});

  @override
  State<KidsSongsScreen> createState() => _KidsSongsScreenState();
}

class _KidsSongsScreenState extends State<KidsSongsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isHebrew = true;
  bool _isPlaying = false;
  int? _playingIndex;

  final List<Map<String, String>> _songs = [
    {
      'titleHe': 'יש לי בובה',
      'titleEn': 'I Have a Doll',
      'emoji': '👶',
      'lyricsHe': 'יש לי בובה, יש לי בובה, בובה קטנה ויפה. היא לא מדברת, היא לא צועקת, רק בוכה ואומרת: אמא!',
      'lyricsEn': 'I have a doll, I have a doll, a small and pretty doll. She doesn\'t talk, she doesn\'t shout, she only cries and says: Mama!',
    },
    {
      'titleHe': 'הבה נגילה',
      'titleEn': 'Hava Nagila',
      'emoji': '🎉',
      'lyricsHe': 'הבה נגילה, הבה נגילה, הבה נגילה ונשמחה! עורו אחים, עורו אחים בלב שמח!',
      'lyricsEn': 'Hava nagila, hava nagila, hava nagila ve nismeha! Uru achim, uru achim be lev sameach!',
    },
    {
      'titleHe': 'שלום חברים',
      'titleEn': 'Hello Friends',
      'emoji': '👋',
      'lyricsHe': 'שלום חברים, שלום חברים, שלום שלום! להתראות חברים, להתראות חברים, להתראות להתראות!',
      'lyricsEn': 'Hello friends, hello friends, hello hello! Goodbye friends, goodbye friends, goodbye goodbye!',
    },
    {
      'titleHe': 'עוגת שוקולד',
      'titleEn': 'Chocolate Cake',
      'emoji': '🎂',
      'lyricsHe': 'עוגת שוקולד, גדולה וחומה, איך היא נעשית? כך נעשית עוגה!',
      'lyricsEn': 'Chocolate cake, big and brown, how is it made? This is how a cake is made!',
    },
    {
      'titleHe': 'Twinkle Twinkle',
      'titleEn': 'Twinkle Twinkle Little Star',
      'emoji': '⭐',
      'lyricsHe': 'Twinkle twinkle little star, how I wonder what you are. Up above the world so high, like a diamond in the sky.',
      'lyricsEn': 'Twinkle twinkle little star, how I wonder what you are. Up above the world so high, like a diamond in the sky.',
    },
    {
      'titleHe': 'Old MacDonald',
      'titleEn': 'Old MacDonald Had a Farm',
      'emoji': '🚜',
      'lyricsHe': 'Old MacDonald had a farm, E-I-E-I-O! And on that farm he had a cow, E-I-E-I-O! With a moo moo here and a moo moo there!',
      'lyricsEn': 'Old MacDonald had a farm, E-I-E-I-O! And on that farm he had a cow, E-I-E-I-O! With a moo moo here and a moo moo there!',
    },
    {
      'titleHe': 'Wheels on the Bus',
      'titleEn': 'The Wheels on the Bus',
      'emoji': '🚌',
      'lyricsHe': 'The wheels on the bus go round and round, round and round, round and round. The wheels on the bus go round and round, all through the town!',
      'lyricsEn': 'The wheels on the bus go round and round, round and round, round and round. The wheels on the bus go round and round, all through the town!',
    },
    {
      'titleHe': 'Head Shoulders',
      'titleEn': 'Head Shoulders Knees and Toes',
      'emoji': '👤',
      'lyricsHe': 'Head, shoulders, knees and toes, knees and toes! Head, shoulders, knees and toes, knees and toes! Eyes and ears and mouth and nose!',
      'lyricsEn': 'Head, shoulders, knees and toes, knees and toes! Head, shoulders, knees and toes, knees and toes! Eyes and ears and mouth and nose!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.1);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
      });
    });
  }

  Future<void> _playSong(int index) async {
    if (_isPlaying && _playingIndex == index) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
      });
      return;
    }

    await _flutterTts.stop();

    final song = _songs[index];
    final lyrics = _isHebrew ? song['lyricsHe']! : song['lyricsEn']!;
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    setState(() {
      _isPlaying = true;
      _playingIndex = index;
    });

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(lyrics);
  }

  @override
  void dispose() {
    _flutterTts.stop();
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
              Colors.pink.shade50,
              Colors.purple.shade50,
              Colors.blue.shade50,
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
                        color: Colors.pink.shade700,
                        size: 32,
                      ),
                      onPressed: () {
                        _flutterTts.stop();
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        _isHebrew ? 'שירי ילדים' : 'Kids Songs',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(10)),

              // Subtitle
              Text(
                _isHebrew ? 'בחר שיר לשמיעה' : 'Choose a song to listen',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  color: Colors.grey.shade700,
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // Songs list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(16),
                    vertical: responsive.spacing(8),
                  ),
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    final isPlaying = _isPlaying && _playingIndex == index;

                    return Padding(
                      padding: EdgeInsets.only(bottom: responsive.spacing(12)),
                      child: GestureDetector(
                        onTap: () => _playSong(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.all(responsive.spacing(16)),
                          decoration: BoxDecoration(
                            color: isPlaying ? Colors.pink.shade100 : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPlaying ? Colors.pink : Colors.pink.shade200,
                              width: isPlaying ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.2),
                                blurRadius: isPlaying ? 15 : 10,
                                offset: Offset(0, isPlaying ? 6 : 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Emoji
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    song['emoji']!,
                                    style: TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),

                              SizedBox(width: responsive.spacing(16)),

                              // Title and subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isHebrew ? song['titleHe']! : song['titleEn']!,
                                      style: TextStyle(
                                        fontSize: responsive.fontSize(20),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      isPlaying
                                          ? (_isHebrew ? 'מנגן...' : 'Playing...')
                                          : (_isHebrew ? 'לחץ לשמיעה' : 'Tap to play'),
                                      style: TextStyle(
                                        fontSize: responsive.fontSize(14),
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Play/Stop icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isPlaying ? Colors.pink : Colors.pink.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying ? Icons.stop : Icons.play_arrow,
                                  color: isPlaying ? Colors.white : Colors.pink,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: responsive.spacing(12)),
            ],
          ),
        ),
      ),
    );
  }
}
