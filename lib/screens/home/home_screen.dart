import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/macro_progress_bar.dart';
import '../../widgets/section_header.dart';
import '../recipes/recipes_screen.dart';
import '../workout/workout_screen.dart';
import 'widgets/calories_ring.dart';
import 'widgets/meal_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer2<UserProvider, NutritionProvider>(
        builder: (context, userProvider, nutrition, _) {
          final profile = userProvider.profile;
          if (profile == null) return const SizedBox.shrink();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
                pinned: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.person, color: Colors.black, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Goal Badge ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _GoalBadge(goal: profile.goalLabel),
                          const SizedBox(width: 8),
                          _GoalBadge(goal: profile.activityLabel, secondary: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Calories Ring + Summary ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Ring
                                CaloriesRing(
                                  consumed: nutrition.consumedCalories,
                                  target: profile.targetCalories,
                                  proteinProgress: nutrition.proteinProgress(profile.targetProtein),
                                  carbsProgress: nutrition.carbsProgress(profile.targetCarbs),
                                  fatProgress: nutrition.fatProgress(profile.targetFat),
                                ),
                                const SizedBox(width: 20),
                                // Stats column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _StatRow(
                                        icon: Icons.local_fire_department,
                                        color: AppColors.caloriesColor,
                                        label: 'Objetivo',
                                        value: '${profile.targetCalories.toInt()} kcal',
                                      ),
                                      const SizedBox(height: 12),
                                      _StatRow(
                                        icon: Icons.trending_up,
                                        color: AppColors.primary,
                                        label: 'Consumidas',
                                        value: '${nutrition.consumedCalories.toInt()} kcal',
                                      ),
                                      const SizedBox(height: 12),
                                      _StatRow(
                                        icon: Icons.battery_charging_full,
                                        color: AppColors.secondary,
                                        label: 'Restantes',
                                        value: '${nutrition.remainingCalories(profile.targetCalories).toInt()} kcal',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 16),

                            // Macro bars
                            MacroProgressBar(
                              label: 'Proteínas',
                              consumed: nutrition.consumedProtein,
                              target: profile.targetProtein,
                              color: AppColors.proteinColor,
                            ),
                            const SizedBox(height: 12),
                            MacroProgressBar(
                              label: 'Carbohidratos',
                              consumed: nutrition.consumedCarbs,
                              target: profile.targetCarbs,
                              color: AppColors.carbsColor,
                            ),
                            const SizedBox(height: 12),
                            MacroProgressBar(
                              label: 'Grasas',
                              consumed: nutrition.consumedFat,
                              target: profile.targetFat,
                              color: AppColors.fatColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Logged Meals Today ────────────────────────────────────
                    if (nutrition.loggedMeals.isNotEmpty) ...[
                      SectionHeader(
                        title: 'Registro de Hoy',
                        subtitle: '${nutrition.loggedMeals.length} comidas',
                        actionLabel: 'Ver todo',
                        onAction: () {},
                      ),
                      const SizedBox(height: 12),
                      ..._buildLoggedMealsList(context, nutrition),
                      const SizedBox(height: 24),
                    ],

                    // ── Workout Summary ───────────────────────────────────────
                    _WorkoutSummaryCard(),

                    const SizedBox(height: 28),

                    // ── Meal Carousels ────────────────────────────────────────
                    const MealCarousel(mealType: 'breakfast', title: 'Desayuno', emoji: '🌅'),
                    const SizedBox(height: 24),
                    const MealCarousel(mealType: 'lunch', title: 'Comida', emoji: '☀️'),
                    const SizedBox(height: 24),
                    const MealCarousel(mealType: 'dinner', title: 'Cena', emoji: '🌙'),
                    const SizedBox(height: 24),
                    const MealCarousel(mealType: 'snack', title: 'Snacks', emoji: '⚡'),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _AddMealFAB(),
    );
  }

  List<Widget> _buildLoggedMealsList(
      BuildContext context, NutritionProvider nutrition) {
    return nutrition.loggedMeals.take(3).map((logged) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      logged.meal.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${logged.calories.toInt()} kcal · P${logged.protein.toInt()}g C${logged.carbs.toInt()}g G${logged.fat.toInt()}g',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<NutritionProvider>().removeLoggedMeal(logged.id);
                },
                child: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días,';
    if (hour < 19) return 'Buenas tardes,';
    return 'Buenas noches,';
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}

class _GoalBadge extends StatelessWidget {
  final String goal;
  final bool secondary;

  const _GoalBadge({required this.goal, this.secondary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: secondary ? null : AppColors.primaryGradient,
        color: secondary ? AppColors.cardBg : null,
        borderRadius: BorderRadius.circular(20),
        border: secondary ? Border.all(color: AppColors.border) : null,
      ),
      child: Text(
        goal,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: secondary ? AppColors.textSecondary : Colors.black,
        ),
      ),
    );
  }
}

class _WorkoutSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, _) {
        final recent = workoutProvider.recentWorkouts;
        final lastWorkout = recent.isNotEmpty ? recent.first : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutScreen()),
            ),
            child: GradientCard(
              gradient: AppColors.purpleGradient,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lastWorkout != null ? 'Último: ${lastWorkout.name}' : 'Empezar Entrenamiento',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lastWorkout != null
                              ? '${lastWorkout.exercises.length} ejercicios · ${lastWorkout.durationMinutes} min'
                              : 'Registra tu rutina de hoy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddMealFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddMealSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.black, size: 20),
            SizedBox(width: 6),
            Text(
              'Añadir Comida',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealSheet(BuildContext context) {
    final nameController = TextEditingController();
    final calsController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    String selectedType = 'lunch';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Añadir Comida',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Meal type selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final type in ['breakfast', 'lunch', 'dinner', 'snack'])
                      GestureDetector(
                        onTap: () => setState(() => selectedType = type),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selectedType == type
                                ? AppColors.primary
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _typeLabel(type),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selectedType == type
                                  ? Colors.black
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nombre del alimento',
                  prefixIcon: Icon(Icons.restaurant_menu, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: calsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Calorías',
                        suffixText: 'kcal',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Proteínas',
                        suffixText: 'g',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: carbsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Carbohidratos',
                        suffixText: 'g',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fatController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Grasas',
                        suffixText: 'g',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    context.read<NutritionProvider>().logCustomFood(
                      name: name,
                      calories: double.tryParse(calsController.text) ?? 0,
                      protein: double.tryParse(proteinController.text) ?? 0,
                      carbs: double.tryParse(carbsController.text) ?? 0,
                      fat: double.tryParse(fatController.text) ?? 0,
                      mealType: selectedType,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Registrar Comida'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    const labels = {
      'breakfast': 'Desayuno',
      'lunch': 'Comida',
      'dinner': 'Cena',
      'snack': 'Snack',
    };
    return labels[type] ?? type;
  }
}
