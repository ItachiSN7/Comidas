-- ================================================================
-- COMIDAS — Script de configuración completo Supabase
-- Ejecutar en: Supabase Dashboard → SQL Editor → New Query
-- ================================================================

-- ── 1. EXTENSIONES ───────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- ── 2. PERFILES DE USUARIO ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_profiles (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  name         TEXT NOT NULL DEFAULT 'Usuario',
  weight_kg    DECIMAL(5,2) NOT NULL DEFAULT 70,
  height_cm    DECIMAL(5,1) NOT NULL DEFAULT 170,
  age          INTEGER NOT NULL DEFAULT 25 CHECK (age BETWEEN 10 AND 120),
  gender       TEXT NOT NULL DEFAULT 'male' CHECK (gender IN ('male', 'female')),
  activity_level TEXT NOT NULL DEFAULT 'moderate'
    CHECK (activity_level IN ('sedentary','light','moderate','active','very_active')),
  goal         TEXT NOT NULL DEFAULT 'maintain'
    CHECK (goal IN ('lose_fat','maintain','gain_muscle')),
  target_calories DECIMAL(7,2) NOT NULL DEFAULT 2000,
  target_protein  DECIMAL(6,2) NOT NULL DEFAULT 150,
  target_carbs    DECIMAL(6,2) NOT NULL DEFAULT 200,
  target_fat      DECIMAL(6,2) NOT NULL DEFAULT 65,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── 3. COMIDAS / RECETAS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS meals (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name            TEXT NOT NULL,
  description     TEXT DEFAULT '',
  image_url       TEXT DEFAULT '',
  calories        DECIMAL(7,2) NOT NULL DEFAULT 0 CHECK (calories >= 0),
  protein         DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (protein >= 0),
  carbs           DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (carbs >= 0),
  fat             DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (fat >= 0),
  prep_time_minutes INTEGER DEFAULT 15 CHECK (prep_time_minutes >= 0),
  difficulty      TEXT DEFAULT 'easy' CHECK (difficulty IN ('easy','medium','hard')),
  meal_type       TEXT NOT NULL CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
  ingredients     JSONB DEFAULT '[]',
  steps           JSONB DEFAULT '[]',
  tags            JSONB DEFAULT '[]',
  is_public       BOOLEAN DEFAULT TRUE,
  created_by      UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ── 4. REGISTRO DIARIO DE COMIDAS ────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_logs (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  meal_id             UUID REFERENCES meals(id) ON DELETE SET NULL,
  custom_name         TEXT,
  custom_calories     DECIMAL(7,2) CHECK (custom_calories >= 0),
  custom_protein      DECIMAL(6,2) CHECK (custom_protein >= 0),
  custom_carbs        DECIMAL(6,2) CHECK (custom_carbs >= 0),
  custom_fat          DECIMAL(6,2) CHECK (custom_fat >= 0),
  meal_type           TEXT NOT NULL CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
  portion_multiplier  DECIMAL(4,2) DEFAULT 1.0 CHECK (portion_multiplier > 0),
  logged_at           TIMESTAMPTZ DEFAULT NOW(),
  date                DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ── 5. EJERCICIOS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exercises (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         TEXT NOT NULL,
  muscle_group TEXT NOT NULL,
  equipment    TEXT DEFAULT 'Sin equipamiento',
  image_url    TEXT DEFAULT '',
  description  TEXT DEFAULT '',
  difficulty   TEXT DEFAULT 'medium' CHECK (difficulty IN ('easy','medium','hard')),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ── 6. SESIONES DE ENTRENAMIENTO ─────────────────────────────────
CREATE TABLE IF NOT EXISTS workouts (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name             TEXT NOT NULL DEFAULT 'Entrenamiento',
  date             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  duration_minutes INTEGER DEFAULT 0 CHECK (duration_minutes >= 0),
  is_completed     BOOLEAN DEFAULT FALSE,
  notes            TEXT DEFAULT '',
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ── 7. EJERCICIOS EN SESIÓN ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS workout_exercises (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id     UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id    UUID REFERENCES exercises(id) ON DELETE SET NULL,
  exercise_order INTEGER DEFAULT 0,
  notes          TEXT DEFAULT ''
);

-- ── 8. SERIES ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS workout_sets (
  id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_exercise_id  UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
  set_number           INTEGER NOT NULL CHECK (set_number > 0),
  reps                 INTEGER NOT NULL DEFAULT 0 CHECK (reps >= 0),
  weight_kg            DECIMAL(6,2) DEFAULT 0 CHECK (weight_kg >= 0),
  is_completed         BOOLEAN DEFAULT FALSE,
  rpe                  INTEGER CHECK (rpe BETWEEN 1 AND 10),
  notes                TEXT DEFAULT ''
);

-- ── 9. LISTAS DE COMPRA ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS shopping_lists (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  week_label   TEXT NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 10. ARTÍCULOS DE COMPRA ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS shopping_items (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,
  category         TEXT NOT NULL DEFAULT 'other',
  quantity         DECIMAL(8,2) DEFAULT 1 CHECK (quantity >= 0),
  unit             TEXT DEFAULT 'unidad',
  is_checked       BOOLEAN DEFAULT FALSE,
  meal_source      TEXT DEFAULT ''
);

-- ================================================================
-- ROW LEVEL SECURITY (RLS)
-- ================================================================

ALTER TABLE user_profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_logs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts          ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets      ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_lists    ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items    ENABLE ROW LEVEL SECURITY;

-- user_profiles
CREATE POLICY "profile_select" ON user_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "profile_insert" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "profile_update" ON user_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "profile_delete" ON user_profiles FOR DELETE USING (auth.uid() = user_id);

-- daily_logs
CREATE POLICY "logs_all"  ON daily_logs FOR ALL USING (auth.uid() = user_id);

-- workouts
CREATE POLICY "workouts_all" ON workouts FOR ALL USING (auth.uid() = user_id);

-- workout_exercises (acceso via workout)
CREATE POLICY "we_all" ON workout_exercises FOR ALL
  USING (workout_id IN (SELECT id FROM workouts WHERE user_id = auth.uid()));

-- workout_sets (acceso via workout_exercise → workout)
CREATE POLICY "ws_all" ON workout_sets FOR ALL
  USING (workout_exercise_id IN (
    SELECT we.id FROM workout_exercises we
    JOIN workouts w ON w.id = we.workout_id
    WHERE w.user_id = auth.uid()
  ));

-- shopping_lists
CREATE POLICY "sl_all" ON shopping_lists FOR ALL USING (auth.uid() = user_id);

-- shopping_items
CREATE POLICY "si_all" ON shopping_items FOR ALL
  USING (shopping_list_id IN (
    SELECT id FROM shopping_lists WHERE user_id = auth.uid()
  ));

-- meals (lectura pública, escritura solo del creador)
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "meals_read"   ON meals FOR SELECT USING (is_public = TRUE OR auth.uid() = created_by);
CREATE POLICY "meals_insert" ON meals FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "meals_update" ON meals FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "meals_delete" ON meals FOR DELETE USING (auth.uid() = created_by);

-- ================================================================
-- FUNCIONES SQL
-- ================================================================

-- Nutrición diaria total del usuario
CREATE OR REPLACE FUNCTION get_daily_nutrition(p_user_id UUID, p_date DATE)
RETURNS TABLE(
  total_calories DECIMAL,
  total_protein  DECIMAL,
  total_carbs    DECIMAL,
  total_fat      DECIMAL,
  meal_count     BIGINT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(
      CASE WHEN dl.meal_id IS NOT NULL
           THEN m.calories * dl.portion_multiplier
           ELSE COALESCE(dl.custom_calories, 0) END
    ), 0) AS total_calories,
    COALESCE(SUM(
      CASE WHEN dl.meal_id IS NOT NULL
           THEN m.protein * dl.portion_multiplier
           ELSE COALESCE(dl.custom_protein, 0) END
    ), 0) AS total_protein,
    COALESCE(SUM(
      CASE WHEN dl.meal_id IS NOT NULL
           THEN m.carbs * dl.portion_multiplier
           ELSE COALESCE(dl.custom_carbs, 0) END
    ), 0) AS total_carbs,
    COALESCE(SUM(
      CASE WHEN dl.meal_id IS NOT NULL
           THEN m.fat * dl.portion_multiplier
           ELSE COALESCE(dl.custom_fat, 0) END
    ), 0) AS total_fat,
    COUNT(dl.id) AS meal_count
  FROM daily_logs dl
  LEFT JOIN meals m ON m.id = dl.meal_id
  WHERE dl.user_id = p_user_id
    AND dl.date = p_date;
END;
$$;

-- Historial de volumen de un ejercicio
CREATE OR REPLACE FUNCTION get_exercise_history(p_user_id UUID, p_exercise_id UUID, p_limit INT DEFAULT 10)
RETURNS TABLE(
  workout_date TIMESTAMPTZ,
  avg_weight   DECIMAL,
  total_volume DECIMAL,
  total_reps   BIGINT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    w.date                        AS workout_date,
    AVG(ws.weight_kg)             AS avg_weight,
    SUM(ws.reps * ws.weight_kg)   AS total_volume,
    SUM(ws.reps)::BIGINT          AS total_reps
  FROM workout_sets ws
  JOIN workout_exercises we ON we.id = ws.workout_exercise_id
  JOIN workouts w ON w.id = we.workout_id
  WHERE w.user_id    = p_user_id
    AND we.exercise_id = p_exercise_id
    AND ws.is_completed = TRUE
    AND w.is_completed  = TRUE
  GROUP BY w.date
  ORDER BY w.date DESC
  LIMIT p_limit;
END;
$$;

-- Detectar ejercicios listos para progresión
CREATE OR REPLACE FUNCTION get_progression_suggestions(p_user_id UUID)
RETURNS TABLE(
  exercise_id       UUID,
  exercise_name     TEXT,
  current_weight    DECIMAL,
  suggested_weight  DECIMAL,
  sessions_count    BIGINT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  WITH recent_sessions AS (
    SELECT
      we.exercise_id,
      e.name AS exercise_name,
      AVG(ws.weight_kg) AS avg_weight,
      BOOL_AND(ws.is_completed) AS all_completed,
      COUNT(DISTINCT w.id) AS session_count,
      ROW_NUMBER() OVER (PARTITION BY we.exercise_id ORDER BY MAX(w.date) DESC) AS rn
    FROM workout_sets ws
    JOIN workout_exercises we ON we.id = ws.workout_exercise_id
    JOIN workouts w ON w.id = we.workout_id
    JOIN exercises e ON e.id = we.exercise_id
    WHERE w.user_id = p_user_id
      AND w.is_completed = TRUE
    GROUP BY we.exercise_id, e.name
  )
  SELECT
    rs.exercise_id,
    rs.exercise_name,
    rs.avg_weight AS current_weight,
    CASE
      WHEN rs.avg_weight > 40 THEN rs.avg_weight + 5
      ELSE rs.avg_weight + 2.5
    END AS suggested_weight,
    rs.session_count
  FROM recent_sessions rs
  WHERE rs.rn = 1
    AND rs.all_completed = TRUE
    AND rs.session_count >= 3
    AND rs.avg_weight > 0;
END;
$$;

-- Trigger: actualizar updated_at en user_profiles
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ================================================================
-- ÍNDICES DE RENDIMIENTO
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_daily_logs_user_date   ON daily_logs(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_workouts_user_date     ON workouts(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_workout_ex_workout     ON workout_exercises(workout_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_ex        ON workout_sets(workout_exercise_id);
CREATE INDEX IF NOT EXISTS idx_meals_type             ON meals(meal_type) WHERE is_public = TRUE;
CREATE INDEX IF NOT EXISTS idx_shopping_items_list    ON shopping_items(shopping_list_id);
CREATE INDEX IF NOT EXISTS idx_shopping_lists_user    ON shopping_lists(user_id);

-- ================================================================
-- DATOS INICIALES: Ejercicios (igual que mock_exercises.dart)
-- ================================================================
INSERT INTO exercises (id, name, muscle_group, equipment, description, difficulty) VALUES
  ('00000001-0000-0000-0000-000000000001', 'Press de Banca',              'chest',     'Barra',              'Ejercicio compuesto fundamental para el pecho.',         'medium'),
  ('00000001-0000-0000-0000-000000000002', 'Press Inclinado con Mancuernas','chest',   'Mancuernas',         'Trabaja la parte superior del pecho.',                   'medium'),
  ('00000001-0000-0000-0000-000000000003', 'Aperturas con Mancuernas',    'chest',     'Mancuernas',         'Aislamiento del pecho.',                                 'easy'),
  ('00000001-0000-0000-0000-000000000004', 'Dominadas',                   'back',      'Barra Dominadas',    'Ejercicio de tracción compuesto.',                       'hard'),
  ('00000001-0000-0000-0000-000000000005', 'Remo con Barra',              'back',      'Barra',              'Trabaja el grosor de la espalda.',                       'medium'),
  ('00000001-0000-0000-0000-000000000006', 'Jalón al Pecho',              'back',      'Polea',              'Alternativa a las dominadas.',                           'easy'),
  ('00000001-0000-0000-0000-000000000007', 'Press Militar',               'shoulders', 'Barra',              'Compuesto de hombros.',                                  'medium'),
  ('00000001-0000-0000-0000-000000000008', 'Elevaciones Laterales',       'shoulders', 'Mancuernas',         'Aislamiento del deltoides medio.',                       'easy'),
  ('00000001-0000-0000-0000-000000000009', 'Sentadilla con Barra',        'legs',      'Barra',              'Rey de los ejercicios.',                                 'hard'),
  ('00000001-0000-0000-0000-000000000010', 'Peso Muerto',                 'back',      'Barra',              'Compuesto total.',                                       'hard'),
  ('00000001-0000-0000-0000-000000000011', 'Prensa de Pierna',            'legs',      'Máquina',            'Trabaja cuádriceps.',                                    'easy'),
  ('00000001-0000-0000-0000-000000000012', 'Extensión de Cuádriceps',     'legs',      'Máquina',            'Aislamiento de cuádriceps.',                             'easy'),
  ('00000001-0000-0000-0000-000000000013', 'Curl Femoral',                'legs',      'Máquina',            'Aislamiento de isquiotibiales.',                         'easy'),
  ('00000001-0000-0000-0000-000000000014', 'Hip Thrust',                  'glutes',    'Barra',              'El ejercicio más efectivo para glúteos.',                'medium'),
  ('00000001-0000-0000-0000-000000000015', 'Curl de Bíceps',              'biceps',    'Mancuernas',         'Aislamiento clásico de bíceps.',                         'easy'),
  ('00000001-0000-0000-0000-000000000016', 'Curl Martillo',               'biceps',    'Mancuernas',         'Trabaja bíceps braquial.',                               'easy'),
  ('00000001-0000-0000-0000-000000000017', 'Press Francés',               'triceps',   'Barra',              'Aislamiento de cabeza larga del tríceps.',               'medium'),
  ('00000001-0000-0000-0000-000000000018', 'Fondos en Paralelas',         'triceps',   'Paralelas',          'Compuesto que trabaja tríceps y pecho.',                 'medium'),
  ('00000001-0000-0000-0000-000000000019', 'Plancha',                     'core',      'Sin equipamiento',   'Ejercicio isométrico fundamental para core.',            'easy'),
  ('00000001-0000-0000-0000-000000000020', 'Rueda Abdominal',             'core',      'Rueda Ab',           'Ejercicio avanzado para core completo.',                 'hard')
ON CONFLICT (id) DO NOTHING;

-- ================================================================
-- VERIFICACIÓN FINAL
-- ================================================================
SELECT
  table_name,
  pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) AS size
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
