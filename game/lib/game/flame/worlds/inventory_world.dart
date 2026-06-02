/// Inventory World - 인벤토리 월드
///
/// 플레이어의 소지품을 관리하는 인벤토리 장면입니다.
library;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:cat_alchemy/game/components/game_button.dart';
import 'package:cat_alchemy/game/components/inventory_slot.dart';
import 'package:cat_alchemy/game/flame/worlds/cat_alchemy_world.dart';

/// 인벤토리 월드
///
/// 플레이어의 아이템과 재료를 표시하고 관리합니다.
class InventoryWorld extends CatAlchemyWorld {
  // 인벤토리 슬롯들
  final List<InventorySlot> _inventorySlots = [];

  // 선택된 슬롯
  InventorySlot? _selectedSlot;

  // 인벤토리 카테고리
  InventoryCategory _currentCategory = InventoryCategory.all;

  // 페이지
  int _currentPage = 0;

  InventoryWorld() : super('inventory');

  @override
  Future<void> onWorldLoad() async {
    // 인벤토리 컴포넌트들 추가
    await _addInventorySlots();
    await _addInventoryUI();
  }

  /// 인벤토리 슬롯 추가
  Future<void> _addInventorySlots() async {
    // 인벤토리 그리드 (4x3)
    final startX = 220.0;
    final startY = 200.0;
    final slotSize = 80.0;
    final gap = 10.0;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        final index = row * 4 + col;
        final slot = InventorySlot(
          itemId: 'item_$index',
          amount: index < 5 ? index + 1 : 0,
          position: Vector2(
            startX + col * (slotSize + gap),
            startY + row * (slotSize + gap),
          ),
          size: slotSize,
          onTap: () => _onSlotTap(_inventorySlots[index]),
        );
        await add(slot);
        _inventorySlots.add(slot);
      }
    }
  }

  /// 인벤토리 UI 추가
  Future<void> _addInventoryUI() async {
    // 카테고리 버튼들
    final categories = [
      InventoryCategory.all,
      InventoryCategory.materials,
      InventoryCategory.items,
      InventoryCategory.crafted,
    ];

    final categoryNames = ['All', 'Materials', 'Items', 'Crafted'];

    for (int i = 0; i < categories.length; i++) {
      final categoryButton = GameButton(
        text: categoryNames[i],
        position: Vector2(150.0 + i * 110, 120),
        size: Vector2(100, 35),
        onPressed: () => _switchCategory(categories[i]),
      );
      await add(categoryButton);
    }

    // 페이지 버튼
    final prevPageButton = GameButton(
      text: '<',
      position: Vector2(200, 480),
      size: Vector2(50, 40),
      onPressed: _previousPage,
    );
    await add(prevPageButton);

    final nextPageButton = GameButton(
      text: '>',
      position: Vector2(550, 480),
      size: Vector2(50, 40),
      onPressed: _nextPage,
    );
    await add(nextPageButton);

    // 아이템 정보 버튼
    final infoButton = GameButton(
      text: 'Info',
      position: Vector2(600, 300),
      size: Vector2(100, 40),
      onPressed: _showItemInfo,
    );
    await add(infoButton);

    // 홈으로 버튼
    final homeButton = GameButton(
      text: 'Home',
      position: Vector2(50, 50),
      size: Vector2(120, 40),
      onPressed: _onHomePressed,
    );
    await add(homeButton);
  }

  /// 슬롯 탭 핸들러
  void _onSlotTap(InventorySlot slot) {
    _selectedSlot = slot;
    debugPrint('Selected slot: ${slot.itemId}');
  }

  /// 카테고리 전환
  void _switchCategory(InventoryCategory category) {
    _currentCategory = category;
    _currentPage = 0;
    debugPrint('Switched to ${category.name} category');
    // 실제 구현에서는 카테고리별로 슬롯 업데이트
  }

  /// 이전 페이지
  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      debugPrint('Page: $_currentPage');
    }
  }

  /// 다음 페이지
  void _nextPage() {
    _currentPage++;
    debugPrint('Page: $_currentPage');
  }

  /// 아이템 정보 표시
  void _showItemInfo() {
    if (_selectedSlot?.itemId != null) {
      debugPrint('Item info: ${_selectedSlot!.itemId}');
    }
  }

  /// 홈 버튼 핸들러
  void _onHomePressed() {
    debugPrint('Navigate to home');
  }

  /// 현재 카테고리 반환
  InventoryCategory get currentCategory => _currentCategory;

  /// 현재 페이지 반환
  int get currentPage => _currentPage;

  /// 선택된 슬롯 반환
  InventorySlot? get selectedSlot => _selectedSlot;

  /// 인벤토리 슬롯들 반환
  List<InventorySlot> get inventorySlots => List.unmodifiable(_inventorySlots);
}

/// 인벤토리 카테고리
enum InventoryCategory {
  all,
  materials,
  items,
  crafted,
}
