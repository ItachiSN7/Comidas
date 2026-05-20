import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../main_nav_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form values
  final nameCtrl = TextEditingController(text: 'Usuario');
  double _weight = 75.0;
  double _height = 175.0;
  int _age = 28;
  String _gender = 'male';
  String _activityLevel = 'moderate';
  String _goal = 'maintain';

  final int _totalSteps = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Progress indicator
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_currentStep > 0)
                        GestureDetector(
                          onTap: _goBack,
                          child: const Icon(Icons.arrow_back_ios, color: AppColors.textSecondary, size: 18),
                        ),
                      const Spacer(),
                      Text(
                        '${_currentStep + 1} / $_totalSteps',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Step progress bar
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 400),
                        widthFactor: (_currentStep + 1) / _totalSteps,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNameStep(),
                _buildBodyStep(),
                _buildActivityStep(),
                _buildGoalStep(),
              ],
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNext,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _currentStep == _totalSteps - 1 ? 'Crear mi Perfil' : 'Continuar',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 20),
          const Text(
            '¿Cómo te\nllamamos?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tu nombre personalizará toda la experiencia de la app.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: nameCtrl,
            autofocus: true,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: 'Tu nombre',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📏', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 20),
          const Text(
            'Tu cuerpo,\ntus datos',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),

          // Gender selector
          const Text('Sexo', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _GenderButton(
                  label: '♂ Masculino',
                  isSelected: _gender == 'male',
                  onTap: () => setState(() => _gender = 'male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderButton(
                  label: '♀ Femenino',
                  isSelected: _gender == 'female',
                  onTap: () => setState(() => _gender = 'female'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Weight slider
          _SliderField(
            label: 'Peso',
            value: _weight,
            min: 40,
            max: 150,
            unit: 'kg',
            onChanged: (v) => setState(() => _weight = v),
          ),

          const SizedBox(height: 20),

          // Height slider
          _SliderField(
            label: 'Altura',
            value: _height,
            min: 140,
            max: 220,
            unit: 'cm',
            onChanged: (v) => setState(() => _height = v),
          ),

          const SizedBox(height: 20),

          // Age slider
          _SliderField(
            label: 'Edad',
            value: _age.toDouble(),
            min: 16,
            max: 80,
            unit: 'años',
            isInt: true,
            onChanged: (v) => setState(() => _age = v.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStep() {
    final levels = [
      {'id': 'sedentary', 'label': 'Sedentario', 'desc': 'Sin ejercicio o muy poco', 'emoji': '🛋️'},
      {'id': 'light', 'label': 'Ligero', 'desc': 'Ejercicio 1-3 días/semana', 'emoji': '🚶'},
      {'id': 'moderate', 'label': 'Moderado', 'desc': 'Ejercicio 3-5 días/semana', 'emoji': '🏃'},
      {'id': 'active', 'label': 'Activo', 'desc': 'Ejercicio fuerte 6-7 días', 'emoji': '⚡'},
      {'id': 'very_active', 'label': 'Muy Activo', 'desc': 'Atleta o trabajo físico', 'emoji': '🏆'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 20),
          const Text(
            'Nivel de\nActividad',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final level = levels[i];
                final isSelected = _activityLevel == level['id'];
                return GestureDetector(
                  onTap: () => setState(() => _activityLevel = level['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(level['emoji']!, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(level['label']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  )),
                              Text(level['desc']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  )),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    final goals = [
      {
        'id': 'lose_fat',
        'label': 'Perder Grasa',
        'desc': 'Déficit calórico de ~500 kcal/día',
        'emoji': '🔥',
        'gradient': AppColors.orangeGradient,
      },
      {
        'id': 'maintain',
        'label': 'Mantener Peso',
        'desc': 'Calorías de mantenimiento exactas',
        'emoji': '⚖️',
        'gradient': AppColors.primaryGradient,
      },
      {
        'id': 'gain_muscle',
        'label': 'Ganar Músculo',
        'desc': 'Superávit calórico de ~300 kcal/día',
        'emoji': '💪',
        'gradient': AppColors.purpleGradient,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 20),
          const Text(
            'Tu Objetivo\nPrincipal',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),
          ...goals.map((goal) {
            final isSelected = _goal == goal['id'];
            final gradient = goal['gradient'] as LinearGradient;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => setState(() => _goal = goal['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: isSelected ? gradient : null,
                    color: isSelected ? null : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: gradient.colors.first.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(goal['emoji'] as String, style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['label'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.black : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              goal['desc'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.black.withOpacity(0.7)
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.black, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _handleNext() async {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      setState(() => _isLoading = true);
      await context.read<UserProvider>().createProfile(
        name: nameCtrl.text.trim().isEmpty ? 'Usuario' : nameCtrl.text.trim(),
        weightKg: _weight,
        heightCm: _height,
        age: _age,
        gender: _gender,
        activityLevel: _activityLevel,
        goal: _goal,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
        );
      }
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    }
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final bool isInt;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.isInt = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: isInt ? value.toInt().toString() : value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: isInt ? (max - min).toInt() : null,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
