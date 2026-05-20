-- ================================================================
-- COMIDAS - Supabase PostgreSQL Schema
-- Fitness & Nutrition Premium App
-- ================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── USER PROFILES ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  weight_kg DECIMAL(5,2) NOT NULL,
  height_cm DECIMAL(5,1) NOT NULL,
  age INTEGER NOT NULL,
  gender TEXT CHECK (gender IN ('male', 'female')) NOT NULL,
  activity_level TEXT CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')) NOT NULL,
  goal TEXT CHECK (goal IN ('lose_fat', 'maintain', 'gain_muscle')) NOT NULL,
  target_calories DECIMAL(7,2) NOT NULL,
  target_protein DECIMAL(6,2) NOT NULL,
  target_carbs DECIMAL(6,2) NOT NULL,
  target_fat DECIMAL(6,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── MEALS ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS meals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  calories DECIMAL(7,2) NOT NULL,
  protein DECIMAL(6,2) NOT NULL,
  carbs DECIMAL(6,2) NOT NULL,
  fat DECIMAL(6,2) NOT NULL,
  prep_time_minutes INTEGER DEFAULT 0,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'easy',
  meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')) NOT NULL,
  ingredients JSONB DEFAULT '[]',
  steps JSONB DEFAULT '[]',
  tags JSONB DEFAULT '[]',
  is_public BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── DAILY LOGS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  meal_id UUID REFERENCES meals(id),
  custom_name TEXT,
  custom_calories DECIMAL(7,2),
  custom_protein DECIMAL(6,2),
  custom_carbs DECIMAL(6,2),
  custom_fat DECIMAL(6,2),
  meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')) NOT NULL,
  portion_multiplier DECIMAL(4,2) DEFAULT 1.0,
  logged_at TIMESTAMPTZ DEFAULT NOW(),
  date DATE DEFAULT CURRENT_DATE
);

-- ── EXERCISES ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  muscle_group TEXT NOT NULL,
  equipment TEXT,
  image_url TEXT,
  description TEXT,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── WORKOUTS ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  date TIMESTAMPTZ DEFAULT NOW(),
  duration_minutes INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── WORKOUT EXERCISES ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS workout_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
  exercise_id UUID REFERENCES exercises(id),
  exercise_order INTEGER DEFAULT 0,
  notes TEXT
);

-- ── WORKOUT SETS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS workout_sets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_exercise_id UUID REFERENCES workout_exercises(id) ON DELETE CASCADE,
  set_number INTEGER NOT NULL,
  reps INTEGER NOT NULL,
  weight_kg DECIMAL(6,2) DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  rpe INTEGER CHECK (rpe BETWEEN 1 AND 10),
  notes TEXT
);

-- ── SHOPPING LISTS ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS shopping_lists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  week_label TEXT NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── SHOPPING ITEMS ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS shopping_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shopping_list_id UUID REFERENCES shopping_lists(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  quantity DECIMAL(8,2) DEFAULT 1,
  unit TEXT DEFAULT 'unidad',
  is_checked BOOLEAN DEFAULT FALSE,
  meal_source TEXT
);

-- ── ROW LEVEL SECURITY ───────────────────────────────────────────
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can read own profile" ON user_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = user_id);

-- Daily logs policies
CREATE POLICY "Users can manage own logs" ON daily_logs FOR ALL USING (auth.uid() = user_id);

-- Workouts policies
CREATE POLICY "Users can manage own workouts" ON workouts FOR ALL USING (auth.uid() = user_id);

-- Workout exercises (via workout ownership)
CREATE POLICY "Users can manage workout exercises" ON workout_exercises FOR ALL
  USING (workout_id IN (SELECT id FROM workouts WHERE user_id = auth.uid()));

-- Workout sets (via workout ownership)
CREATE POLICY "Users can manage workout sets" ON workout_sets FOR ALL
  USING (workout_exercise_id IN (
    SELECT we.id FROM workout_exercises we
    JOIN workouts w ON w.id = we.workout_id
    WHERE w.user_id = auth.uid()
  ));

-- Shopping lists
CREATE POLICY "Users can manage own shopping lists" ON shopping_lists FOR ALL USING (auth.uid() = user_id);

-- Shopping items
CREATE POLICY "Users can manage own shopping items" ON shopping_items FOR ALL
  USING (shopping_list_id IN (SELECT id FROM shopping_lists WHERE user_id = auth.uid()));

-- Public meals readable by all authenticated users
CREATE POLICY "Anyone can read public meals" ON meals FOR SELECT USING (is_public = TRUE OR auth.uid() = created_by);

-- ── FUNCTIONS ────────────────────────────────────────────────────

-- Get daily nutrition summary
CREATE OR REPLACE FUNCTION get_daily_nutrition(p_user_id UUID, p_date DATE)
RETURNS TABLE(
  total_calories DECIMAL,
  total_protein DECIMAL,
  total_carbs DECIMAL,
  total_fat DECIMAL,
  meal_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(CASE WHEN dl.meal_id IS NOT NULL THEN m.calories * dl.portion_multiplier ELSE dl.custom_calories END), 0) as total_calories,
    COALESCE(SUM(CASE WHEN dl.meal_id IS NOT NULL THEN m.protein * dl.portion_multiplier ELSE dl.custom_protein END), 0) as total_protein,
    COALESCE(SUM(CASE WHEN dl.meal_id IS NOT NULL THEN m.carbs * dl.portion_multiplier ELSE dl.custom_carbs END), 0) as total_carbs,
    COALESCE(SUM(CASE WHEN dl.meal_id IS NOT NULL THEN m.fat * dl.portion_multiplier ELSE dl.custom_fat END), 0) as total_fat,
    COUNT(dl.id) as meal_count
  FROM daily_logs dl
  LEFT JOIN meals m ON m.id = dl.meal_id
  WHERE dl.user_id = p_user_id AND dl.date = p_date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get workout volume history for an exercise
CREATE OR REPLACE FUNCTION get_exercise_volume_history(p_user_id UUID, p_exercise_id UUID, p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
  workout_date TIMESTAMPTZ,
  avg_weight DECIMAL,
  total_volume DECIMAL,
  total_sets BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    w.date as workout_date,
    AVG(ws.weight_kg) as avg_weight,
    SUM(ws.reps * ws.weight_kg) as total_volume,
    COUNT(ws.id) as total_sets
  FROM workout_sets ws
  JOIN workout_exercises we ON we.id = ws.workout_exercise_id
  JOIN workouts w ON w.id = we.workout_id
  WHERE w.user_id = p_user_id
    AND we.exercise_id = p_exercise_id::UUID
    AND ws.is_completed = TRUE
  GROUP BY w.date
  ORDER BY w.date DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── INDEXES ──────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_daily_logs_user_date ON daily_logs(user_id, date);
CREATE INDEX IF NOT EXISTS idx_workouts_user_date ON workouts(user_id, date);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout ON workout_exercises(workout_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_exercise ON workout_sets(workout_exercise_id);
CREATE INDEX IF NOT EXISTS idx_meals_type ON meals(meal_type);
CREATE INDEX IF NOT EXISTS idx_shopping_items_list ON shopping_items(shopping_list_id);
