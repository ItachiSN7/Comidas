import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/workout_provider.dart';
import 'home/home_screen.dart';
import 'recipes/recipes_screen.dart';
import 'workout/workout_screen.dart';
import 'shopping/shopping_screen.dart';
import 'profile/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecipesScreen(),
    WorkoutScreen(),
    ShoppingScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Inicio'),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Recetas'),
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Gym'),
    _NavItem(icon: Icons.shopping_cart_rounded, label: 'Compra'),
    _NavItem(icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  void initState() {
    super.initState();
    // Load demo workout data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadDemoData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              item.icon,
                              size: isSelected ? 24 : 22,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
