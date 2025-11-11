import 'dart:math';

/// שאלה ברורה עם הנחיה ספציפית
class ClearQuestion {
  final String questionText; // עברית
  final String questionTextEn; // אנגלית
  final String spokenText; // מה להגיד ב-TTS
  final String spokenTextEn; // מה להגיד ב-TTS באנגלית
  final List<String> answers;
  final String correctAnswer;

  ClearQuestion({
    required this.questionText,
    required this.questionTextEn,
    required this.spokenText,
    required this.spokenTextEn,
    required this.answers,
    required this.correctAnswer,
  });

  /// יצירת שאלה אקראית ברורה
  static ClearQuestion generate({bool isHebrew = true}) {
    final random = Random();
    final type = random.nextInt(4);

    switch (type) {
      case 0:
        return _generateLetterQuestion();
      case 1:
        return _generateNumberQuestion();
      case 2:
        return _generateColorQuestion();
      case 3:
      default:
        return _generateMathQuestion();
    }
  }

  static ClearQuestion _generateLetterQuestion() {
    final letterNames = {
      'א': 'אלף',
      'ב': 'בית',
      'ג': 'גימל',
      'ד': 'דלת',
      'ה': 'הא',
      'ו': 'ואו',
      'ז': 'זיין',
      'ח': 'חית',
    };

    final lettersEn = {
      'A': 'A',
      'B': 'B',
      'C': 'C',
      'D': 'D',
      'E': 'E',
      'F': 'F',
      'G': 'G',
      'H': 'H',
    };

    final random = Random();
    final letters = letterNames.keys.toList();
    final targetLetter = letters[random.nextInt(letters.length)];
    final targetLetterName = letterNames[targetLetter]!;

    final lettersEnList = lettersEn.keys.toList();
    final targetLetterEn = lettersEnList[random.nextInt(lettersEnList.length)];

    final wrongLetters =
        letters.where((l) => l != targetLetter).toList()..shuffle();
    final wrongLettersEn =
        lettersEnList.where((l) => l != targetLetterEn).toList()..shuffle();

    final answers = [
      targetLetter,
      ...wrongLetters.take(3),
    ]..shuffle();

    return ClearQuestion(
      questionText: 'בחר את האות $targetLetterName',
      questionTextEn: 'Choose the letter $targetLetterEn',
      spokenText: 'בחר את האות $targetLetterName',
      spokenTextEn: 'Choose the letter $targetLetterEn',
      answers: answers,
      correctAnswer: targetLetter,
    );
  }

  static ClearQuestion _generateNumberQuestion() {
    final numberWords = {
      1: 'אחת',
      2: 'שתיים',
      3: 'שלוש',
      4: 'ארבע',
      5: 'חמש',
      6: 'שש',
      7: 'שבע',
      8: 'שמונה',
      9: 'תשע',
      10: 'עשר',
    };

    final numberWordsEn = {
      1: 'One',
      2: 'Two',
      3: 'Three',
      4: 'Four',
      5: 'Five',
      6: 'Six',
      7: 'Seven',
      8: 'Eight',
      9: 'Nine',
      10: 'Ten',
    };

    final random = Random();
    final targetNumber = random.nextInt(10) + 1;
    final targetWord = numberWords[targetNumber]!;
    final targetWordEn = numberWordsEn[targetNumber]!;

    final wrongNumbers = List.generate(10, (i) => i + 1)
        .where((n) => n != targetNumber)
        .toList()
      ..shuffle();

    final answers = [
      targetNumber.toString(),
      ...wrongNumbers.take(3).map((n) => n.toString()),
    ]..shuffle();

    return ClearQuestion(
      questionText: 'בחר את המספר $targetWord',
      questionTextEn: 'Choose the number $targetWordEn',
      spokenText: 'בחר את המספר $targetWord',
      spokenTextEn: 'Choose the number $targetWordEn',
      answers: answers,
      correctAnswer: targetNumber.toString(),
    );
  }

  static ClearQuestion _generateColorQuestion() {
    final colors = {
      'אדום': 'Red',
      'כחול': 'Blue',
      'ירוק': 'Green',
      'צהוב': 'Yellow',
      'כתום': 'Orange',
      'סגול': 'Purple',
    };

    final random = Random();
    final colorsList = colors.keys.toList();
    final targetColor = colorsList[random.nextInt(colorsList.length)];
    final targetColorEn = colors[targetColor]!;

    final wrongColors =
        colorsList.where((c) => c != targetColor).toList()..shuffle();
    final wrongColorsEn = wrongColors.map((c) => colors[c]!).toList();

    final answers = [
      targetColor,
      ...wrongColors.take(3),
    ]..shuffle();

    return ClearQuestion(
      questionText: 'בחר את הצבע $targetColor',
      questionTextEn: 'Choose the color $targetColorEn',
      spokenText: 'בחר את הצבע $targetColor',
      spokenTextEn: 'Choose the color $targetColorEn',
      answers: answers,
      correctAnswer: targetColor,
    );
  }

  static ClearQuestion _generateMathQuestion() {
    final random = Random();
    final num1 = random.nextInt(5) + 1;
    final num2 = random.nextInt(5) + 1;
    final correctAnswer = num1 + num2;

    final wrongAnswers = List.generate(15, (i) => i + 1)
        .where((n) => n != correctAnswer)
        .toList()
      ..shuffle();

    final answers = [
      correctAnswer.toString(),
      ...wrongAnswers.take(3).map((n) => n.toString()),
    ]..shuffle();

    return ClearQuestion(
      questionText: 'כמה זה $num1 + $num2?',
      questionTextEn: 'What is $num1 + $num2?',
      spokenText: 'כמה זה $num1 ועוד $num2?',
      spokenTextEn: 'What is $num1 plus $num2?',
      answers: answers,
      correctAnswer: correctAnswer.toString(),
    );
  }
}
