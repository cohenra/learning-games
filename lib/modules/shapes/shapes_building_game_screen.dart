import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק בניית צורות - פשוט ובעל הגיון
class ShapesBuildingGameScreen extends StatefulWidget {
  const ShapesBuildingGameScreen({super.key});

  @override
  State<ShapesBuildingGameScreen> createState() => _ShapesBuildingGameScreenState();
}

class _ShapesBuildingGameScreenState extends State<ShapesBuildingGameScreen>
    with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  bool _isHebrew = true;

  // Game state
  int _difficultyLevel = 1; // 1=Easy, 2=Medium, 3=Hard
  bool _gameStarted = false;
  int _score = 0;
  int _currentPatternIndex = 0;
  List<ShapeSlotModel> _slots = [];
  List<DraggableShapeModel> _availableShapes = [];

  // Animation
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame(int difficulty) {
    setState(() {
      _difficultyLevel = difficulty;
      _gameStarted = true;
      _score = 0;
      _currentPatternIndex = 0;
      _generateLevel();
    });
  }

  void _generateLevel() {
    if (_difficultyLevel == 1) {
      _buildEasyPattern(_currentPatternIndex);
    } else if (_difficultyLevel == 2) {
      _buildMediumPattern(_currentPatternIndex);
    } else {
      _buildHardPattern(_currentPatternIndex);
    }
  }

  void _buildEasyPattern(int patternIndex) {
    switch (patternIndex) {
      case 0:
        // Pattern 0: House (existing)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.5, 0.25),
            size: 112,
            color: Colors.red.shade500,
            label: _isHebrew ? 'גג משולש' : 'Triangle Roof',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.square,
            position: const Offset(0.5, 0.55),
            size: 132,
            color: Colors.orange.shade300,
            label: _isHebrew ? 'גוף הבית' : 'House Body',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.square,
            position: const Offset(0.35, 0.5),
            size: 55,
            color: Colors.lightBlue.shade300,
            label: _isHebrew ? 'חלון' : 'Window',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.65, 0.65),
            size: 80,
            color: Colors.brown.shade300,
            label: _isHebrew ? 'דלת' : 'Door',
          ),
        ];
        break;

      case 1:
        // Pattern 1: Flower (circle center + triangle petals + rectangle stem)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.5, 0.35),
            size: 98,
            color: Colors.pink.shade400,
            label: _isHebrew ? 'מרכז הפרח' : 'Flower Center',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.35, 0.28),
            size: 75,
            color: Colors.purple.shade300,
            label: _isHebrew ? 'עלה כותרת' : 'Petal',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.65, 0.28),
            size: 75,
            color: Colors.purple.shade300,
            label: _isHebrew ? 'עלה כותרת' : 'Petal',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.5, 0.65),
            size: 88,
            color: Colors.green.shade600,
            label: _isHebrew ? 'גבעול' : 'Stem',
          ),
        ];
        break;

      case 2:
        // Pattern 2: Robot (square head + rectangle body + circle eyes)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.square,
            position: const Offset(0.5, 0.3),
            size: 108,
            color: Colors.grey.shade400,
            label: _isHebrew ? 'ראש הרובוט' : 'Robot Head',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.42, 0.28),
            size: 55,
            color: Colors.blue.shade600,
            label: _isHebrew ? 'עין שמאלית' : 'Left Eye',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.58, 0.28),
            size: 55,
            color: Colors.blue.shade600,
            label: _isHebrew ? 'עין ימנית' : 'Right Eye',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.5, 0.6),
            size: 112,
            color: Colors.grey.shade600,
            label: _isHebrew ? 'גוף הרובוט' : 'Robot Body',
          ),
        ];
        break;

      case 3:
        // Pattern 3: Sun (circle + triangle rays)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.5, 0.4),
            size: 112,
            color: Colors.yellow.shade600,
            label: _isHebrew ? 'שמש' : 'Sun',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.5, 0.2),
            size: 70,
            color: Colors.orange.shade500,
            label: _isHebrew ? 'קרן עליונה' : 'Top Ray',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.3, 0.4),
            size: 70,
            color: Colors.orange.shade500,
            label: _isHebrew ? 'קרן שמאלית' : 'Left Ray',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.7, 0.4),
            size: 70,
            color: Colors.orange.shade500,
            label: _isHebrew ? 'קרן ימנית' : 'Right Ray',
          ),
        ];
        break;

      case 4:
        // Pattern 4: Tree (triangle leaves + rectangle trunk + circle fruits)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.5, 0.3),
            size: 112,
            color: Colors.green.shade700,
            label: _isHebrew ? 'עלווה' : 'Leaves',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.5, 0.65),
            size: 85,
            color: Colors.brown.shade600,
            label: _isHebrew ? 'גזע' : 'Trunk',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.4, 0.35),
            size: 55,
            color: Colors.red.shade600,
            label: _isHebrew ? 'פרי' : 'Fruit',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.6, 0.35),
            size: 55,
            color: Colors.red.shade600,
            label: _isHebrew ? 'פרי' : 'Fruit',
          ),
        ];
        break;

      default:
        _slots = [];
    }

    _availableShapes = _slots.map((slot) {
      return DraggableShapeModel(
        shapeType: slot.shapeType,
        size: slot.size,
        color: slot.color,
      );
    }).toList();

    _availableShapes.shuffle(Random());
    setState(() {});
  }

  void _buildMediumPattern(int patternIndex) {
    switch (patternIndex) {
      case 0:
        // Pattern 0: Car (existing)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.5, 0.5),
            size: 152,
            color: Colors.blue.shade400,
            label: _isHebrew ? 'גוף הרכב' : 'Car Body',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.35, 0.7),
            size: 70,
            color: Colors.black87,
            label: _isHebrew ? 'גלגל שמאלי' : 'Left Wheel',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.65, 0.7),
            size: 70,
            color: Colors.black87,
            label: _isHebrew ? 'גלגל ימני' : 'Right Wheel',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.square,
            position: const Offset(0.4, 0.45),
            size: 60,
            color: Colors.lightBlue.shade200,
            label: _isHebrew ? 'חלון' : 'Window',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.7, 0.5),
            size: 55,
            color: Colors.yellow.shade600,
            label: _isHebrew ? 'פנס' : 'Light',
          ),
        ];
        break;

      case 1:
        // Pattern 1: Boat (triangle sail + rectangle hull + circle porthole)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.5, 0.3),
            size: 112,
            color: Colors.white,
            label: _isHebrew ? 'מפרש' : 'Sail',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.5, 0.6),
            size: 142,
            color: Colors.brown.shade400,
            label: _isHebrew ? 'גוף הסירה' : 'Hull',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.45, 0.58),
            size: 55,
            color: Colors.lightBlue.shade600,
            label: _isHebrew ? 'חלון עגול' : 'Porthole',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.3, 0.75),
            size: 60,
            color: Colors.blue.shade300,
            label: _isHebrew ? 'גל מים' : 'Wave',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.7, 0.75),
            size: 60,
            color: Colors.blue.shade300,
            label: _isHebrew ? 'גל מים' : 'Wave',
          ),
        ];
        break;

      case 2:
        // Pattern 2: Cat face (circle head + 2 triangles ears + circle eyes + triangle nose)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.5, 0.45),
            size: 132,
            color: Colors.orange.shade400,
            label: _isHebrew ? 'ראש החתול' : 'Cat Head',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.35, 0.25),
            size: 75,
            color: Colors.orange.shade600,
            label: _isHebrew ? 'אוזן שמאלית' : 'Left Ear',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.65, 0.25),
            size: 75,
            color: Colors.orange.shade600,
            label: _isHebrew ? 'אוזן ימנית' : 'Right Ear',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.42, 0.4),
            size: 55,
            color: Colors.green.shade600,
            label: _isHebrew ? 'עין שמאלית' : 'Left Eye',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.58, 0.4),
            size: 55,
            color: Colors.green.shade600,
            label: _isHebrew ? 'עין ימנית' : 'Right Eye',
          ),
        ];
        break;

      case 3:
        // Pattern 3: Ice cream (triangle cone + circles scoops + star topping)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.5, 0.65),
            size: 108,
            color: Colors.brown.shade300,
            label: _isHebrew ? 'גביע' : 'Cone',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.5, 0.42),
            size: 88,
            color: Colors.pink.shade300,
            label: _isHebrew ? 'כדור גלידה תחתון' : 'Bottom Scoop',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.5, 0.28),
            size: 83,
            color: Colors.brown.shade100,
            label: _isHebrew ? 'כדור גלידה עליון' : 'Top Scoop',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.star,
            position: const Offset(0.5, 0.15),
            size: 60,
            color: Colors.yellow.shade600,
            label: _isHebrew ? 'כוכב' : 'Star Topping',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.5, 0.75),
            size: 70,
            color: Colors.brown.shade700,
            label: _isHebrew ? 'שוקולד' : 'Chocolate',
          ),
        ];
        break;

      case 4:
        // Pattern 4: Rocket (triangle top + rectangle body + 2 triangles fins + circle window)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.5, 0.2),
            size: 88,
            color: Colors.red.shade600,
            label: _isHebrew ? 'חרוט' : 'Nose Cone',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.5, 0.5),
            size: 122,
            color: Colors.grey.shade300,
            label: _isHebrew ? 'גוף הטיל' : 'Rocket Body',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.5, 0.45),
            size: 60,
            color: Colors.lightBlue.shade400,
            label: _isHebrew ? 'חלון' : 'Window',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.35, 0.7),
            size: 75,
            color: Colors.blue.shade600,
            label: _isHebrew ? 'סנפיר שמאלי' : 'Left Fin',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.65, 0.7),
            size: 75,
            color: Colors.blue.shade600,
            label: _isHebrew ? 'סנפיר ימני' : 'Right Fin',
          ),
        ];
        break;

      default:
        _slots = [];
    }

    _availableShapes = _slots.map((slot) {
      return DraggableShapeModel(
        shapeType: slot.shapeType,
        size: slot.size,
        color: slot.color,
      );
    }).toList();

    _availableShapes.shuffle(Random());
    setState(() {});
  }

  void _buildHardPattern(int patternIndex) {
    switch (patternIndex) {
      case 0:
        // Pattern 0: Tree scene (existing)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.4, 0.25),
            size: 88,
            color: Colors.green.shade600,
            label: _isHebrew ? 'עלווה עליונה' : 'Top Leaves',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.4, 0.38),
            size: 98,
            color: Colors.green.shade700,
            label: _isHebrew ? 'עלווה אמצעית' : 'Middle Leaves',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.4, 0.52),
            size: 108,
            color: Colors.green.shade800,
            label: _isHebrew ? 'עלווה תחתונה' : 'Bottom Leaves',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.4, 0.75),
            size: 85,
            color: Colors.brown.shade600,
            label: _isHebrew ? 'גזע' : 'Trunk',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.75, 0.2),
            size: 75,
            color: Colors.yellow.shade600,
            label: _isHebrew ? 'שמש' : 'Sun',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.star,
            position: const Offset(0.75, 0.45),
            size: 60,
            color: Colors.amber.shade400,
            label: _isHebrew ? 'כוכב' : 'Star',
          ),
        ];
        break;

      case 1:
        // Pattern 1: Castle (3 rectangles towers + 3 triangles roofs + square door + 2 circle windows)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.3, 0.5),
            size: 108,
            color: Colors.grey.shade400,
            label: _isHebrew ? 'מגדל שמאלי' : 'Left Tower',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.5, 0.55),
            size: 122,
            color: Colors.grey.shade500,
            label: _isHebrew ? 'מגדל אמצעי' : 'Middle Tower',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.7, 0.5),
            size: 108,
            color: Colors.grey.shade400,
            label: _isHebrew ? 'מגדל ימני' : 'Right Tower',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.3, 0.28),
            size: 85,
            color: Colors.red.shade700,
            label: _isHebrew ? 'גג שמאלי' : 'Left Roof',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.5, 0.3),
            size: 88,
            color: Colors.red.shade700,
            label: _isHebrew ? 'גג אמצעי' : 'Middle Roof',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.7, 0.28),
            size: 85,
            color: Colors.red.shade700,
            label: _isHebrew ? 'גג ימני' : 'Right Roof',
          ),
        ];
        break;

      case 2:
        // Pattern 2: Train (rectangles cars + circles wheels + square windows + triangle smoke)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.3, 0.45),
            size: 112,
            color: Colors.red.shade500,
            label: _isHebrew ? 'קרון קדמי' : 'Front Car',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.6, 0.45),
            size: 112,
            color: Colors.blue.shade500,
            label: _isHebrew ? 'קרון אחורי' : 'Back Car',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.25, 0.65),
            size: 60,
            color: Colors.black87,
            label: _isHebrew ? 'גלגל' : 'Wheel',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.35, 0.65),
            size: 60,
            color: Colors.black87,
            label: _isHebrew ? 'גלגל' : 'Wheel',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.55, 0.65),
            size: 60,
            color: Colors.black87,
            label: _isHebrew ? 'גלגל' : 'Wheel',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.65, 0.65),
            size: 60,
            color: Colors.black87,
            label: _isHebrew ? 'גלגל' : 'Wheel',
          ),
        ];
        break;

      case 3:
        // Pattern 3: Butterfly (circles body parts + triangles wings + star decoration)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.5, 0.4),
            size: 75,
            color: Colors.brown.shade600,
            label: _isHebrew ? 'ראש הפרפר' : 'Butterfly Head',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.5, 0.52),
            size: 85,
            color: Colors.brown.shade700,
            label: _isHebrew ? 'גוף הפרפר' : 'Butterfly Body',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.3, 0.4),
            size: 98,
            color: Colors.purple.shade400,
            label: _isHebrew ? 'כנף שמאלית עליונה' : 'Left Top Wing',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.7, 0.4),
            size: 98,
            color: Colors.purple.shade400,
            label: _isHebrew ? 'כנף ימנית עליונה' : 'Right Top Wing',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.3, 0.6),
            size: 88,
            color: Colors.pink.shade400,
            label: _isHebrew ? 'כנף שמאלית תחתונה' : 'Left Bottom Wing',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.7, 0.6),
            size: 88,
            color: Colors.pink.shade400,
            label: _isHebrew ? 'כנף ימנית תחתונה' : 'Right Bottom Wing',
          ),
        ];
        break;

      case 4:
        // Pattern 4: Beach scene (circle sun + triangle umbrella + rectangle towel + star starfish + circle ball)
        _slots = [
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.75, 0.25),
            size: 88,
            color: Colors.yellow.shade600,
            label: _isHebrew ? 'שמש' : 'Sun',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.triangle,
            position: const Offset(0.3, 0.35),
            size: 108,
            color: Colors.red.shade500,
            label: _isHebrew ? 'שמשיה' : 'Umbrella',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.rectangle,
            position: const Offset(0.6, 0.6),
            size: 112,
            color: Colors.blue.shade300,
            label: _isHebrew ? 'מגבת' : 'Towel',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.star,
            position: const Offset(0.3, 0.7),
            size: 75,
            color: Colors.orange.shade600,
            label: _isHebrew ? 'כוכב ים' : 'Starfish',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.circle,
            position: const Offset(0.7, 0.45),
            size: 80,
            color: Colors.red.shade400,
            label: _isHebrew ? 'כדור חוף' : 'Beach Ball',
          ),
          ShapeSlotModel(
            shapeType: ShapeType.square,
            position: const Offset(0.5, 0.75),
            size: 98,
            color: Colors.brown.shade300,
            label: _isHebrew ? 'חול' : 'Sand',
          ),
        ];
        break;

      default:
        _slots = [];
    }

    _availableShapes = _slots.map((slot) {
      return DraggableShapeModel(
        shapeType: slot.shapeType,
        size: slot.size,
        color: slot.color,
      );
    }).toList();

    _availableShapes.shuffle(Random());
    setState(() {});
  }

  void _checkDrop(DraggableShapeModel shape, ShapeSlotModel slot) {
    if (slot.isPlaced) return;

    final appProvider = context.read<AppProvider>();

    if (shape.shapeType == slot.shapeType) {
      // נכון!
      setState(() {
        slot.isPlaced = true;
        _availableShapes.remove(shape);
        _score += 10;
      });

      _animationController.forward(from: 0);
      appProvider.speak(_isHebrew ? 'כל הכבוד!' : 'Great job!');

      // בדיקה אם סיימנו
      if (_availableShapes.isEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _showCompletionDialog();
          }
        });
      }
    } else {
      // לא נכון
      appProvider.speak(_isHebrew ? 'נסה צורה אחרת' : 'Try another shape');
    }
  }

  void _showCompletionDialog() {
    final patternNumber = _currentPatternIndex + 1;
    final isLastPattern = _currentPatternIndex == 4;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isHebrew ? '🎉 מעולה! 🎉' : '🎉 Excellent! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isHebrew
                ? 'השלמת תבנית $patternNumber מתוך 5!'
                : 'Pattern $patternNumber/5 completed!',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              _isHebrew ? 'ניקוד: $_score' : 'Score: $_score',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _gameStarted = false;
              });
            },
            child: Text(_isHebrew ? 'חזרה לתפריט' : 'Back to Menu'),
          ),
          if (!isLastPattern)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentPatternIndex++;
                  _generateLevel();
                });
              },
              child: Text(_isHebrew ? 'תבנית הבאה' : 'Next Pattern'),
            ),
          if (isLastPattern)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _gameStarted = false;
                });
              },
              child: Text(_isHebrew ? 'סיימת! חזרה לתפריט' : 'Finished! Back to Menu'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isHebrew ? 'משחק בנייה 🏗️' : 'Building Game 🏗️'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.pink.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: _gameStarted ? _buildGameView(responsive) : _buildDifficultySelector(responsive),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(ResponsiveHelper responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isHebrew ? '🏗️ בחר רמת קושי 🏗️' : '🏗️ Choose Difficulty 🏗️',
            style: TextStyle(
              fontSize: responsive.fontSize(32),
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: responsive.spacing(40)),

          Padding(
            padding: responsive.safePadding,
            child: KidButton(
              text: _isHebrew ? 'קל - בנה בית 🏠' : 'Easy - Build a House 🏠',
              icon: Icons.home,
              onPressed: () => _startGame(1),
              color: Colors.green.shade400,
              width: responsive.width(80),
              height: responsive.buttonHeight,
            ),
          ),
          SizedBox(height: responsive.verticalSpacing),

          Padding(
            padding: responsive.safePadding,
            child: KidButton(
              text: _isHebrew ? 'בינוני - בנה רכב 🚗' : 'Medium - Build a Car 🚗',
              icon: Icons.directions_car,
              onPressed: () => _startGame(2),
              color: Colors.orange.shade400,
              width: responsive.width(80),
              height: responsive.buttonHeight,
            ),
          ),
          SizedBox(height: responsive.verticalSpacing),

          Padding(
            padding: responsive.safePadding,
            child: KidButton(
              text: _isHebrew ? 'קשה - בנה עץ 🌳' : 'Hard - Build a Tree 🌳',
              icon: Icons.park,
              onPressed: () => _startGame(3),
              color: Colors.red.shade400,
              width: responsive.width(80),
              height: responsive.buttonHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(ResponsiveHelper responsive) {
    return Column(
      children: [
        // Score panel
        _buildScorePanel(),
        const SizedBox(height: 12),

        // Building area
        Expanded(
          child: _buildBuildingArea(),
        ),

        // Available shapes
        _buildShapesArea(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildScorePanel() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            '$_score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            _isHebrew ? 'נותרו: ${_availableShapes.length}' : 'Remaining: ${_availableShapes.length}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade300, width: 3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: _slots.map((slot) {
              return _buildSlot(slot, constraints);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildSlot(ShapeSlotModel slot, BoxConstraints constraints) {
    // Increase the hit area by adding padding around the shape
    final hitAreaPadding = slot.size * 0.5; // 50% padding makes it much easier to drop
    final hitAreaSize = slot.size + hitAreaPadding;

    final left = slot.position.dx * constraints.maxWidth - (hitAreaSize / 2);
    final top = slot.position.dy * constraints.maxHeight - (hitAreaSize / 2);

    return Positioned(
      left: left,
      top: top,
      child: DragTarget<DraggableShapeModel>(
        onWillAccept: (shape) => shape != null && !slot.isPlaced,
        onAccept: (shape) => _checkDrop(shape, slot),
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          return Container(
            width: hitAreaSize,
            height: hitAreaSize,
            // Center the actual shape within the larger hit area
            alignment: Alignment.center,
            child: Container(
              width: slot.size,
              height: slot.size,
              child: slot.isPlaced
                  ? _buildShapeWidget(slot.shapeType, slot.size, slot.color, opacity: 1.0)
                  : _buildShapeWidget(
                      slot.shapeType,
                      slot.size,
                      slot.color,
                      opacity: isHovering ? 0.5 : 0.2,
                      showBorder: true,
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShapesArea() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
      child: _availableShapes.isEmpty
          ? Center(
              child: Text(
                '✨',
                style: TextStyle(fontSize: 48),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _availableShapes.map((shape) {
                return _buildDraggableShape(shape);
              }).toList(),
            ),
    );
  }

  Widget _buildDraggableShape(DraggableShapeModel shape) {
    // Add padding around the shape to make it easier to grab
    final paddedSize = shape.size + 20; // Add 20px padding on each side

    return Container(
      width: paddedSize,
      height: paddedSize,
      child: Draggable<DraggableShapeModel>(
        data: shape,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.2,
            child: _buildShapeWidget(shape.shapeType, shape.size, shape.color),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: Center(
            child: _buildShapeWidget(shape.shapeType, shape.size, shape.color),
          ),
        ),
        child: Center(
          child: _buildShapeWidget(shape.shapeType, shape.size, shape.color),
        ),
      ),
    );
  }

  Widget _buildShapeWidget(ShapeType type, double size, Color color, {double opacity = 1.0, bool showBorder = false}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ShapePainter(
          shapeType: type,
          color: color.withOpacity(opacity),
          showBorder: showBorder,
        ),
      ),
    );
  }
}

// Models
enum ShapeType { circle, square, triangle, rectangle, star }

class ShapeSlotModel {
  final ShapeType shapeType;
  final Offset position;
  final double size;
  final Color color;
  final String label;
  bool isPlaced;

  ShapeSlotModel({
    required this.shapeType,
    required this.position,
    required this.size,
    required this.color,
    required this.label,
    this.isPlaced = false,
  });
}

class DraggableShapeModel {
  final ShapeType shapeType;
  final double size;
  final Color color;

  DraggableShapeModel({
    required this.shapeType,
    required this.size,
    required this.color,
  });
}

// Custom Painter
class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color color;
  final bool showBorder;

  ShapePainter({
    required this.shapeType,
    required this.color,
    this.showBorder = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (shapeType) {
      case ShapeType.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width / 2;
        canvas.drawCircle(center, radius, paint);
        if (showBorder) {
          canvas.drawCircle(center, radius, borderPaint);
        }
        break;

      case ShapeType.square:
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawRect(rect, paint);
        if (showBorder) {
          canvas.drawRect(rect, borderPaint);
        }
        break;

      case ShapeType.triangle:
        final path = Path();
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        canvas.drawPath(path, paint);
        if (showBorder) {
          canvas.drawPath(path, borderPaint);
        }
        break;

      case ShapeType.rectangle:
        final rect = Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.25,
          size.width * 0.8,
          size.height * 0.5,
        );
        canvas.drawRect(rect, paint);
        if (showBorder) {
          canvas.drawRect(rect, borderPaint);
        }
        break;

      case ShapeType.star:
        _drawStar(canvas, size, paint);
        if (showBorder) {
          _drawStar(canvas, size, borderPaint);
        }
        break;
    }
  }

  void _drawStar(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2.5;

    for (int i = 0; i < 10; i++) {
      final angle = (i * pi / 5) - pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
