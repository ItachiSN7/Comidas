import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/shopping_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize Supabase (replace with your actual keys)
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://your-project.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'your-anon-key',
    ),
  );

  runApp(const ComidasApp());
}

class ComidasApp extends StatelessWidget {
  const ComidasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadProfile()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
      ],
      child: MaterialApp(
        title: 'Comidas',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const _SplashScreen();
        }
        if (!userProvider.isOnboarded) {
          return const OnboardingScreen();
        }
        return const MainNavScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🥗', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Comidas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fitness & Nutrición Premium',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
