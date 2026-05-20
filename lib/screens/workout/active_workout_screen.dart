import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/glass_card.dart';

const _uuid = Uuid();

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, _) {
        final workout = workoutProvider.activeWorkout;
        if (workout == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
          return const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.background,
                leading: GestureDetector(
                  onTap: () => _confirmDiscard(context, workoutProvider),
                  child: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
                title: Column(
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _timerLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  GestureDetector(
                    onTap: () => _finishWorkout(context, workoutProvider),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Terminar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Stats bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          _LiveStat('Ejercicios', workout.exercises.length.toString()),
                          _LiveStat(
                            'Series Completadas',
                            workout.exercises
                                .fold(0, (s, e) => s + e.completedSets)
                                .toString(),
                          ),
                          _LiveStat(
                            'Volumen',
                            '${(workout.totalVolume / 1000).toStringAsFixed(1)}t',
                          ),
                        ],
                      ),
                    ),

                    // Exercise list
                    ...workout.exercises.asMap().entries.map(
                      (entry) => _ExerciseBlock(
                        exerciseIndex: entry.key,
                        workoutExercise: entry.value,
                        workoutProvider: workoutProvider,
                      ),
                    ),

                    // Add Exercise button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: OutlinedButton.icon(
                        onPressed: () => _showExercisePicker(context, workoutProvider),
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        label: const Text('Añadir Ejercicio',
                            style: TextStyle(color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _finishWorkout(BuildContext context, WorkoutProvider provider) {
    provider.finishWorkout(_seconds ~/ 60);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Entrenamiento completado en $_timerLabel! 🔥'),
        backgroundColor: AppColors.cardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDiscard(BuildContext context, WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Descartar entrenamiento', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('¿Seguro que quieres cancelar esta sesión?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              provider.discardWorkout();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Descartar', style: TextStyle(color: AppColors.caloriesColor)),
          ),
        ],
      ),
    );
  }

  void _showExercisePicker(BuildContext context, WorkoutProvider provider) {
    final exercises = provider.allExercises;
    String selectedGroup = 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Elegir Ejercicio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Group filter
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    {'id': 'all', 'label': 'Todos'},
                    {'id': 'chest', 'label': 'Pecho'},
                    {'id': 'back', 'label': 'Espalda'},
                    {'id': 'legs', 'label': 'Piernas'},
                    {'id': 'shoulders', 'label': 'Hombros'},
                    {'id': 'biceps', 'label': 'Bíceps'},
                    {'id': 'triceps', 'label': 'Tríceps'},
                    {'id': 'core', 'label': 'Core'},
                  ].map((g) {
                    final isSelected = selectedGroup == g['id'];
                    return GestureDetector(
                      onTap: () => setState(() => selectedGroup = g['id']!),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          g['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: exercises
                      .where((e) => selectedGroup == 'all' || e.muscleGroup == selectedGroup)
                      .length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final filtered = exercises
                        .where((e) => selectedGroup == 'all' || e.muscleGroup == selectedGroup)
                        .toList();
                    final ex = filtered[index];
                    return GestureDetector(
                      onTap: () {
                        provider.addExerciseToWorkout(ex);
                        Navigator.pop(ctx);
                      },
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
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.fitness_center,
                                  color: AppColors.secondary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ex.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                  Text(
                                    '${ex.muscleGroupLabel} · ${ex.equipment}',
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.add_circle, color: AppColors.primary, size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveStat extends StatelessWidget {
  final String label;
  final String value;

  const _LiveStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
            Text(label,
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ExerciseBlock extends StatelessWidget {
  final int exerciseIndex;
  final WorkoutExercise workoutExercise;
  final WorkoutProvider workoutProvider;

  const _ExerciseBlock({
    required this.exerciseIndex,
    required this.workoutExercise,
    required this.workoutProvider,
  });

  @override
  Widget build(BuildContext context) {
    final ex = workoutExercise.exercise;
    final suggestion = workoutExercise.suggestion;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${exerciseIndex + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text(ex.muscleGroupLabel,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progression suggestion
            if (suggestion != null)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.primary, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Intenta ${suggestion.suggestedWeight.toInt()} kg hoy (+${suggestion.weightIncrease.toInt()} kg)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Sets header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text('Set', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Peso (kg)', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Reps', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Sets
            ...workoutExercise.sets.asMap().entries.map(
              (entry) => _SetRow(
                setIndex: entry.key,
                set: entry.value,
                exerciseId: workoutExercise.id,
                provider: workoutProvider,
              ),
            ),

            // Add set
            TextButton.icon(
              onPressed: () => workoutProvider.addSet(workoutExercise.id),
              icon: const Icon(Icons.add, size: 16, color: AppColors.textTertiary),
              label: const Text('Añadir Serie', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setIndex;
  final WorkoutSet set;
  final String exerciseId;
  final WorkoutProvider provider;

  const _SetRow({
    required this.setIndex,
    required this.set,
    required this.exerciseId,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final weightCtrl = TextEditingController(
      text: set.weightKg > 0 ? set.weightKg.toString() : '',
    );
    final repsCtrl = TextEditingController(text: set.reps.toString());

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: TextField(
                controller: weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  hintText: '0',
                  fillColor: set.isCompleted
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.surface,
                ),
                onChanged: (v) => provider.updateSet(
                  exerciseId,
                  setIndex,
                  weight: double.tryParse(v) ?? 0,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: TextField(
                controller: repsCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  hintText: '0',
                  fillColor: set.isCompleted
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.surface,
                ),
                onChanged: (v) => provider.updateSet(
                  exerciseId,
                  setIndex,
                  reps: int.tryParse(v) ?? 0,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => provider.updateSet(
              exerciseId,
              setIndex,
              completed: !set.isCompleted,
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: set.isCompleted
                    ? AppColors.primary
                    : AppColors.cardBg2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: set.isCompleted ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Icon(
                set.isCompleted ? Icons.check : Icons.check,
                size: 16,
                color: set.isCompleted ? Colors.black : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
