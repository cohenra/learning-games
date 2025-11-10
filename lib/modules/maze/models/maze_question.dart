import 'package:flutter/material.dart';

/// סוג שאלה
enum QuestionTopic {
  numbers,
  colors,
  letters,
  shapes,
}

/// שאלה במבוך
class MazeQuestion {
  final String id;
  final QuestionTopic topic;
  final String questionText;
  final String questionTextEn;
  final List<MazeAnswer> answers;
  final int correctAnswerIndex;
  final Widget? visualWidget; // עבור ויזואליזציה (נקודות, צבעים וכו')

  const MazeQuestion({
    required this.id,
    required this.topic,
    required this.questionText,
    required this.questionTextEn,
    required this.answers,
    required this.correctAnswerIndex,
    this.visualWidget,
  });

  MazeAnswer get correctAnswer => answers[correctAnswerIndex];

  /// יצירת שאלה אקראית לפי נושא
  static MazeQuestion generateRandom(QuestionTopic topic, {required bool isHebrew}) {
    switch (topic) {
      case QuestionTopic.numbers:
        return _generateNumberQuestion(isHebrew);
      case QuestionTopic.colors:
        return _generateColorQuestion(isHebrew);
      case QuestionTopic.letters:
        return _generateLetterQuestion(isHebrew);
      case QuestionTopic.shapes:
        return _generateShapeQuestion(isHebrew);
    }
  }

  static MazeQuestion _generateNumberQuestion(bool isHebrew) {
    final number = 1 + (DateTime.now().millisecondsSinceEpoch % 10);
    final answers = _generateNumberAnswers(number);

    return MazeQuestion(
      id: 'num_$number',
      topic: QuestionTopic.numbers,
      questionText: 'כמה נקודות?',
      questionTextEn: 'How many dots?',
      answers: answers,
      correctAnswerIndex: answers.indexWhere((a) => a.value == number.toString()),
    );
  }

  static MazeQuestion _generateColorQuestion(bool isHebrew) {
    final colors = ['אדום', 'כחול', 'ירוק', 'צהוב', 'סגול', 'כתום'];
    final colorsEn = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'];
    final colorValues = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange
    ];

    final index = DateTime.now().millisecondsSinceEpoch % colors.length;
    final answers = _generateColorAnswers(index, colors, colorsEn, colorValues);

    return MazeQuestion(
      id: 'color_$index',
      topic: QuestionTopic.colors,
      questionText: 'איזה צבע?',
      questionTextEn: 'Which color?',
      answers: answers,
      correctAnswerIndex: 0,
    );
  }

  static MazeQuestion _generateLetterQuestion(bool isHebrew) {
    if (isHebrew) {
      final letters = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח'];
      final index = DateTime.now().millisecondsSinceEpoch % letters.length;
      final answers = _generateLetterAnswers(index, letters);

      return MazeQuestion(
        id: 'letter_he_$index',
        topic: QuestionTopic.letters,
        questionText: 'איזו אות?',
        questionTextEn: 'Which letter?',
        answers: answers,
        correctAnswerIndex: 0,
      );
    } else {
      final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
      final index = DateTime.now().millisecondsSinceEpoch % letters.length;
      final answers = _generateLetterAnswers(index, letters);

      return MazeQuestion(
        id: 'letter_en_$index',
        topic: QuestionTopic.letters,
        questionText: 'איזו אות?',
        questionTextEn: 'Which letter?',
        answers: answers,
        correctAnswerIndex: 0,
      );
    }
  }

  static MazeQuestion _generateShapeQuestion(bool isHebrew) {
    final shapes = ['עיגול', 'ריבוע', 'משולש', 'כוכב', 'לב'];
    final shapesEn = ['Circle', 'Square', 'Triangle', 'Star', 'Heart'];
    final index = DateTime.now().millisecondsSinceEpoch % shapes.length;
    final answers = _generateShapeAnswers(index, shapes, shapesEn);

    return MazeQuestion(
      id: 'shape_$index',
      topic: QuestionTopic.shapes,
      questionText: 'איזו צורה?',
      questionTextEn: 'Which shape?',
      answers: answers,
      correctAnswerIndex: 0,
    );
  }

  static List<MazeAnswer> _generateNumberAnswers(int correct) {
    final answers = <MazeAnswer>[];
    answers.add(MazeAnswer(value: correct.toString(), displayText: correct.toString()));

    final used = {correct};
    while (answers.length < 4) {
      final num = 1 + (DateTime.now().millisecondsSinceEpoch + answers.length) % 10;
      if (!used.contains(num)) {
        answers.add(MazeAnswer(value: num.toString(), displayText: num.toString()));
        used.add(num);
      }
    }

    answers.shuffle();
    return answers;
  }

  static List<MazeAnswer> _generateColorAnswers(
    int correctIndex,
    List<String> colors,
    List<String> colorsEn,
    List<Color> colorValues,
  ) {
    final answers = <MazeAnswer>[];
    answers.add(MazeAnswer(
      value: correctIndex.toString(),
      displayText: colors[correctIndex],
      displayTextEn: colorsEn[correctIndex],
    ));

    final used = {correctIndex};
    while (answers.length < 4) {
      final idx = (DateTime.now().millisecondsSinceEpoch + answers.length) % colors.length;
      if (!used.contains(idx)) {
        answers.add(MazeAnswer(
          value: idx.toString(),
          displayText: colors[idx],
          displayTextEn: colorsEn[idx],
        ));
        used.add(idx);
      }
    }

    answers.shuffle();
    return answers;
  }

  static List<MazeAnswer> _generateLetterAnswers(int correctIndex, List<String> letters) {
    final answers = <MazeAnswer>[];
    answers.add(MazeAnswer(
      value: letters[correctIndex],
      displayText: letters[correctIndex],
    ));

    final used = {correctIndex};
    while (answers.length < 4) {
      final idx = (DateTime.now().millisecondsSinceEpoch + answers.length) % letters.length;
      if (!used.contains(idx)) {
        answers.add(MazeAnswer(
          value: letters[idx],
          displayText: letters[idx],
        ));
        used.add(idx);
      }
    }

    answers.shuffle();
    return answers;
  }

  static List<MazeAnswer> _generateShapeAnswers(
    int correctIndex,
    List<String> shapes,
    List<String> shapesEn,
  ) {
    final answers = <MazeAnswer>[];
    answers.add(MazeAnswer(
      value: correctIndex.toString(),
      displayText: shapes[correctIndex],
      displayTextEn: shapesEn[correctIndex],
    ));

    final used = {correctIndex};
    while (answers.length < 4) {
      final idx = (DateTime.now().millisecondsSinceEpoch + answers.length) % shapes.length;
      if (!used.contains(idx)) {
        answers.add(MazeAnswer(
          value: idx.toString(),
          displayText: shapes[idx],
          displayTextEn: shapesEn[idx],
        ));
        used.add(idx);
      }
    }

    answers.shuffle();
    return answers;
  }
}

/// תשובה לשאלה
class MazeAnswer {
  final String value;
  final String displayText;
  final String? displayTextEn;

  const MazeAnswer({
    required this.value,
    required this.displayText,
    this.displayTextEn,
  });

  String getDisplayText(bool isHebrew) {
    if (isHebrew) {
      return displayText;
    } else {
      return displayTextEn ?? displayText;
    }
  }
}
