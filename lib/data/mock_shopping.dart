import '../models/shopping_item.dart';

ShoppingList generateWeeklyShoppingList(List<String> selectedMealIds) {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));

  return ShoppingList(
    id: 'weekly_${now.millisecondsSinceEpoch}',
    weekLabel:
        '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}',
    items: _generateItems(),
    generatedAt: now,
  );
}

List<ShoppingItem> _generateItems() {
  return [
    // PROTEINS
    ShoppingItem(id: 'p1', name: 'Pechuga de Pollo', category: 'proteins', quantity: 1400, unit: 'g', mealSource: 'Pollo Teriyaki, Pollo con Brócoli'),
    ShoppingItem(id: 'p2', name: 'Salmón Fresco', category: 'proteins', quantity: 400, unit: 'g', mealSource: 'Ensalada Salmón, Salmón Teriyaki'),
    ShoppingItem(id: 'p3', name: 'Atún al Natural', category: 'proteins', quantity: 320, unit: 'g', mealSource: 'Pasta con Atún'),
    ShoppingItem(id: 'p4', name: 'Merluza', category: 'proteins', quantity: 400, unit: 'g', mealSource: 'Merluza al Horno'),
    ShoppingItem(id: 'p5', name: 'Huevos', category: 'proteins', quantity: 18, unit: 'unidades', mealSource: 'Tostadas, Tortilla'),
    ShoppingItem(id: 'p6', name: 'Proteína en Polvo', category: 'proteins', quantity: 1, unit: 'bote', mealSource: 'Avena Proteica, Batido'),
    ShoppingItem(id: 'p7', name: 'Tofu Firme', category: 'proteins', quantity: 400, unit: 'g', mealSource: 'Bol de Tofu'),
    ShoppingItem(id: 'p8', name: 'Pavo Ahumado', category: 'proteins', quantity: 240, unit: 'g', mealSource: 'Wrap de Pavo'),

    // VEGETABLES
    ShoppingItem(id: 'v1', name: 'Brócoli', category: 'vegetables', quantity: 800, unit: 'g', mealSource: 'Varios'),
    ShoppingItem(id: 'v2', name: 'Espinacas Baby', category: 'vegetables', quantity: 400, unit: 'g', mealSource: 'Tortilla, Batido Verde'),
    ShoppingItem(id: 'v3', name: 'Aguacate', category: 'vegetables', quantity: 4, unit: 'unidades', mealSource: 'Tostadas, Ensalada'),
    ShoppingItem(id: 'v4', name: 'Tomate Cherry', category: 'vegetables', quantity: 400, unit: 'g', mealSource: 'Pasta, Tortilla'),
    ShoppingItem(id: 'v5', name: 'Pimiento Rojo', category: 'vegetables', quantity: 3, unit: 'unidades', mealSource: 'Merluza, Curry'),
    ShoppingItem(id: 'v6', name: 'Pepino', category: 'vegetables', quantity: 3, unit: 'unidades', mealSource: 'Hummus, Wrap'),
    ShoppingItem(id: 'v7', name: 'Zanahoria', category: 'vegetables', quantity: 500, unit: 'g', mealSource: 'Hummus, Tofu'),
    ShoppingItem(id: 'v8', name: 'Espárragos', category: 'vegetables', quantity: 400, unit: 'g', mealSource: 'Salmón Teriyaki'),
    ShoppingItem(id: 'v9', name: 'Zucchini', category: 'vegetables', quantity: 2, unit: 'unidades', mealSource: 'Merluza al Horno'),
    ShoppingItem(id: 'v10', name: 'Lechuga Romana', category: 'vegetables', quantity: 1, unit: 'unidad', mealSource: 'Wrap'),

    // FRUITS
    ShoppingItem(id: 'f1', name: 'Plátano', category: 'fruits', quantity: 7, unit: 'unidades', mealSource: 'Avena, Batido'),
    ShoppingItem(id: 'f2', name: 'Frutos Rojos Mixtos', category: 'fruits', quantity: 600, unit: 'g', mealSource: 'Avena, Yogur'),
    ShoppingItem(id: 'f3', name: 'Fresas', category: 'fruits', quantity: 300, unit: 'g', mealSource: 'Yogur Griego'),
    ShoppingItem(id: 'f4', name: 'Limón', category: 'fruits', quantity: 5, unit: 'unidades', mealSource: 'Varios'),

    // CARBOHYDRATES
    ShoppingItem(id: 'c1', name: 'Arroz Integral', category: 'carbs', quantity: 1000, unit: 'g', mealSource: 'Pollo Teriyaki, Curry'),
    ShoppingItem(id: 'c2', name: 'Quinoa', category: 'carbs', quantity: 400, unit: 'g', mealSource: 'Ensalada Salmón'),
    ShoppingItem(id: 'c3', name: 'Avena', category: 'carbs', quantity: 800, unit: 'g', mealSource: 'Bowl Avena, Energy Balls'),
    ShoppingItem(id: 'c4', name: 'Pan Integral', category: 'carbs', quantity: 1, unit: 'barra', mealSource: 'Tostadas'),
    ShoppingItem(id: 'c5', name: 'Pasta Trigo Sarraceno', category: 'carbs', quantity: 500, unit: 'g', mealSource: 'Pasta con Atún'),
    ShoppingItem(id: 'c6', name: 'Tortillas Integrales', category: 'carbs', quantity: 8, unit: 'unidades', mealSource: 'Wrap de Pavo'),
    ShoppingItem(id: 'c7', name: 'Batata', category: 'carbs', quantity: 600, unit: 'g', mealSource: 'Pollo con Batata'),
    ShoppingItem(id: 'c8', name: 'Garbanzos Cocidos', category: 'carbs', quantity: 800, unit: 'g', mealSource: 'Curry, Hummus'),

    // DAIRY
    ShoppingItem(id: 'd1', name: 'Yogur Griego 0%', category: 'dairy', quantity: 1000, unit: 'g', mealSource: 'Yogur con Granola'),
    ShoppingItem(id: 'd2', name: 'Requesón', category: 'dairy', quantity: 400, unit: 'g', mealSource: 'Snack Requesón'),
    ShoppingItem(id: 'd3', name: 'Queso Cottage', category: 'dairy', quantity: 200, unit: 'g', mealSource: 'Tortilla Claras'),
    ShoppingItem(id: 'd4', name: 'Leche de Almendras', category: 'dairy', quantity: 1, unit: 'litro', mealSource: 'Avena Proteica'),
    ShoppingItem(id: 'd5', name: 'Leche de Coco', category: 'dairy', quantity: 400, unit: 'ml', mealSource: 'Curry, Batido'),

    // SNACKS
    ShoppingItem(id: 'sn1', name: 'Almendras', category: 'snacks', quantity: 200, unit: 'g', mealSource: 'Bowl Avena, Snacks'),
    ShoppingItem(id: 'sn2', name: 'Nueces', category: 'snacks', quantity: 150, unit: 'g', mealSource: 'Energy Balls, Yogur'),
    ShoppingItem(id: 'sn3', name: 'Granola Artesanal', category: 'snacks', quantity: 300, unit: 'g', mealSource: 'Yogur Griego'),
    ShoppingItem(id: 'sn4', name: 'Dátiles Medjool', category: 'snacks', quantity: 200, unit: 'g', mealSource: 'Energy Balls'),
    ShoppingItem(id: 'sn5', name: 'Cacao Puro en Polvo', category: 'snacks', quantity: 100, unit: 'g', mealSource: 'Energy Balls'),
    ShoppingItem(id: 'sn6', name: 'Mantequilla de Almendra', category: 'snacks', quantity: 1, unit: 'bote', mealSource: 'Batido Verde'),
  ];
}
