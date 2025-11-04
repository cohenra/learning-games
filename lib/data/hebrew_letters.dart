import 'package:flutter/material.dart';

/// מייצג אות עברית יחידה
class HebrewLetter {
  final String letter; // האות עצמה: א, ב, ג...
  final String name; // השם המלא: אָלֶף, בֵּית, גִּימֶל
  final String key; // מפתח לקובץ סאונד: alef, bet, gimel
  final Color color; // צבע ייחודי לאות (לעיצוב)

  const HebrewLetter({
    required this.letter,
    required this.name,
    required this.key,
    required this.color,
  });
}

/// רשימת כל האותיות העבריות (22 אותיות + 5 סופיות)
class HebrewLettersData {
  // 22 אותיות רגילות
  static const List<HebrewLetter> regularLetters = [
    HebrewLetter(letter: 'א', name: 'אָלֶף', key: 'alef', color: Colors.red),
    HebrewLetter(letter: 'ב', name: 'בֵּית', key: 'bet', color: Colors.blue),
    HebrewLetter(letter: 'ג', name: 'גִּימֶל', key: 'gimel', color: Colors.green),
    HebrewLetter(letter: 'ד', name: 'דָּלֶת', key: 'dalet', color: Colors.orange),
    HebrewLetter(letter: 'ה', name: 'הֵא', key: 'hey', color: Colors.purple),
    HebrewLetter(letter: 'ו', name: 'וָו', key: 'vav', color: Colors.pink),
    HebrewLetter(letter: 'ז', name: 'זַיִן', key: 'zayin', color: Colors.teal),
    HebrewLetter(letter: 'ח', name: 'חֵית', key: 'chet', color: Colors.amber),
    HebrewLetter(letter: 'ט', name: 'טֵית', key: 'tet', color: Colors.cyan),
    HebrewLetter(letter: 'י', name: 'יוֹד', key: 'yod', color: Colors.lime),
    HebrewLetter(letter: 'כ', name: 'כַּף', key: 'kaf', color: Colors.indigo),
    HebrewLetter(letter: 'ל', name: 'לָמֶד', key: 'lamed', color: Colors.deepOrange),
    HebrewLetter(letter: 'מ', name: 'מֵם', key: 'mem', color: Colors.lightGreen),
    HebrewLetter(letter: 'נ', name: 'נוּן', key: 'nun', color: Colors.deepPurple),
    HebrewLetter(letter: 'ס', name: 'סָמֶךְ', key: 'samech', color: Colors.brown),
    HebrewLetter(letter: 'ע', name: 'עַיִן', key: 'ayin', color: Colors.blueGrey),
    HebrewLetter(letter: 'פ', name: 'פֵּא', key: 'pey', color: Colors.redAccent),
    HebrewLetter(letter: 'צ', name: 'צַדִּי', key: 'tzadi', color: Colors.lightBlue),
    HebrewLetter(letter: 'ק', name: 'קוֹף', key: 'kof', color: Colors.greenAccent),
    HebrewLetter(letter: 'ר', name: 'רֵישׁ', key: 'resh', color: Colors.orangeAccent),
    HebrewLetter(letter: 'ש', name: 'שִׁין', key: 'shin', color: Colors.purpleAccent),
    HebrewLetter(letter: 'ת', name: 'תָּו', key: 'tav', color: Colors.pinkAccent),
  ];

  // 5 אותיות סופיות (אופציונלי - לשלב מתקדם יותר)
  static const List<HebrewLetter> finalLetters = [
    HebrewLetter(letter: 'ך', name: 'כַּף סוֹפִית', key: 'kaf_sofit', color: Colors.indigo),
    HebrewLetter(letter: 'ם', name: 'מֵם סוֹפִית', key: 'mem_sofit', color: Colors.lightGreen),
    HebrewLetter(letter: 'ן', name: 'נוּן סוֹפִית', key: 'nun_sofit', color: Colors.deepPurple),
    HebrewLetter(letter: 'ף', name: 'פֵּא סוֹפִית', key: 'pey_sofit', color: Colors.redAccent),
    HebrewLetter(letter: 'ץ', name: 'צַדִּי סוֹפִית', key: 'tzadi_sofit', color: Colors.lightBlue),
  ];

  /// מחזיר את כל האותיות (רגילות + סופיות)
  static List<HebrewLetter> get allLetters => [...regularLetters, ...finalLetters];

  /// מחזיר רק את האותיות הרגילות (22 אותיות)
  static List<HebrewLetter> get basicLetters => regularLetters;

  /// מחזיר אות לפי מפתח
  static HebrewLetter? getByKey(String key) {
    try {
      return allLetters.firstWhere((l) => l.key == key);
    } catch (_) {
      return null;
    }
  }
}
