import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../data/mock_meals.dart';

class NutritionProvider extends ChangeNotifier {
  final List<LoggedMeal> _loggedMeals = [];
  String _selectedDate = _todayKey();

  List<LoggedMeal> get loggedMeals =>
      _loggedMeals.where((m) => _dateKey(m.loggedAt) == _selectedDate).toList();

  double get consumedCalories =>
      loggedMeals.fold(0, (sum, m) => sum + m.calories);
  double get consumedProtein =>
      loggedMeals.fold(0, (sum, m) => sum + m.protein);
  double get consumedCarbs =>
      loggedMeals.fold(0, (sum, m) => sum + m.carbs);
  double get consumedFat =>
      loggedMeals.fold(0, (sum, m) => sum + m.fat);

  double remainingCalories(double target) =>
      (target - consumedCalories).clamp(0, double.infinity);
  double remainingProtein(double target) =>
      (target - consumedProtein).clamp(0, double.infinity);
  double remainingCarbs(double target) =>
      (target - consumedCarbs).clamp(0, double.infinity);
  double remainingFat(double target) =>
      (target - consumedFat).clamp(0, double.infinity);

  double caloriesProgress(double target) =>
      target > 0 ? (consumedCalories / target).clamp(0, 1) : 0;
  double proteinProgress(double target) =>
      target > 0 ? (consumedProtein / target).clamp(0, 1) : 0;
  double carbsProgress(double target) =>
      target > 0 ? (consumedCarbs / target).clamp(0, 1) : 0;
  double fatProgress(double target) =>
      target > 0 ? (consumedFat / target).clamp(0, 1) : 0;

  List<LoggedMeal> getMealsByType(String type) =>
      loggedMeals.where((m) => m.mealType == type).toList();

  List<Meal> getRecommendedMeals({
    required String mealType,
    required double targetCalories,
    required double targetProtein,
    required double targetFat,
    required String goal,
  }) {
    return getRecommendedMeals(
      mealType: mealType,
      remainingCalories: remainingCalories(targetCalories),
      remainingProtein: remainingProtein(targetProtein),
      remainingFat: remainingFat(targetFat),
      goal: goal,
    );
  }

  void logMeal(Meal meal, String mealType, {double portion = 1.0}) {
    final logged = LoggedMeal(
      id: '${meal.id}_${DateTime.now().millisecondsSinceEpoch}',
      meal: meal,
      loggedAt: DateTime.now(),
      mealType: mealType,
      portionMultiplier: portion,
    );
    _loggedMeals.add(logged);
    notifyListeners();
  }

  void logCustomFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String mealType,
  }) {
    final meal = Meal(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: 'Alimento personalizado',
      imageUrl: '',
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      prepTimeMinutes: 0,
      difficulty: 'easy',
      mealType: mealType,
      ingredients: [],
      steps: [],
      tags: ['personalizado'],
    );
    logMeal(meal, mealType);
  }

  void removeLoggedMeal(String id) {
    _loggedMeals.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = _dateKey(date);
    notifyListeners();
  }

  static String _todayKey() => _dateKey(DateTime.now());
  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
