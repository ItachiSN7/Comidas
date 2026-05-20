import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import 'profile_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      emoji: '🎯',
      title: 'Tu Nutrición,\nInteligente',
      subtitle:
          'Calcula tus calorías y macros automáticamente según tu objetivo. Recomendaciones personalizadas que se adaptan a ti.',
      gradientColors: [Color(0xFF00FF87), Color(0xFF00D4FF)],
    ),
    _OnboardingPage(
      emoji: '🍽️',
      title: 'Recetas que\nte Encantan',
      subtitle:
          'Descubre recetas deliciosas adaptadas a tus macros restantes del día. Cuanto más comes, más se ajustan.',
      gradientColors: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
    ),
    _OnboardingPage(
      emoji: '💪',
      title: 'Entrena con\nInteligencia',
      subtitle:
          'Registra tus rutinas, sigue tu progresión y recibe sugerencias automáticas de aumento de peso.',
      gradientColors: [Color(0xFFA55EEA), Color(0xFF6C63FF)],
    ),
    _OnboardingPage(
      emoji: '🛒',
      title: 'Compra de\nForma Simple',
      subtitle:
          'Genera tu lista de compra semanal automáticamente basada en tus recetas y objetivos.',
      gradientColors: [Color(0xFF00D4FF), Color(0xFF6C63FF)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: page.gradientColors,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, index) => _OnboardingPageView(page: _pages[index]),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _currentPage ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.textMuted,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: page.gradientColors[0].withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Comenzar mi Journey'
                              : 'Siguiente',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _navigateToSetup,
                      child: const Text(
                        'Saltar',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _navigateToSetup();
    }
  }

  void _navigateToSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big emoji in gradient container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: page.gradientColors[0].withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
