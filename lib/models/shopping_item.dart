class ShoppingItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  bool isChecked;
  final String? mealSource;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.isChecked = false,
    this.mealSource,
  });

  String get categoryLabel {
    const labels = {
      'proteins': 'Proteínas',
      'vegetables': 'Verduras',
      'fruits': 'Frutas',
      'carbs': 'Carbohidratos',
      'snacks': 'Snacks',
      'dairy': 'Lácteos',
      'condiments': 'Condimentos',
      'beverages': 'Bebidas',
    };
    return labels[category] ?? category;
  }

  ShoppingItem copyWith({bool? isChecked}) {
    return ShoppingItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      isChecked: isChecked ?? this.isChecked,
      mealSource: mealSource,
    );
  }
}

class ShoppingList {
  final String id;
  final String weekLabel;
  final List<ShoppingItem> items;
  final DateTime generatedAt;

  const ShoppingList({
    required this.id,
    required this.weekLabel,
    required this.items,
    required this.generatedAt,
  });

  Map<String, List<ShoppingItem>> get itemsByCategory {
    final grouped = <String, List<ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  int get totalItems => items.length;
  int get checkedItems => items.where((i) => i.isChecked).length;
  double get progress => totalItems > 0 ? checkedItems / totalItems : 0;
}
