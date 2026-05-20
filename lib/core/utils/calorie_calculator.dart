class CalorieCalculator {
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    // Mifflin-St Jeor equation
    if (gender.toLowerCase() == 'male') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    const multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (multipliers[activityLevel] ?? 1.55);
  }

  static Map<String, double> calculateMacros({
    required double calories,
    required String goal,
  }) {
    double protein, carbs, fat;

    switch (goal) {
      case 'lose_fat':
        // High protein, moderate carbs, lower fat
        protein = (calories * 0.35) / 4; // 35% protein
        carbs = (calories * 0.35) / 4; // 35% carbs
        fat = (calories * 0.30) / 9; // 30% fat
        break;
      case 'gain_muscle':
        // High protein, high carbs, moderate fat
        protein = (calories * 0.30) / 4; // 30% protein
        carbs = (calories * 0.45) / 4; // 45% carbs
        fat = (calories * 0.25) / 9; // 25% fat
        break;
      case 'maintain':
      default:
        // Balanced macros
        protein = (calories * 0.25) / 4; // 25% protein
        carbs = (calories * 0.50) / 4; // 50% carbs
        fat = (calories * 0.25) / 9; // 25% fat
        break;
    }

    return {
      'protein': protein.roundToDouble(),
      'carbs': carbs.roundToDouble(),
      'fat': fat.roundToDouble(),
    };
  }

  static double adjustCaloriesForGoal(double tdee, String goal) {
    switch (goal) {
      case 'lose_fat':
        return tdee - 500; // 500 cal deficit
      case 'gain_muscle':
        return tdee + 300; // 300 cal surplus
      case 'maintain':
      default:
        return tdee;
    }
  }
}
