import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../core/utils/calorie_calculator.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isOnboarded = false;
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  bool get isOnboarded => _isOnboarded;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool('is_onboarded') ?? false;
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      _profile = UserProfile.fromMap(jsonDecode(profileJson));
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createProfile({
    required String name,
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) async {
    final bmr = CalorieCalculator.calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    final tdee = CalorieCalculator.calculateTDEE(bmr: bmr, activityLevel: activityLevel);
    final targetCalories = CalorieCalculator.adjustCaloriesForGoal(tdee, goal);
    final macros = CalorieCalculator.calculateMacros(calories: targetCalories, goal: goal);

    _profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
      targetCalories: targetCalories.roundToDouble(),
      targetProtein: macros['protein']!,
      targetCarbs: macros['carbs']!,
      targetFat: macros['fat']!,
    );

    _isOnboarded = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);
    await prefs.setString('user_profile', jsonEncode(_profile!.toMap()));
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(_profile!.toMap()));
    notifyListeners();
  }

  Future<void> resetProfile() async {
    _profile = null;
    _isOnboarded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
