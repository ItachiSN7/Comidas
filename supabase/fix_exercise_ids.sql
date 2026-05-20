-- ================================================================
-- Sincronizar IDs de ejercicios con la app Flutter
-- Ejecutar en: SQL Editor de Supabase
-- Solo necesitas ejecutar esto UNA VEZ
-- ================================================================

-- Borramos los ejercicios auto-generados y los re-insertamos con IDs fijos
DELETE FROM exercises;

INSERT INTO exercises (id, name, muscle_group, equipment, description, difficulty) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Press de Banca',               'chest',     'Barra',           'Ejercicio compuesto fundamental para el pecho.',     'medium'),
  ('00000000-0000-0000-0000-000000000002', 'Press Inclinado con Mancuernas','chest',     'Mancuernas',      'Trabaja la parte superior del pecho.',               'medium'),
  ('00000000-0000-0000-0000-000000000003', 'Aperturas con Mancuernas',      'chest',     'Mancuernas',      'Aislamiento del pecho.',                             'easy'),
  ('00000000-0000-0000-0000-000000000004', 'Dominadas',                     'back',      'Barra Dominadas', 'Ejercicio de tracción compuesto.',                   'hard'),
  ('00000000-0000-0000-0000-000000000005', 'Remo con Barra',                'back',      'Barra',           'Trabaja el grosor de la espalda.',                   'medium'),
  ('00000000-0000-0000-0000-000000000006', 'Jalón al Pecho',                'back',      'Polea',           'Alternativa a las dominadas.',                       'easy'),
  ('00000000-0000-0000-0000-000000000007', 'Press Militar',                 'shoulders', 'Barra',           'Compuesto de hombros.',                              'medium'),
  ('00000000-0000-0000-0000-000000000008', 'Elevaciones Laterales',         'shoulders', 'Mancuernas',      'Aislamiento del deltoides medio.',                   'easy'),
  ('00000000-0000-0000-0000-000000000009', 'Sentadilla con Barra',          'legs',      'Barra',           'Rey de los ejercicios.',                             'hard'),
  ('00000000-0000-0000-0000-000000000010', 'Peso Muerto',                   'back',      'Barra',           'Compuesto total.',                                   'hard'),
  ('00000000-0000-0000-0000-000000000011', 'Prensa de Pierna',              'legs',      'Máquina',         'Trabaja cuádriceps.',                                'easy'),
  ('00000000-0000-0000-0000-000000000012', 'Extensión de Cuádriceps',       'legs',      'Máquina',         'Aislamiento de cuádriceps.',                         'easy'),
  ('00000000-0000-0000-0000-000000000013', 'Curl Femoral',                  'legs',      'Máquina',         'Aislamiento de isquiotibiales.',                     'easy'),
  ('00000000-0000-0000-0000-000000000014', 'Hip Thrust',                    'glutes',    'Barra',           'El mejor ejercicio para glúteos.',                   'medium'),
  ('00000000-0000-0000-0000-000000000015', 'Curl de Bíceps',                'biceps',    'Mancuernas',      'Aislamiento clásico de bíceps.',                     'easy'),
  ('00000000-0000-0000-0000-000000000016', 'Curl Martillo',                 'biceps',    'Mancuernas',      'Trabaja bíceps braquial.',                           'easy'),
  ('00000000-0000-0000-0000-000000000017', 'Press Francés',                 'triceps',   'Barra',           'Aislamiento de cabeza larga del tríceps.',           'medium'),
  ('00000000-0000-0000-0000-000000000018', 'Fondos en Paralelas',           'triceps',   'Paralelas',       'Compuesto tríceps y pecho.',                         'medium'),
  ('00000000-0000-0000-0000-000000000019', 'Plancha',                       'core',      'Sin equipamiento','Ejercicio isométrico fundamental para core.',        'easy'),
  ('00000000-0000-0000-0000-000000000020', 'Rueda Abdominal',               'core',      'Rueda Ab',        'Ejercicio avanzado para core.',                      'hard');

-- Verificar
SELECT id, name FROM exercises ORDER BY id;
