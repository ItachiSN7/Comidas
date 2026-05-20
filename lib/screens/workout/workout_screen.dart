import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import 'active_workout_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                title: const Text(
                  'Entrenamiento',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Start Workout CTA ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GradientCard(
                        gradient: AppColors.primaryGradient,
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nuevo Entrenamiento',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Registra tu sesión de hoy',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () => _startWorkout(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.play_arrow, color: AppColors.primary, size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            'Empezar',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.fitness_center, size: 64, color: Colors.black26),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Progression Suggestions ────────────────────────────
                    if (workoutProvider.suggestions.isNotEmpty) ...[
                      SectionHeader(
                        title: 'Progresión Sugerida',
                        subtitle: '${workoutProvider.suggestions.length} ejercicios listos',
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: workoutProvider.suggestions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, index) => _ProgressionCard(
                            suggestion: workoutProvider.suggestions[index],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Stats Overview ─────────────────────────────────────
                    if (workoutProvider.recentWorkouts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Entrenamientos',
                                value: workoutProvider.recentWorkouts.length.toString(),
                                icon: Icons.calendar_today,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Volumen Total',
                                value: '${(workoutProvider.recentWorkouts.fold(0.0, (s, w) => s + w.totalVolume) / 1000).toStringAsFixed(1)}t',
                                icon: Icons.bar_chart,
                                color: AppColors.accentPurple,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Min. Entrenados',
                                value: workoutProvider.recentWorkouts
                                    .fold(0, (s, w) => s + w.durationMinutes)
                                    .toString(),
                                icon: Icons.timer,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Recent Workouts ────────────────────────────────────
                    SectionHeader(
                      title: 'Historial',
                      subtitle: 'Tus últimas sesiones',
                    ),
                    const SizedBox(height: 12),

                    if (workoutProvider.recentWorkouts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.fitness_center, size: 48, color: AppColors.textMuted),
                              SizedBox(height: 12),
                              Text(
                                'Aún no tienes entrenamientos.\n¡Empieza tu primera sesión!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...workoutProvider.recentWorkouts
                          .take(5)
                          .map((w) => _WorkoutHistoryCard(workout: w)),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startWorkout(BuildContext context) {
    final nameController = TextEditingController(text: 'Entrenamiento');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre del Entrenamiento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Ej: Empuje - Pecho y Tríceps',
              ),
            ),
            const SizedBox(height: 16),
            // Quick templates
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Empuje', 'Tracción', 'Piernas', 'Full Body', 'Upper Body', 'Core'
              ].map((template) => GestureDetector(
                onTap: () => nameController.text = template,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    template,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final name = nameController.text.trim().isEmpty
                      ? 'Entrenamiento'
                      : nameController.text.trim();
                  context.read<WorkoutProvider>().startWorkout(name);
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Empezar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressionCard extends StatelessWidget {
  final ProgressionSuggestion suggestion;

  const _ProgressionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up, color: AppColors.primary, size: 14),
              ),
              const SizedBox(width: 8),
              const Text(
                'Aumentar Peso',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.exerciseName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '${suggestion.currentWeight.toInt()} kg',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const Icon(Icons.arrow_forward, size: 12, color: AppColors.textTertiary),
              Text(
                '${suggestion.suggestedWeight.toInt()} kg',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final Workout workout;

  const _WorkoutHistoryCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(workout.date).inDays;
    final dayLabel = days == 0 ? 'Hoy' : days == 1 ? 'Ayer' : 'Hace $days días';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  dayLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoChip(Icons.fitness_center, '${workout.exercises.length} ejercicios', AppColors.secondary),
                const SizedBox(width: 8),
                _InfoChip(Icons.timer, '${workout.durationMinutes} min', AppColors.accentOrange),
                const SizedBox(width: 8),
                _InfoChip(Icons.bar_chart, '${(workout.totalVolume / 1000).toStringAsFixed(1)}t', AppColors.accentPurple),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
