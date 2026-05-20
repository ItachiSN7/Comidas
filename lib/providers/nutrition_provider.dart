import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal.dart';
import '../data/mock_meals.dart';

class NutritionProvider extends ChangeNotifier {
  static final _client = Supabase.instance.client;

  final List<LoggedMeal> _loggedMeals = [];
  String _selectedDate = _todayKey();
  bool _syncing = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<LoggedMeal> get loggedMeals =>
      _loggedMeals.where((m) => _dateKey(m.loggedAt) == _selectedDate).toList();

  double get consumedCalories => loggedMeals.fold(0, (s, m) => s + m.calories);
  double get consumedProtein  => loggedMeals.fold(0, (s, m) => s + m.protein);
  double get consumedCarbs    => loggedMeals.fold(0, (s, m) => s + m.carbs);
  double get consumedFat      => loggedMeals.fold(0, (s, m) => s + m.fat);

  double remainingCalories(double t) => (t - consumedCalories).clamp(0, double.infinity);
  double remainingProtein(double t)  => (t - consumedProtein).clamp(0, double.infinity);
  double remainingCarbs(double t)    => (t - consumedCarbs).clamp(0, double.infinity);
  double remainingFat(double t)      => (t - consumedFat).clamp(0, double.infinity);

  double caloriesProgress(double t) => t > 0 ? (consumedCalories / t).clamp(0, 1) : 0;
  double proteinProgress(double t)  => t > 0 ? (consumedProtein / t).clamp(0, 1) : 0;
  double carbsProgress(double t)    => t > 0 ? (consumedCarbs / t).clamp(0, 1) : 0;
  double fatProgress(double t)      => t > 0 ? (consumedFat / t).clamp(0, 1) : 0;

  List<LoggedMeal> getMealsByType(String type) =>
      loggedMeals.where((m) => m.mealType == type).toList();

  // ── Recommendations ───────────────────────────────────────────────────────

  List<Meal> getRecommendedMeals({
    required String mealType,
    required double targetCalories,
    required double targetProtein,
    required double targetFat,
    required String goal,
  }) {
    final remCal     = remainingCalories(targetCalories);
    final remProtein = remainingProtein(targetProtein);
    final remFat     = remainingFat(targetFat);

    return mockMeals
        .where((m) => m.mealType == mealType)
        .toList()
      ..sort((a, b) => _mealScore(b, remCal, remProtein, remFat, goal)
          .compareTo(_mealScore(a, remCal, remProtein, remFat, goal)));
  }

  double _mealScore(Meal m, double remCal, double remProt, double remFat, String goal) {
    double score = 0;
    if (m.calories <= remCal)  score += 2;
    if (m.protein  <= remProt) score += 1;
    if (m.fat      <= remFat)  score += 1;
    if (goal == 'gain_muscle' && m.protein >= 25) score += 2;
    if (goal == 'lose_fat'    && m.calories <= 400) score += 2;
    return score;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

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
    _syncLog(logged);
  }

  void logCustomFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String mealType,
  }) {
    logMeal(
      Meal(
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
      ),
      mealType,
    );
  }

  void removeLoggedMeal(String id) {
    _loggedMeals.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = _dateKey(date);
    notifyListeners();
  }

  // ── Supabase sync ─────────────────────────────────────────────────────────

  Future<void> loadFromSupabase(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final rows = await _client
          .from('daily_logs')
          .select('*, meals(*)')
          .eq('user_id', userId)
          .eq('date', _dateKey(date)) as List;

      _loggedMeals.removeWhere((m) => _dateKey(m.loggedAt) == _dateKey(date));

      for (final row in rows) {
        final mealData = row['meals'] as Map<String, dynamic>?;
        final meal = mealData != null
            ? Meal.fromMap(mealData)
            : Meal(
                id: 'custom_${row['id']}',
                name: row['custom_name'] ?? 'Alimento',
                description: '',
                imageUrl: '',
                calories: (row['custom_calories'] ?? 0).toDouble(),
                protein: (row['custom_protein'] ?? 0).toDouble(),
                carbs: (row['custom_carbs'] ?? 0).toDouble(),
                fat: (row['custom_fat'] ?? 0).toDouble(),
                prepTimeMinutes: 0,
                difficulty: 'easy',
                mealType: row['meal_type'] ?? 'snack',
                ingredients: [],
                steps: [],
                tags: [],
              );

        _loggedMeals.add(LoggedMeal(
          id: row['id'],
          meal: meal,
          loggedAt: DateTime.parse(row['logged_at']),
          mealType: row['meal_type'] ?? 'snack',
          portionMultiplier: (row['portion_multiplier'] ?? 1).toDouble(),
        ));
      }
      notifyListeners();
    } catch (_) {
      // Keep local data on error
    }
  }

  Future<void> _syncLog(LoggedMeal logged) async {
    if (_syncing) return;
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    _syncing = true;
    try {
      final isCustom = logged.meal.id.startsWith('custom_');
      await _client.from('daily_logs').insert({
        'user_id': userId,
        'meal_id': isCustom ? null : logged.meal.id,
        'custom_name': isCustom ? logged.meal.name : null,
        'custom_calories': isCustom ? logged.calories : null,
        'custom_protein': isCustom ? logged.protein : null,
        'custom_carbs': isCustom ? logged.carbs : null,
        'custom_fat': isCustom ? logged.fat : null,
        'meal_type': logged.mealType,
        'portion_multiplier': logged.portionMultiplier,
        'logged_at': logged.loggedAt.toIso8601String(),
        'date': _dateKey(logged.loggedAt),
      });
    } catch (_) {
      // Offline — local only
    } finally {
      _syncing = false;
    }
  }

  static String _todayKey() => _dateKey(DateTime.now());
  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
