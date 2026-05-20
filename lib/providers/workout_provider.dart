import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../data/mock_exercises.dart';

const _uuid = Uuid();

class WorkoutProvider extends ChangeNotifier {
  final List<Workout> _workouts = [];
  Workout? _activeWorkout;
  final List<ProgressionSuggestion> _suggestions = [];

  List<Workout> get workouts => List.unmodifiable(_workouts);
  Workout? get activeWorkout => _activeWorkout;
  List<ProgressionSuggestion> get suggestions => List.unmodifiable(_suggestions);

  List<Workout> get recentWorkouts => _workouts
      .where((w) => w.isCompleted)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  // Start a new workout
  void startWorkout(String name) {
    _activeWorkout = Workout(
      id: _uuid.v4(),
      name: name,
      date: DateTime.now(),
      exercises: [],
    );
    notifyListeners();
  }

  void addExerciseToWorkout(Exercise exercise) {
    if (_activeWorkout == null) return;
    final workoutExercise = WorkoutExercise(
      id: _uuid.v4(),
      exercise: exercise,
      sets: [
        WorkoutSet(id: _uuid.v4(), reps: 10, weightKg: 0),
        WorkoutSet(id: _uuid.v4(), reps: 10, weightKg: 0),
        WorkoutSet(id: _uuid.v4(), reps: 10, weightKg: 0),
      ],
      suggestion: _getSuggestionForExercise(exercise.id),
    );
    _activeWorkout = _activeWorkout!.copyWith(
      exercises: [..._activeWorkout!.exercises, workoutExercise],
    );
    notifyListeners();
  }

  void updateSet(String exerciseId, int setIndex, {int? reps, double? weight, bool? completed}) {
    if (_activeWorkout == null) return;
    final exercises = _activeWorkout!.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final sets = List<WorkoutSet>.from(e.sets);
      if (setIndex < sets.length) {
        sets[setIndex] = sets[setIndex].copyWith(
          reps: reps,
          weightKg: weight,
          isCompleted: completed,
        );
      }
      return e.copyWith(sets: sets);
    }).toList();
    _activeWorkout = _activeWorkout!.copyWith(exercises: exercises);
    notifyListeners();
  }

  void addSet(String exerciseId) {
    if (_activeWorkout == null) return;
    final exercises = _activeWorkout!.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final lastSet = e.sets.isNotEmpty ? e.sets.last : null;
      final newSet = WorkoutSet(
        id: _uuid.v4(),
        reps: lastSet?.reps ?? 10,
        weightKg: lastSet?.weightKg ?? 0,
      );
      return e.copyWith(sets: [...e.sets, newSet]);
    }).toList();
    _activeWorkout = _activeWorkout!.copyWith(exercises: exercises);
    notifyListeners();
  }

  void removeSet(String exerciseId, int setIndex) {
    if (_activeWorkout == null) return;
    final exercises = _activeWorkout!.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final sets = List<WorkoutSet>.from(e.sets)..removeAt(setIndex);
      return e.copyWith(sets: sets);
    }).toList();
    _activeWorkout = _activeWorkout!.copyWith(exercises: exercises);
    notifyListeners();
  }

  void finishWorkout(int durationMinutes) {
    if (_activeWorkout == null) return;
    final completed = _activeWorkout!.copyWith(
      isCompleted: true,
      durationMinutes: durationMinutes,
    );
    _workouts.add(completed);
    _activeWorkout = null;
    _generateProgressionSuggestions();
    notifyListeners();
  }

  void discardWorkout() {
    _activeWorkout = null;
    notifyListeners();
  }

  void _generateProgressionSuggestions() {
    _suggestions.clear();
    // Check each exercise for progression opportunities
    final exerciseHistory = <String, List<WorkoutExercise>>{};

    for (final workout in _workouts.where((w) => w.isCompleted)) {
      for (final ex in workout.exercises) {
        exerciseHistory.putIfAbsent(ex.exercise.id, () => []).add(ex);
      }
    }

    for (final entry in exerciseHistory.entries) {
      final history = entry.value;
      if (history.length >= 3) {
        final recent = history.last;
        final allCompleted = recent.sets.every((s) => s.isCompleted);
        final avgWeight = recent.sets.isEmpty
            ? 0.0
            : recent.sets.fold(0.0, (sum, s) => sum + s.weightKg) / recent.sets.length;

        if (allCompleted && avgWeight > 0) {
          final suggestion = ProgressionSuggestion(
            exerciseId: entry.key,
            exerciseName: recent.exercise.name,
            currentWeight: avgWeight,
            suggestedWeight: avgWeight + (avgWeight > 40 ? 5 : 2.5),
            reason: 'Completaste todas las series durante ${history.length} sesiones consecutivas.',
            consecutiveSessions: history.length,
          );
          _suggestions.add(suggestion);
        }
      }
    }
    notifyListeners();
  }

  ProgressionSuggestion? _getSuggestionForExercise(String exerciseId) {
    try {
      return _suggestions.firstWhere((s) => s.exerciseId == exerciseId);
    } catch (_) {
      return null;
    }
  }

  Map<String, List<double>> getProgressData(String exerciseId) {
    final weights = <double>[];
    final volumes = <double>[];

    for (final workout in _workouts.where((w) => w.isCompleted)) {
      for (final ex in workout.exercises) {
        if (ex.exercise.id == exerciseId) {
          final avgWeight = ex.sets.isEmpty
              ? 0.0
              : ex.sets.fold(0.0, (sum, s) => sum + s.weightKg) / ex.sets.length;
          weights.add(avgWeight);
          volumes.add(ex.totalVolume);
        }
      }
    }
    return {'weights': weights, 'volumes': volumes};
  }

  List<Exercise> get allExercises => mockExercises;

  void loadDemoData() {
    if (_workouts.isNotEmpty) return;

    // Add 3 demo workouts for progression suggestions
    for (int i = 3; i >= 1; i--) {
      final workout = Workout(
        id: _uuid.v4(),
        name: 'Empuje - Pecho & Tríceps',
        date: DateTime.now().subtract(Duration(days: i * 2)),
        exercises: [
          WorkoutExercise(
            id: _uuid.v4(),
            exercise: mockExercises.firstWhere((e) => e.id == 'ex1'),
            sets: [
              WorkoutSet(id: _uuid.v4(), reps: 8, weightKg: 80, isCompleted: true),
              WorkoutSet(id: _uuid.v4(), reps: 8, weightKg: 80, isCompleted: true),
              WorkoutSet(id: _uuid.v4(), reps: 8, weightKg: 80, isCompleted: true),
            ],
          ),
        ],
        durationMinutes: 55,
        isCompleted: true,
      );
      _workouts.add(workout);
    }
    _generateProgressionSuggestions();
  }
}
