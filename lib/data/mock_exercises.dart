import '../models/workout.dart';

// IDs fijos que coinciden exactamente con la base de datos de Supabase
const _e01 = '00000000-0000-0000-0000-000000000001';
const _e02 = '00000000-0000-0000-0000-000000000002';
const _e03 = '00000000-0000-0000-0000-000000000003';
const _e04 = '00000000-0000-0000-0000-000000000004';
const _e05 = '00000000-0000-0000-0000-000000000005';
const _e06 = '00000000-0000-0000-0000-000000000006';
const _e07 = '00000000-0000-0000-0000-000000000007';
const _e08 = '00000000-0000-0000-0000-000000000008';
const _e09 = '00000000-0000-0000-0000-000000000009';
const _e10 = '00000000-0000-0000-0000-000000000010';
const _e11 = '00000000-0000-0000-0000-000000000011';
const _e12 = '00000000-0000-0000-0000-000000000012';
const _e13 = '00000000-0000-0000-0000-000000000013';
const _e14 = '00000000-0000-0000-0000-000000000014';
const _e15 = '00000000-0000-0000-0000-000000000015';
const _e16 = '00000000-0000-0000-0000-000000000016';
const _e17 = '00000000-0000-0000-0000-000000000017';
const _e18 = '00000000-0000-0000-0000-000000000018';
const _e19 = '00000000-0000-0000-0000-000000000019';
const _e20 = '00000000-0000-0000-0000-000000000020';

final List<Exercise> mockExercises = [
  // CHEST
  Exercise(
    id: _e01,
    name: 'Press de Banca',
    muscleGroup: 'chest',
    equipment: 'Barra',
    imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    description: 'Ejercicio compuesto fundamental para el pecho. Activa pectorales, hombros anteriores y tríceps.',
    difficulty: 'medium',
  ),
  Exercise(
    id: _e02,
    name: 'Press Inclinado con Mancuernas',
    muscleGroup: 'chest',
    equipment: 'Mancuernas',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    description: 'Trabaja la parte superior del pecho con mayor amplitud de movimiento.',
    difficulty: 'medium',
  ),
  Exercise(
    id: _e03,
    name: 'Aperturas con Mancuernas',
    muscleGroup: 'chest',
    equipment: 'Mancuernas',
    imageUrl: 'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=800',
    description: 'Aislamiento del pecho con énfasis en el estiramiento y la contracción.',
    difficulty: 'easy',
  ),

  // BACK
  Exercise(
    id: _e04,
    name: 'Dominadas',
    muscleGroup: 'back',
    equipment: 'Barra Dominadas',
    imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a03?w=800',
    description: 'Ejercicio de tracción compuesto. Excelente para la anchura y grosor de la espalda.',
    difficulty: 'hard',
  ),
  Exercise(
    id: _e05,
    name: 'Remo con Barra',
    muscleGroup: 'back',
    equipment: 'Barra',
    imageUrl: 'https://images.unsplash.com/photo-1550345332-09e3ac987658?w=800',
    description: 'Trabaja el grosor de la espalda. Enfocado en dorsales, romboides y trapecios.',
    difficulty: 'medium',
  ),
  Exercise(
    id: _e06,
    name: 'Jalón al Pecho',
    muscleGroup: 'back',
    equipment: 'Polea',
    imageUrl: 'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=800',
    description: 'Alternativa a las dominadas, ideal para trabajo de dorsales con control del peso.',
    difficulty: 'easy',
  ),

  // SHOULDERS
  Exercise(
    id: _e07,
    name: 'Press Militar',
    muscleGroup: 'shoulders',
    equipment: 'Barra',
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
    description: 'Compuesto de hombros que trabaja los tres deltoides y el trapecio.',
    difficulty: 'medium',
  ),
  Exercise(
    id: _e08,
    name: 'Elevaciones Laterales',
    muscleGroup: 'shoulders',
    equipment: 'Mancuernas',
    imageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=800',
    description: 'Aislamiento del deltoides medio para mayor anchura de hombros.',
    difficulty: 'easy',
  ),

  // LEGS
  Exercise(
    id: _e09,
    name: 'Sentadilla con Barra',
    muscleGroup: 'legs',
    equipment: 'Barra',
    imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
    description: 'Rey de los ejercicios. Trabaja cuádriceps, isquios, glúteos y core.',
    difficulty: 'hard',
  ),
  Exercise(
    id: _e10,
    name: 'Peso Muerto',
    muscleGroup: 'back',
    equipment: 'Barra',
    imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800',
    description: 'Compuesto total. Isquiotibiales, glúteos, espalda baja y trapecios.',
    difficulty: 'hard',
  ),
  Exercise(
    id: _e11,
    name: 'Prensa de Pierna',
    muscleGroup: 'legs',
    equipment: 'Máquina',
    imageUrl: 'https://images.unsplash.com/photo-1567598508481-65985588e295?w=800',
    description: 'Trabaja cuádriceps principalmente con menor demanda técnica que la sentadilla.',
    difficulty: 'easy',
  ),
  Exercise(
    id: _e12,
    name: 'Extensión de Cuádriceps',
    muscleGroup: 'legs',
    equipment: 'Máquina',
    imageUrl: 'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?w=800',
    description: 'Aislamiento de cuádriceps en máquina de extensión.',
    difficulty: 'easy',
  ),
  Exercise(
    id: _e13,
    name: 'Curl Femoral',
    muscleGroup: 'legs',
    equipment: 'Máquina',
    imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
    description: 'Aislamiento de isquiotibiales tumbado en máquina.',
    difficulty: 'easy',
  ),
  Exercise(
    id: _e14,
    name: 'Hip Thrust',
    muscleGroup: 'glutes',
    equipment: 'Barra',
    imageUrl: 'https://images.unsplash.com/photo-1580261450046-d0a30080dc9b?w=800',
    description: 'El ejercicio más efectivo para activación y desarrollo de glúteos.',
    difficulty: 'medium',
  ),

  // BICEPS
  Exercise(
    id: _e15,
    name: 'Curl de Bíceps',
    muscleGroup: 'biceps',
    equipment: 'Mancuernas',
    imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800',
    description: 'Aislamiento clásico de bíceps con mancuernas o barra.',
    difficulty: 'easy',
  ),
  Exercise(
    id: _e16,
    name: 'Curl Martillo',
    muscleGroup: 'biceps',
    equipment: 'Mancuernas',
    imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    description: 'Trabaja bíceps braquial y braquiorradial con agarre neutro.',
    difficulty: 'easy',
  ),

  // TRICEPS
  Exercise(
    id: _e17,
    name: 'Press Francés',
    muscleGroup: 'triceps',
    equipment: 'Barra',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    description: 'Aislamiento de cabeza larga del tríceps tumbado con barra EZ.',
    difficulty: 'medium',
  ),
  Exercise(
    id: _e18,
    name: 'Fondos en Paralelas',
    muscleGroup: 'triceps',
    equipment: 'Paralelas',
    imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a03?w=800',
    description: 'Compuesto que trabaja tríceps, pecho y hombros anteriores.',
    difficulty: 'medium',
  ),

  // CORE
  Exercise(
    id: _e19,
    name: 'Plancha',
    muscleGroup: 'core',
    equipment: 'Sin equipamiento',
    imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
    description: 'Ejercicio isométrico fundamental para core y estabilidad.',
    difficulty: 'easy',
  ),
  Exercise(
    id: _e20,
    name: 'Rueda Abdominal',
    muscleGroup: 'core',
    equipment: 'Rueda Ab',
    imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
    description: 'Ejercicio avanzado para core completo y estabilidad de columna.',
    difficulty: 'hard',
  ),
];

List<Exercise> getExercisesByMuscleGroup(String group) =>
    mockExercises.where((e) => e.muscleGroup == group).toList();

final Map<String, String> muscleGroupIcons = {
  'chest': '💪',
  'back': '🏋️',
  'shoulders': '🤸',
  'biceps': '💪',
  'triceps': '💪',
  'legs': '🦵',
  'glutes': '🍑',
  'core': '🎯',
  'cardio': '🏃',
  'full_body': '⚡',
};
