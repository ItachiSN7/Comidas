import 'package:flutter/foundation.dart';
import '../models/shopping_item.dart';
import '../data/mock_shopping.dart';

class ShoppingProvider extends ChangeNotifier {
  ShoppingList? _currentList;

  ShoppingList? get currentList => _currentList;

  void generateList() {
    _currentList = generateWeeklyShoppingList([]);
    notifyListeners();
  }

  void toggleItem(String itemId) {
    if (_currentList == null) return;
    final items = _currentList!.items.map((item) {
      if (item.id == itemId) return item.copyWith(isChecked: !item.isChecked);
      return item;
    }).toList();
    _currentList = ShoppingList(
      id: _currentList!.id,
      weekLabel: _currentList!.weekLabel,
      items: items,
      generatedAt: _currentList!.generatedAt,
    );
    notifyListeners();
  }

  void addCustomItem(String name, String category) {
    if (_currentList == null) return;
    final newItem = ShoppingItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      quantity: 1,
      unit: 'unidad',
    );
    _currentList = ShoppingList(
      id: _currentList!.id,
      weekLabel: _currentList!.weekLabel,
      items: [..._currentList!.items, newItem],
      generatedAt: _currentList!.generatedAt,
    );
    notifyListeners();
  }

  void clearChecked() {
    if (_currentList == null) return;
    final items = _currentList!.items.where((i) => !i.isChecked).toList();
    _currentList = ShoppingList(
      id: _currentList!.id,
      weekLabel: _currentList!.weekLabel,
      items: items,
      generatedAt: _currentList!.generatedAt,
    );
    notifyListeners();
  }
}
