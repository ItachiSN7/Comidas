import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_meals.dart';
import '../../models/meal.dart';
import '../../widgets/glass_card.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'Todo'},
    {'id': 'breakfast', 'label': '🌅 Desayuno'},
    {'id': 'lunch', 'label': '☀️ Comida'},
    {'id': 'dinner', 'label': '🌙 Cena'},
    {'id': 'snack', 'label': '⚡ Snack'},
  ];

  List<Meal> get _filteredMeals {
    var meals = mockMeals;
    if (_selectedFilter != 'all') {
      meals = meals.where((m) => m.mealType == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      meals = meals.where((m) =>
          m.name.toLowerCase().contains(query) ||
          m.tags.any((t) => t.toLowerCase().contains(query))).toList();
    }
    return meals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: const Text(
              'Recetas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar recetas...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: const Icon(Icons.close, color: AppColors.textTertiary),
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Filter chips
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilter == filter['id'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter['id']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            child: Text(
                              filter['label']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.black : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final meal = _filteredMeals[index];
                  return _RecipeGridCard(meal: meal);
                },
                childCount: _filteredMeals.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _RecipeGridCard extends StatelessWidget {
  final Meal meal;

  const _RecipeGridCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(meal: meal)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      meal.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardBg2,
                        child: const Icon(Icons.restaurant, color: AppColors.textMuted, size: 32),
                      ),
                    ),
                  ),
                  // Meal type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        meal.mealTypeLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            size: 11, color: AppColors.caloriesColor),
                        const SizedBox(width: 2),
                        Text(
                          '${meal.calories.toInt()} kcal',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.caloriesColor,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.timer_outlined, size: 11, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Text(
                          '${meal.prepTimeMinutes}m',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MiniMacro('P', '${meal.protein.toInt()}g', AppColors.proteinColor),
                        const SizedBox(width: 3),
                        _MiniMacro('C', '${meal.carbs.toInt()}g', AppColors.carbsColor),
                        const SizedBox(width: 3),
                        _MiniMacro('G', '${meal.fat.toInt()}g', AppColors.fatColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMacro(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label$value',
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
