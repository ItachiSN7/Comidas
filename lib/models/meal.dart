class Meal {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int prepTimeMinutes;
  final String difficulty;
  final String mealType;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  bool isLogged;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTimeMinutes,
    required this.difficulty,
    required this.mealType,
    required this.ingredients,
    required this.steps,
    required this.tags,
    this.isLogged = false,
  });

  String get difficultyLabel {
    switch (difficulty) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Media';
      case 'hard':
        return 'Difícil';
      default:
        return 'Fácil';
    }
  }

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Comida';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Snack';
      default:
        return 'Comida';
    }
  }

  Meal copyWith({bool? isLogged}) {
    return Meal(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      prepTimeMinutes: prepTimeMinutes,
      difficulty: difficulty,
      mealType: mealType,
      ingredients: ingredients,
      steps: steps,
      tags: tags,
      isLogged: isLogged ?? this.isLogged,
    );
  }
}

class LoggedMeal {
  final String id;
  final Meal meal;
  final DateTime loggedAt;
  final String mealType;
  final double portionMultiplier;

  const LoggedMeal({
    required this.id,
    required this.meal,
    required this.loggedAt,
    required this.mealType,
    this.portionMultiplier = 1.0,
  });

  double get calories => meal.calories * portionMultiplier;
  double get protein => meal.protein * portionMultiplier;
  double get carbs => meal.carbs * portionMultiplier;
  double get fat => meal.fat * portionMultiplier;
}

class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;
  final String category;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
    required this.category,
  });
}
