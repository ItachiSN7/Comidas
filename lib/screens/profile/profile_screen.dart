import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/macro_progress_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final profile = userProvider.profile;
          if (profile == null) return const SizedBox.shrink();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                title: const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _showEditProfile(context, userProvider),
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // ── Avatar & Name ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Colors.black, size: 36),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userProvider.isAuthenticated
                                        ? (userProvider.currentUser?.email ?? profile.goalLabel)
                                        : profile.goalLabel,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _ProfileTag('${profile.weightKg.toInt()} kg'),
                                      const SizedBox(width: 6),
                                      _ProfileTag('${profile.heightCm.toInt()} cm'),
                                      const SizedBox(width: 6),
                                      _ProfileTag('${profile.age} años'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Daily Targets ──────────────────────────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Objetivos Diarios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _TargetCard(
                                    label: 'Calorías',
                                    value: '${profile.targetCalories.toInt()}',
                                    unit: 'kcal',
                                    color: AppColors.caloriesColor,
                                    icon: Icons.local_fire_department,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _TargetCard(
                                    label: 'Proteínas',
                                    value: '${profile.targetProtein.toInt()}',
                                    unit: 'g',
                                    color: AppColors.proteinColor,
                                    icon: Icons.egg_alt_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _TargetCard(
                                    label: 'Carbohidratos',
                                    value: '${profile.targetCarbs.toInt()}',
                                    unit: 'g',
                                    color: AppColors.carbsColor,
                                    icon: Icons.grain,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _TargetCard(
                                    label: 'Grasas',
                                    value: '${profile.targetFat.toInt()}',
                                    unit: 'g',
                                    color: AppColors.fatColor,
                                    icon: Icons.water_drop_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Body Stats ─────────────────────────────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estadísticas Corporales',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _BodyStat('Peso actual', '${profile.weightKg} kg'),
                            _BodyStat('Altura', '${profile.heightCm} cm'),
                            _BodyStat('Edad', '${profile.age} años'),
                            _BodyStat('Sexo', profile.gender == 'male' ? 'Masculino' : 'Femenino'),
                            _BodyStat('Nivel de Actividad', profile.activityLabel),
                            _BodyStat('Objetivo', profile.goalLabel),
                            // BMI
                            _BodyStat(
                              'IMC',
                              _calculateBMI(profile.weightKg, profile.heightCm),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Settings ───────────────────────────────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            _SettingsRow(
                              icon: Icons.notifications_outlined,
                              label: 'Notificaciones',
                              color: AppColors.secondary,
                              onTap: () {},
                            ),
                            _SettingsRow(
                              icon: Icons.share_outlined,
                              label: 'Compartir Progreso',
                              color: AppColors.accentPurple,
                              onTap: () {},
                            ),
                            _SettingsRow(
                              icon: Icons.sync_outlined,
                              label: 'Sincronizar datos hoy',
                              color: AppColors.accentOrange,
                              onTap: () => _syncToday(context),
                            ),
                            _SettingsRow(
                              icon: Icons.info_outline,
                              label: 'Acerca de Comidas',
                              color: AppColors.textTertiary,
                              onTap: () => _showAbout(context),
                            ),
                            if (userProvider.isAuthenticated)
                              _SettingsRow(
                                icon: Icons.logout,
                                label: 'Cerrar Sesión',
                                color: AppColors.accentOrange,
                                onTap: () => _confirmSignOut(context, userProvider),
                                isDestructive: false,
                              ),
                            _SettingsRow(
                              icon: Icons.delete_forever_outlined,
                              label: 'Reiniciar Perfil',
                              color: AppColors.error,
                              onTap: () => _confirmReset(context, userProvider),
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        'Comidas v1.0.0\nFitness & Nutrición Premium',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _calculateBMI(double weight, double height) {
    final heightM = height / 100;
    final bmi = weight / (heightM * heightM);
    String category;
    if (bmi < 18.5) category = 'Bajo peso';
    else if (bmi < 25) category = 'Normal';
    else if (bmi < 30) category = 'Sobrepeso';
    else category = 'Obesidad';
    return '${bmi.toStringAsFixed(1)} ($category)';
  }

  Future<void> _syncToday(BuildContext context) async {
    final nutrition = context.read<NutritionProvider>();
    await nutrition.loadFromSupabase(DateTime.now());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos sincronizados ✓'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Comidas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        content: const Text(
          'v1.0.0 — Fitness & Nutrición Premium\n\nDesarrollado con Flutter + Supabase.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Tus datos quedan guardados en la nube. Puedes volver a iniciar sesión cuando quieras.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.signOut();
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.accentOrange)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reiniciar Perfil', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          '¿Estás seguro? Se eliminarán todos tus datos.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              provider.resetProfile();
              Navigator.pop(context);
            },
            child: const Text('Reiniciar', style: TextStyle(color: AppColors.caloriesColor)),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, UserProvider provider) {
    // Simplified edit - just shows info for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edición de perfil disponible próximamente'),
        backgroundColor: AppColors.cardBg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ProfileTag extends StatelessWidget {
  final String label;

  const _ProfileTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _TargetCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _BodyStat extends StatelessWidget {
  final String label;
  final String value;

  const _BodyStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? AppColors.caloriesColor : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
