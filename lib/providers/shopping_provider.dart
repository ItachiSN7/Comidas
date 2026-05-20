import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shopping_item.dart';
import '../data/mock_shopping.dart';

class ShoppingProvider extends ChangeNotifier {
  static final _client = Supabase.instance.client;

  ShoppingList? _currentList;

  ShoppingList? get currentList => _currentList;

  Future<void> generateList() async {
    _currentList = generateWeeklyShoppingList([]);
    notifyListeners();
    await _syncList();
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
    _syncToggle(itemId, items.firstWhere((i) => i.id == itemId).isChecked);
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

  // ── Supabase sync ─────────────────────────────────────────────────────────

  Future<void> loadLatestFromSupabase() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final rows = await _client
          .from('shopping_lists')
          .select('*, shopping_items(*)')
          .eq('user_id', userId)
          .order('generated_at', ascending: false)
          .limit(1) as List;

      if (rows.isEmpty) return;
      final row = rows.first;
      final itemRows = row['shopping_items'] as List? ?? [];

      _currentList = ShoppingList(
        id: row['id'],
        weekLabel: row['week_label'],
        generatedAt: DateTime.parse(row['generated_at']),
        items: itemRows.map((i) => ShoppingItem(
          id: i['id'],
          name: i['name'],
          category: i['category'] ?? 'other',
          quantity: (i['quantity'] ?? 1).toDouble(),
          unit: i['unit'] ?? 'unidad',
          isChecked: i['is_checked'] ?? false,
          mealSource: i['meal_source'] ?? '',
        )).toList(),
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _syncList() async {
    final list = _currentList;
    final userId = _client.auth.currentUser?.id;
    if (list == null || userId == null) return;
    try {
      final listRow = await _client.from('shopping_lists').insert({
        'user_id': userId,
        'week_label': list.weekLabel,
        'generated_at': list.generatedAt.toIso8601String(),
      }).select('id').single();

      final listId = listRow['id'] as String;
      for (final item in list.items) {
        await _client.from('shopping_items').insert({
          'shopping_list_id': listId,
          'name': item.name,
          'category': item.category,
          'quantity': item.quantity,
          'unit': item.unit,
          'is_checked': item.isChecked,
          'meal_source': item.mealSource,
        });
      }

      // Update local list ID to the DB ID for future syncs
      _currentList = ShoppingList(
        id: listId,
        weekLabel: list.weekLabel,
        items: list.items,
        generatedAt: list.generatedAt,
      );
    } catch (_) {}
  }

  Future<void> _syncToggle(String itemId, bool isChecked) async {
    if (_client.auth.currentUser == null) return;
    try {
      await _client
          .from('shopping_items')
          .update({'is_checked': isChecked})
          .eq('id', itemId);
    } catch (_) {}
  }
}
