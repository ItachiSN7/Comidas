class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String imageUrl;
  final String description;
  final String difficulty;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.imageUrl,
    required this.description,
    required this.difficulty,
  });

  String get muscleGroupLabel {
    const labels = {
      'chest': 'Pecho',
      'back': 'Espalda',
      'shoulders': 'Hombros',
      'biceps': 'Bíceps',
      'triceps': 'Tríceps',
      'legs': 'Piernas',
      'glutes': 'Glúteos',
      'core': 'Core',
      'cardio': 'Cardio',
      'full_body': 'Cuerpo Completo',
    };
    return labels[muscleGroup] ?? muscleGroup;
  }
}

class WorkoutSet {
  final String id;
  final int reps;
  final double weightKg;
  final bool isCompleted;
  final String? notes;
  final int? rpe; // Rate of Perceived Exertion (1-10)

  const WorkoutSet({
    required this.id,
    required this.reps,
    required this.weightKg,
    this.isCompleted = false,
    this.notes,
    this.rpe,
  });

  WorkoutSet copyWith({
    int? reps,
    double? weightKg,
    bool? isCompleted,
    String? notes,
    int? rpe,
  }) {
    return WorkoutSet(
      id: id,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      rpe: rpe ?? this.rpe,
    );
  }
}

class WorkoutExercise {
  final String id;
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final String? notes;
  final ProgressionSuggestion? suggestion;

  const WorkoutExercise({
    required this.id,
    required this.exercise,
    required this.sets,
    this.notes,
    this.suggestion,
  });

  double get totalVolume =>
      sets.where((s) => s.isCompleted).fold(0, (sum, s) => sum + (s.reps * s.weightKg));

  int get completedSets => sets.where((s) => s.isCompleted).length;

  WorkoutExercise copyWith({
    List<WorkoutSet>? sets,
    String? notes,
    ProgressionSuggestion? suggestion,
  }) {
    return WorkoutExercise(
      id: id,
      exercise: exercise,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      suggestion: suggestion ?? this.suggestion,
    );
  }
}

class Workout {
  final String id;
  final String name;
  final DateTime date;
  final List<WorkoutExercise> exercises;
  final int durationMinutes;
  final bool isCompleted;
  final String? notes;

  const Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.exercises,
    this.durationMinutes = 0,
    this.isCompleted = false,
    this.notes,
  });

  double get totalVolume =>
      exercises.fold(0, (sum, e) => sum + e.totalVolume);

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.sets.length);

  Workout copyWith({
    String? name,
    List<WorkoutExercise>? exercises,
    int? durationMinutes,
    bool? isCompleted,
    String? notes,
  }) {
    return Workout(
      id: id,
      name: name ?? this.name,
      date: date,
      exercises: exercises ?? this.exercises,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}

class ProgressionSuggestion {
  final String exerciseId;
  final String exerciseName;
  final double currentWeight;
  final double suggestedWeight;
  final String reason;
  final int consecutiveSessions;

  const ProgressionSuggestion({
    required this.exerciseId,
    required this.exerciseName,
    required this.currentWeight,
    required this.suggestedWeight,
    required this.reason,
    required this.consecutiveSessions,
  });

  double get weightIncrease => suggestedWeight - currentWeight;
  double get percentIncrease => (weightIncrease / currentWeight) * 100;
}
