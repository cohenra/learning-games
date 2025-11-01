import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  int _coins = 0;
  int get coins => _coins;

  ProgressProvider() {
    _load();
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    notifyListeners();
  }

  void addCoins(int amount) async {
    _coins += amount;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('coins', _coins);
  }
}
