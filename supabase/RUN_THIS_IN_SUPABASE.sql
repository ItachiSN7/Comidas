-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  COMIDAS APP — Setup completo de base de datos                  ║
-- ║                                                                  ║
-- ║  CÓMO EJECUTAR:                                                  ║
-- ║  1. Ve a https://supabase.com/dashboard/project/                ║
-- ║     ojbsbailordibjlekoyk/sql/new                                 ║
-- ║  2. Selecciona TODO este archivo (Ctrl+A)                        ║
-- ║  3. Pégalo en el editor SQL                                      ║
-- ║  4. Click "Run" (o Ctrl+Enter)                                   ║
-- ║  ✅ Listo — verás las tablas creadas al final                    ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── PERFILES ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_profiles (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  name            TEXT NOT NULL DEFAULT 'Usuario',
  weight_kg       DECIMAL(5,2) NOT NULL DEFAULT 70,
  height_cm       DECIMAL(5,1) NOT NULL DEFAULT 170,
  age             INTEGER NOT NULL DEFAULT 25 CHECK (age BETWEEN 10 AND 120),
  gender          TEXT NOT NULL DEFAULT 'male'
                  CHECK (gender IN ('male','female')),
  activity_level  TEXT NOT NULL DEFAULT 'moderate'
                  CHECK (activity_level IN ('sedentary','light','moderate','active','very_active')),
  goal            TEXT NOT NULL DEFAULT 'maintain'
                  CHECK (goal IN ('lose_fat','maintain','gain_muscle')),
  target_calories DECIMAL(7,2) NOT NULL DEFAULT 2000,
  target_protein  DECIMAL(6,2) NOT NULL DEFAULT 150,
  target_carbs    DECIMAL(6,2) NOT NULL DEFAULT 200,
  target_fat      DECIMAL(6,2) NOT NULL DEFAULT 65,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ── RECETAS ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS meals (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name              TEXT NOT NULL,
  description       TEXT DEFAULT '',
  image_url         TEXT DEFAULT '',
  calories          DECIMAL(7,2) NOT NULL DEFAULT 0 CHECK (calories >= 0),
  protein           DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (protein >= 0),
  carbs             DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (carbs >= 0),
  fat               DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (fat >= 0),
  prep_time_minutes INTEGER DEFAULT 15,
  difficulty        TEXT DEFAULT 'easy' CHECK (difficulty IN ('easy','medium','hard')),
  meal_type         TEXT NOT NULL CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
  ingredients       JSONB DEFAULT '[]',
  steps             JSONB DEFAULT '[]',
  tags              JSONB DEFAULT '[]',
  is_public         BOOLEAN DEFAULT TRUE,
  created_by        UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ── REGISTRO DIARIO ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_logs (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id            UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  meal_id            UUID REFERENCES meals(id) ON DELETE SET NULL,
  custom_name        TEXT,
  custom_calories    DECIMAL(7,2) CHECK (custom_calories >= 0),
  custom_protein     DECIMAL(6,2) CHECK (custom_protein >= 0),
  custom_carbs       DECIMAL(6,2) CHECK (custom_carbs >= 0),
  custom_fat         DECIMAL(6,2) CHECK (custom_fat >= 0),
  meal_type          TEXT NOT NULL CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
  portion_multiplier DECIMAL(4,2) DEFAULT 1.0 CHECK (portion_multiplier > 0),
  logged_at          TIMESTAMPTZ DEFAULT NOW(),
  date               DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ── EJERCICIOS ────────────────────────────────────────────────────
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

-- ── ENTRENAMIENTOS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS workouts (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name             TEXT NOT NULL DEFAULT 'Entrenamiento',
  date             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  duration_minutes INTEGER DEFAULT 0,
  is_completed     BOOLEAN DEFAULT FALSE,
  notes            TEXT DEFAULT '',
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS workout_exercises (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id     UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id    UUID REFERENCES exercises(id) ON DELETE SET NULL,
  exercise_order INTEGER DEFAULT 0,
  notes          TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS workout_sets (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
  set_number          INTEGER NOT NULL,
  reps                INTEGER NOT NULL DEFAULT 0,
  weight_kg           DECIMAL(6,2) DEFAULT 0,
  is_completed        BOOLEAN DEFAULT FALSE,
  rpe                 INTEGER CHECK (rpe BETWEEN 1 AND 10),
  notes               TEXT DEFAULT ''
);

-- ── LISTA DE COMPRA ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS shopping_lists (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  week_label   TEXT NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS shopping_items (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,
  category         TEXT NOT NULL DEFAULT 'other',
  quantity         DECIMAL(8,2) DEFAULT 1,
  unit             TEXT DEFAULT 'unidad',
  is_checked       BOOLEAN DEFAULT FALSE,
  meal_source      TEXT DEFAULT ''
);

-- ── RLS (Row Level Security) ──────────────────────────────────────
ALTER TABLE user_profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE meals              ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_logs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts          ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets      ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_lists    ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items    ENABLE ROW LEVEL SECURITY;

-- user_profiles
CREATE POLICY "profiles_select" ON user_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "profiles_insert" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "profiles_update" ON user_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "profiles_delete" ON user_profiles FOR DELETE USING (auth.uid() = user_id);

-- meals (públicas para lectura)
CREATE POLICY "meals_read"   ON meals FOR SELECT USING (is_public OR auth.uid() = created_by);
CREATE POLICY "meals_write"  ON meals FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "meals_update" ON meals FOR UPDATE USING (auth.uid() = created_by);

-- daily_logs
CREATE POLICY "logs_all" ON daily_logs FOR ALL USING (auth.uid() = user_id);

-- workouts
CREATE POLICY "workouts_all" ON workouts FOR ALL USING (auth.uid() = user_id);

-- workout_exercises
CREATE POLICY "we_all" ON workout_exercises FOR ALL USING (
  workout_id IN (SELECT id FROM workouts WHERE user_id = auth.uid())
);

-- workout_sets
CREATE POLICY "ws_all" ON workout_sets FOR ALL USING (
  workout_exercise_id IN (
    SELECT we.id FROM workout_exercises we
    JOIN workouts w ON w.id = we.workout_id
    WHERE w.user_id = auth.uid()
  )
);

-- shopping
CREATE POLICY "sl_all" ON shopping_lists FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "si_all" ON shopping_items FOR ALL USING (
  shopping_list_id IN (SELECT id FROM shopping_lists WHERE user_id = auth.uid())
);

-- ── FUNCIONES ─────────────────────────────────────────────────────

-- Nutrición diaria
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
    COALESCE(SUM(CASE WHEN dl.meal_id IS NOT NULL
      THEN m.calories * dl.portion_multiplier
      ELSE COALESCE(dl.custom_calories, 0) END), 0),
    COALESCE(SUM(CASE WHEN dl.meal_id IS NOT NULL
      THEN m.protein * dl.portion_multiplier
      ELSE COALESCE(dl.custom_protein, 0) END), 0),
    COALESCE(SUM(CASE WHEN dl.meal_id IS NOT NULL
      THEN m.carbs * dl.portion_multiplier
      ELSE COALESCE(dl.custom_carbs, 0) END), 0),
    COALESCE(SUM(CASE WHEN dl.meal_id IS NOT NULL
      THEN m.fat * dl.portion_multiplier
      ELSE COALESCE(dl.custom_fat, 0) END), 0),
    COUNT(dl.id)
  FROM daily_logs dl
  LEFT JOIN meals m ON m.id = dl.meal_id
  WHERE dl.user_id = p_user_id AND dl.date = p_date;
END; $$;

-- Historial de ejercicio
CREATE OR REPLACE FUNCTION get_exercise_history(
  p_user_id UUID, p_exercise_id UUID, p_limit INT DEFAULT 10
)
RETURNS TABLE(
  workout_date TIMESTAMPTZ,
  avg_weight   DECIMAL,
  total_volume DECIMAL,
  total_reps   BIGINT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    w.date,
    AVG(ws.weight_kg),
    SUM(ws.reps * ws.weight_kg),
    SUM(ws.reps)::BIGINT
  FROM workout_sets ws
  JOIN workout_exercises we ON we.id = ws.workout_exercise_id
  JOIN workouts w ON w.id = we.workout_id
  WHERE w.user_id = p_user_id
    AND we.exercise_id = p_exercise_id
    AND ws.is_completed = TRUE
    AND w.is_completed = TRUE
  GROUP BY w.date
  ORDER BY w.date DESC
  LIMIT p_limit;
END; $$;

-- Sugerencias de progresión
CREATE OR REPLACE FUNCTION get_progression_suggestions(p_user_id UUID)
RETURNS TABLE(
  exercise_id      UUID,
  exercise_name    TEXT,
  current_weight   DECIMAL,
  suggested_weight DECIMAL,
  sessions_count   BIGINT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  WITH stats AS (
    SELECT
      we.exercise_id,
      e.name,
      AVG(ws.weight_kg) AS avg_w,
      BOOL_AND(ws.is_completed) AS all_done,
      COUNT(DISTINCT w.id) AS sess_count
    FROM workout_sets ws
    JOIN workout_exercises we ON we.id = ws.workout_exercise_id
    JOIN workouts w ON w.id = we.workout_id
    JOIN exercises e ON e.id = we.exercise_id
    WHERE w.user_id = p_user_id AND w.is_completed = TRUE
    GROUP BY we.exercise_id, e.name
  )
  SELECT
    exercise_id,
    name,
    avg_w,
    CASE WHEN avg_w > 40 THEN avg_w + 5 ELSE avg_w + 2.5 END,
    sess_count
  FROM stats
  WHERE all_done = TRUE AND sess_count >= 3 AND avg_w > 0;
END; $$;

-- Trigger updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── ÍNDICES ────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_logs_user_date    ON daily_logs(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_workouts_user     ON workouts(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_we_workout        ON workout_exercises(workout_id);
CREATE INDEX IF NOT EXISTS idx_ws_exercise       ON workout_sets(workout_exercise_id);
CREATE INDEX IF NOT EXISTS idx_meals_type        ON meals(meal_type) WHERE is_public;
CREATE INDEX IF NOT EXISTS idx_si_list           ON shopping_items(shopping_list_id);

-- ── SEED: 20 Ejercicios ────────────────────────────────────────────
INSERT INTO exercises (name, muscle_group, equipment, description, difficulty) VALUES
  ('Press de Banca',              'chest',     'Barra',            'Ejercicio compuesto fundamental para el pecho.',   'medium'),
  ('Press Inclinado con Mancuernas','chest',   'Mancuernas',       'Trabaja la parte superior del pecho.',             'medium'),
  ('Aperturas con Mancuernas',    'chest',     'Mancuernas',       'Aislamiento del pecho.',                           'easy'),
  ('Dominadas',                   'back',      'Barra Dominadas',  'Ejercicio de tracción compuesto.',                 'hard'),
  ('Remo con Barra',              'back',      'Barra',            'Trabaja el grosor de la espalda.',                 'medium'),
  ('Jalón al Pecho',              'back',      'Polea',            'Alternativa a las dominadas.',                     'easy'),
  ('Press Militar',               'shoulders', 'Barra',            'Compuesto de hombros.',                            'medium'),
  ('Elevaciones Laterales',       'shoulders', 'Mancuernas',       'Aislamiento del deltoides medio.',                 'easy'),
  ('Sentadilla con Barra',        'legs',      'Barra',            'Rey de los ejercicios.',                           'hard'),
  ('Peso Muerto',                 'back',      'Barra',            'Compuesto total cuerpo.',                          'hard'),
  ('Prensa de Pierna',            'legs',      'Máquina',          'Trabaja cuádriceps.',                              'easy'),
  ('Extensión de Cuádriceps',     'legs',      'Máquina',          'Aislamiento de cuádriceps.',                       'easy'),
  ('Curl Femoral',                'legs',      'Máquina',          'Aislamiento de isquiotibiales.',                   'easy'),
  ('Hip Thrust',                  'glutes',    'Barra',            'El mejor ejercicio para glúteos.',                 'medium'),
  ('Curl de Bíceps',              'biceps',    'Mancuernas',       'Aislamiento clásico de bíceps.',                   'easy'),
  ('Curl Martillo',               'biceps',    'Mancuernas',       'Trabaja bíceps braquial.',                         'easy'),
  ('Press Francés',               'triceps',   'Barra',            'Aislamiento de cabeza larga del tríceps.',         'medium'),
  ('Fondos en Paralelas',         'triceps',   'Paralelas',        'Compuesto tríceps y pecho.',                       'medium'),
  ('Plancha',                     'core',      'Sin equipamiento', 'Ejercicio isométrico fundamental.',                'easy'),
  ('Rueda Abdominal',             'core',      'Rueda Ab',         'Ejercicio avanzado para core.',                    'hard')
ON CONFLICT DO NOTHING;

-- ── VERIFICACIÓN FINAL ─────────────────────────────────────────────
SELECT
  table_name AS "📋 Tabla",
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_name = t.table_name AND table_schema = 'public') AS "columnas"
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
