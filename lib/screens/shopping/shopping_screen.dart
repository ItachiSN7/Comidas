import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/shopping_item.dart';
import '../../providers/shopping_provider.dart';
import '../../widgets/glass_card.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  static const _categoryOrder = [
    'proteins', 'vegetables', 'fruits', 'carbs', 'dairy', 'snacks', 'condiments', 'beverages'
  ];

  static const _categoryIcons = {
    'proteins': '🥩',
    'vegetables': '🥦',
    'fruits': '🍓',
    'carbs': '🍚',
    'dairy': '🥛',
    'snacks': '🥜',
    'condiments': '🧂',
    'beverages': '💧',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ShoppingProvider>(
        builder: (context, shoppingProvider, _) {
          final list = shoppingProvider.currentList;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                title: const Text(
                  'Lista de Compra',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                actions: [
                  if (list != null)
                    IconButton(
                      onPressed: () => _showAddItemSheet(context, shoppingProvider),
                      icon: const Icon(Icons.add, color: AppColors.primary),
                    ),
                  if (list != null && list.checkedItems > 0)
                    IconButton(
                      onPressed: () => shoppingProvider.clearChecked(),
                      icon: const Icon(Icons.delete_sweep, color: AppColors.textTertiary),
                    ),
                ],
              ),

              SliverToBoxAdapter(
                child: list == null
                    ? _EmptyShoppingState(onGenerate: () => shoppingProvider.generateList())
                    : _ShoppingListView(
                        list: list,
                        categoryOrder: _categoryOrder,
                        categoryIcons: _categoryIcons,
                        onToggle: shoppingProvider.toggleItem,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddItemSheet(BuildContext context, ShoppingProvider provider) {
    final nameCtrl = TextEditingController();
    String selectedCategory = 'proteins';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Añadir Artículo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Nombre del artículo'),
              ),
              const SizedBox(height: 12),
              // Category selector
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categoryOrder.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_categoryIcons[cat]} ${ShoppingItem(id: '', name: '', category: cat, quantity: 0, unit: '').categoryLabel}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      provider.addCustomItem(name, selectedCategory);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Añadir a la Lista'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyShoppingState extends StatelessWidget {
  final VoidCallback onGenerate;

  const _EmptyShoppingState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 56, color: Colors.black),
          ),
          const SizedBox(height: 24),
          const Text(
            'Lista de compra semanal',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Genera automáticamente tu lista basada en tus recetas de la semana, agrupada por categorías.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Feature highlights
          Row(
            children: [
              _FeatureChip('🥩 Proteínas'),
              const SizedBox(width: 8),
              _FeatureChip('🥦 Verduras'),
              const SizedBox(width: 8),
              _FeatureChip('🍓 Frutas'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _FeatureChip('🍚 Carbos'),
              const SizedBox(width: 8),
              _FeatureChip('🥛 Lácteos'),
              const SizedBox(width: 8),
              _FeatureChip('🥜 Snacks'),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Generar Lista Semanal'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ShoppingListView extends StatelessWidget {
  final dynamic list;
  final List<String> categoryOrder;
  final Map<String, String> categoryIcons;
  final void Function(String) onToggle;

  const _ShoppingListView({
    required this.list,
    required this.categoryOrder,
    required this.categoryIcons,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final categories = list.itemsByCategory as Map<String, List<dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semana ${list.weekLabel}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${list.checkedItems} de ${list.totalItems} artículos',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${(list.progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 400),
                      widthFactor: list.progress.toDouble(),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Category sections
        ...categoryOrder
            .where((cat) => categories.containsKey(cat))
            .map((cat) => _CategorySection(
                  icon: categoryIcons[cat] ?? '📦',
                  title: ShoppingItem(id: '', name: '', category: cat, quantity: 0, unit: '').categoryLabel,
                  items: categories[cat]!.cast<ShoppingItem>(),
                  onToggle: onToggle,
                )),

        const SizedBox(height: 100),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String icon;
  final String title;
  final List<ShoppingItem> items;
  final void Function(String) onToggle;

  const _CategorySection({
    required this.icon,
    required this.title,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final checkedCount = items.where((i) => i.isChecked).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$checkedCount/${items.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: () => onToggle(item.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: item.isChecked ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: item.isChecked ? AppColors.primary : AppColors.borderLight,
                                  width: 1.5,
                                ),
                              ),
                              child: item.isChecked
                                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: item.isChecked
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  decoration: item.isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            Text(
                              '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: AppColors.border,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
