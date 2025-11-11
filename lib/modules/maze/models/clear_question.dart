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
    final letters = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח'];
    final lettersEn = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final random = Random();

    final targetLetter = letters[random.nextInt(letters.length)];
    final targetLetterEn = lettersEn[random.nextInt(lettersEn.length)];

    final wrongLetters =
        letters.where((l) => l != targetLetter).toList()..shuffle();
    final wrongLettersEn =
        lettersEn.where((l) => l != targetLetterEn).toList()..shuffle();

    final answers = [
      targetLetter,
      ...wrongLetters.take(3),
    ]..shuffle();

    final answersEn = [
      targetLetterEn,
      ...wrongLettersEn.take(3),
    ]..shuffle();

    return ClearQuestion(
      questionText: 'בחר את האות $targetLetter',
      questionTextEn: 'Choose the letter $targetLetterEn',
      spokenText: 'בחר את האות $targetLetter',
      spokenTextEn: 'Choose the letter $targetLetterEn',
      answers: answers,
      correctAnswer: targetLetter,
    );
  }

  static ClearQuestion _generateNumberQuestion() {
    final random = Random();
    final targetNumber = random.nextInt(10) + 1;

    final wrongNumbers = List.generate(10, (i) => i + 1)
        .where((n) => n != targetNumber)
        .toList()
      ..shuffle();

    final answers = [
      targetNumber.toString(),
      ...wrongNumbers.take(3).map((n) => n.toString()),
    ]..shuffle();

    return ClearQuestion(
      questionText: 'בחר את המספר $targetNumber',
      questionTextEn: 'Choose the number $targetNumber',
      spokenText: 'בחר את המספר $targetNumber',
      spokenTextEn: 'Choose the number $targetNumber',
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
