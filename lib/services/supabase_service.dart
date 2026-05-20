import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/meal.dart';
import '../models/workout.dart';
import '../models/shopping_item.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ── Auth ────────────────────────────────────────────────────────────────
  static User? get currentUser => _client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  static Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── User Profile ─────────────────────────────────────────────────────────
  static Future<void> upsertProfile(UserProfile profile) async {
    await _client.from('user_profiles').upsert({
      'user_id': currentUser?.id,
      ...profile.toMap(),
    });
  }

  static Future<UserProfile?> fetchProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final data = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromMap(data);
  }

  // ── Daily Logs ───────────────────────────────────────────────────────────
  static Future<void> logMeal(LoggedMeal logged) async {
    await _client.from('daily_logs').insert({
      'user_id': currentUser?.id,
      'meal_id': logged.meal.id.startsWith('custom_') ? null : logged.meal.id,
      'custom_name': logged.meal.id.startsWith('custom_') ? logged.meal.name : null,
      'custom_calories': logged.meal.id.startsWith('custom_') ? logged.calories : null,
      'custom_protein': logged.meal.id.startsWith('custom_') ? logged.protein : null,
      'custom_carbs': logged.meal.id.startsWith('custom_') ? logged.carbs : null,
      'custom_fat': logged.meal.id.startsWith('custom_') ? logged.fat : null,
      'meal_type': logged.mealType,
      'portion_multiplier': logged.portionMultiplier,
      'logged_at': logged.loggedAt.toIso8601String(),
      'date': logged.loggedAt.toIso8601String().split('T')[0],
    });
  }

  static Future<Map<String, double>> getDailyNutrition(DateTime date) async {
    final userId = currentUser?.id;
    if (userId == null) return {};

    final result = await _client.rpc('get_daily_nutrition', params: {
      'p_user_id': userId,
      'p_date': date.toIso8601String().split('T')[0],
    });

    if (result is List && result.isNotEmpty) {
      final row = result.first;
      return {
        'calories': (row['total_calories'] ?? 0).toDouble(),
        'protein': (row['total_protein'] ?? 0).toDouble(),
        'carbs': (row['total_carbs'] ?? 0).toDouble(),
        'fat': (row['total_fat'] ?? 0).toDouble(),
      };
    }
    return {};
  }

  // ── Workouts ─────────────────────────────────────────────────────────────
  static Future<String> saveWorkout(Workout workout) async {
    final workoutData = await _client.from('workouts').insert({
      'user_id': currentUser?.id,
      'name': workout.name,
      'date': workout.date.toIso8601String(),
      'duration_minutes': workout.durationMinutes,
      'is_completed': workout.isCompleted,
      'notes': workout.notes,
    }).select('id').single();

    final workoutId = workoutData['id'] as String;

    // Save exercises and sets
    for (int i = 0; i < workout.exercises.length; i++) {
      final ex = workout.exercises[i];
      final exData = await _client.from('workout_exercises').insert({
        'workout_id': workoutId,
        'exercise_id': ex.exercise.id,
        'exercise_order': i,
        'notes': ex.notes,
      }).select('id').single();

      final exId = exData['id'] as String;

      for (int j = 0; j < ex.sets.length; j++) {
        final set = ex.sets[j];
        await _client.from('workout_sets').insert({
          'workout_exercise_id': exId,
          'set_number': j + 1,
          'reps': set.reps,
          'weight_kg': set.weightKg,
          'is_completed': set.isCompleted,
          'rpe': set.rpe,
          'notes': set.notes,
        });
      }
    }

    return workoutId;
  }

  static Future<List<Map<String, dynamic>>> getExerciseHistory(String exerciseId) async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    return await _client.rpc('get_exercise_volume_history', params: {
      'p_user_id': userId,
      'p_exercise_id': exerciseId,
      'p_limit': 10,
    });
  }

  // ── Shopping Lists ────────────────────────────────────────────────────────
  static Future<void> saveShoppingList(ShoppingList list) async {
    final listData = await _client.from('shopping_lists').insert({
      'user_id': currentUser?.id,
      'week_label': list.weekLabel,
      'generated_at': list.generatedAt.toIso8601String(),
    }).select('id').single();

    final listId = listData['id'] as String;

    for (final item in list.items) {
      await _client.from('shopping_items').insert({
        'shopping_list_id': listId,
        'name': item.name,
        'category': item.category,
        'quantity': item.quantity,
        'unit': item.unit,
        'is_checked': item.isChecked,
        'meal_source': item.mealSource,
      });
    }
  }

  static Future<void> updateShoppingItem(String itemId, bool isChecked) async {
    await _client.from('shopping_items').update({'is_checked': isChecked}).eq('id', itemId);
  }
}
