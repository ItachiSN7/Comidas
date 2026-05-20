class UserProfile {
  final String id;
  final String name;
  final double weightKg;
  final double heightCm;
  final int age;
  final String gender;
  final String activityLevel;
  final String goal;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  const UserProfile({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  String get goalLabel {
    switch (goal) {
      case 'lose_fat':
        return 'Perder Grasa';
      case 'gain_muscle':
        return 'Ganar Músculo';
      case 'maintain':
      default:
        return 'Mantener Peso';
    }
  }

  String get activityLabel {
    switch (activityLevel) {
      case 'sedentary':
        return 'Sedentario';
      case 'light':
        return 'Ligero';
      case 'moderate':
        return 'Moderado';
      case 'active':
        return 'Activo';
      case 'very_active':
        return 'Muy Activo';
      default:
        return 'Moderado';
    }
  }

  UserProfile copyWith({
    String? id,
    String? name,
    double? weightKg,
    double? heightCm,
    int? age,
    String? gender,
    String? activityLevel,
    String? goal,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'age': age,
      'gender': gender,
      'activity_level': activityLevel,
      'goal': goal,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fat': targetFat,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      weightKg: (map['weight_kg'] ?? 70).toDouble(),
      heightCm: (map['height_cm'] ?? 170).toDouble(),
      age: map['age'] ?? 25,
      gender: map['gender'] ?? 'male',
      activityLevel: map['activity_level'] ?? 'moderate',
      goal: map['goal'] ?? 'maintain',
      targetCalories: (map['target_calories'] ?? 2000).toDouble(),
      targetProtein: (map['target_protein'] ?? 150).toDouble(),
      targetCarbs: (map['target_carbs'] ?? 200).toDouble(),
      targetFat: (map['target_fat'] ?? 65).toDouble(),
    );
  }
}
