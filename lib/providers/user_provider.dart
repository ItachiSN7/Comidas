import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../core/utils/calorie_calculator.dart';

enum AppAuthState { loading, unauthenticated, authenticated, offline }

class UserProvider extends ChangeNotifier {
  static final _client = Supabase.instance.client;

  UserProfile? _profile;
  AppAuthState _authState = AppAuthState.loading;
  bool _isOnboarded = false;
  StreamSubscription<AuthState>? _authSub;

  UserProfile? get profile => _profile;
  AppAuthState get authState => _authState;
  bool get isLoading => _authState == AppAuthState.loading;
  bool get isAuthenticated => _authState == AppAuthState.authenticated;
  bool get isOffline => _authState == AppAuthState.offline;
  bool get isOnboarded => _isOnboarded;
  User? get currentUser => _client.auth.currentUser;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    _authSub = _client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _loadFromSupabase();
      } else if (_authState != AppAuthState.offline) {
        await _loadLocal();
      }
    });

    final session = _client.auth.currentSession;
    if (session != null) {
      await _loadFromSupabase();
    } else {
      await _loadLocal();
    }
  }

  Future<void> _loadFromSupabase() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        _profile = UserProfile.fromMap(data);
        _isOnboarded = true;
      }
      _authState = AppAuthState.authenticated;
    } catch (_) {
      await _loadLocal();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboarded = prefs.getBool('is_onboarded') ?? false;
      final json = prefs.getString('user_profile');
      if (json != null) _profile = UserProfile.fromMap(jsonDecode(json));
      _authState = _client.auth.currentUser != null
          ? AppAuthState.authenticated
          : AppAuthState.unauthenticated;
    } catch (_) {
      _authState = AppAuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> loadProfile() => _init();

  // ── Auth actions ──────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _profile = null;
    _isOnboarded = false;
    _authState = AppAuthState.unauthenticated;
    notifyListeners();
  }

  void continueOffline() {
    _authState = AppAuthState.offline;
    notifyListeners();
  }

  // ── Profile management ────────────────────────────────────────────────────

  Future<void> createProfile({
    required String name,
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) async {
    final bmr = CalorieCalculator.calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    final tdee = CalorieCalculator.calculateTDEE(bmr: bmr, activityLevel: activityLevel);
    final targetCalories = CalorieCalculator.adjustCaloriesForGoal(tdee, goal);
    final macros = CalorieCalculator.calculateMacros(calories: targetCalories, goal: goal);

    _profile = UserProfile(
      id: currentUser?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
      targetCalories: targetCalories.roundToDouble(),
      targetProtein: macros['protein']!,
      targetCarbs: macros['carbs']!,
      targetFat: macros['fat']!,
    );

    _isOnboarded = true;
    await _persistProfile();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    await _persistProfile();
    notifyListeners();
  }

  Future<void> _persistProfile() async {
    final profile = _profile;
    if (profile == null) return;

    // Always save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);
    await prefs.setString('user_profile', jsonEncode(profile.toMap()));

    // Sync to Supabase if authenticated
    if (isAuthenticated && currentUser != null) {
      try {
        await _client.from('user_profiles').upsert({
          'user_id': currentUser!.id,
          'name': profile.name,
          'weight_kg': profile.weightKg,
          'height_cm': profile.heightCm,
          'age': profile.age,
          'gender': profile.gender,
          'activity_level': profile.activityLevel,
          'goal': profile.goal,
          'target_calories': profile.targetCalories,
          'target_protein': profile.targetProtein,
          'target_carbs': profile.targetCarbs,
          'target_fat': profile.targetFat,
        });
      } catch (_) {
        // offline — local save is enough
      }
    }
  }

  Future<void> resetProfile() async {
    _profile = null;
    _isOnboarded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (isAuthenticated) await signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
