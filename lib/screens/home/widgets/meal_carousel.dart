import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/meal.dart';
import '../../../providers/nutrition_provider.dart';
import '../../../providers/user_provider.dart';
import '../../recipes/recipe_detail_screen.dart';

class MealCarousel extends StatelessWidget {
  final String mealType;
  final String title;
  final String emoji;

  const MealCarousel({
    super.key,
    required this.mealType,
    required this.title,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<NutritionProvider, UserProvider>(
      builder: (context, nutrition, user, _) {
        final profile = user.profile;
        if (profile == null) return const SizedBox.shrink();

        final meals = nutrition.getRecommendedMeals(
          mealType: mealType,
          targetCalories: profile.targetCalories,
          targetProtein: profile.targetProtein,
          targetFat: profile.targetFat,
          goal: profile.goal,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: meals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _MealCard(meal: meals[index], mealType: mealType),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final String mealType;

  const _MealCard({required this.meal, required this.mealType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(meal: meal)),
      ),
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                meal.imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: AppColors.cardBg2,
                  child: const Icon(Icons.restaurant, color: AppColors.textMuted, size: 32),
                ),
              ),
            ),
            // Gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                  ),
                ),
              ),
            ),
            // Calories badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  '${meal.calories.toInt()} kcal',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            // Info section
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MacroTag('P', '${meal.protein.toInt()}g', AppColors.proteinColor),
                        const SizedBox(width: 4),
                        _MacroTag('C', '${meal.carbs.toInt()}g', AppColors.carbsColor),
                        const SizedBox(width: 4),
                        _MacroTag('G', '${meal.fat.toInt()}g', AppColors.fatColor),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 11, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          '${meal.prepTimeMinutes} min',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        _LogButton(meal: meal, mealType: mealType),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroTag(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label$value',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  final Meal meal;
  final String mealType;

  const _LogButton({required this.meal, required this.mealType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<NutritionProvider>().logMeal(meal, mealType);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.name} añadida al registro'),
            backgroundColor: AppColors.cardBg,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '+ Añadir',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
