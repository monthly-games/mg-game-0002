/// Shop World - 상점 월드
///
/// 아이템을 구매하고 판매하는 상점 장면입니다.
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:cat_alchemy/game/components/game_button.dart';
import 'package:cat_alchemy/game/flame/worlds/cat_alchemy_world.dart';

/// 상점 월드
///
/// 플레이어가 재료와 아이템을 거래합니다.
class ShopWorld extends CatAlchemyWorld {
  // 상점 아이템 슬롯들
  final List<ShopItemSlot> _shopItems = [];

  // 상점 탭 (판매/구매)
  ShopTab _currentTab = ShopTab.buy;

  // 선택된 아이템
  ShopItemSlot? _selectedItem;

  ShopWorld() : super('shop');

  @override
  Future<void> onWorldLoad() async {
    // 상점 컴포넌트들 추가
    await _addShopItems();
    await _addShopUI();
  }

  /// 상점 아이템 추가
  Future<void> _addShopItems() async {
    // 기본 상점 아이템들
    final items = [
      ShopItemData(
        name: 'Herb',
        price: 10,
        icon: 'herb_icon.png',
        description: 'Basic crafting material',
      ),
      ShopItemData(
        name: 'Ore',
        price: 15,
        icon: 'ore_icon.png',
        description: 'Mining material',
      ),
      ShopItemData(
        name: 'Cloth',
        price: 20,
        icon: 'cloth_icon.png',
        description: 'Textile material',
      ),
      ShopItemData(
        name: 'Crystal',
        price: 50,
        icon: 'crystal_icon.png',
        description: 'Rare magical material',
      ),
    ];

    // 아이템 슬롯 생성 (2x2 그리드)
    final positions = [
      Vector2(250, 200),
      Vector2(400, 200),
      Vector2(250, 320),
      Vector2(400, 320),
    ];

    for (int i = 0; i < items.length && i < positions.length; i++) {
      final itemSlot = ShopItemSlot(
        itemData: items[i],
        position: positions[i],
        onTap: () => _onItemTap(_shopItems[i]),
      );
      await add(itemSlot);
      _shopItems.add(itemSlot);
    }
  }

  /// 상점 UI 추가
  Future<void> _addShopUI() async {
    // 구매/판매 탭 버튼
    final buyTabButton = GameButton(
      text: 'Buy',
      position: Vector2(200, 120),
      size: Vector2(100, 40),
      onPressed: () => _switchTab(ShopTab.buy),
    );
    await add(buyTabButton);

    final sellTabButton = GameButton(
      text: 'Sell',
      position: Vector2(310, 120),
      size: Vector2(100, 40),
      onPressed: () => _switchTab(ShopTab.sell),
    );
    await add(sellTabButton);

    // 구매/판매 버튼
    final transactionButton = GameButton(
      text: 'Buy',
      position: Vector2(550, 260),
      size: Vector2(120, 50),
      onPressed: _onTransactionPressed,
    );
    await add(transactionButton);

    // 홈으로 버튼
    final homeButton = GameButton(
      text: 'Home',
      position: Vector2(50, 50),
      size: Vector2(120, 40),
      onPressed: _onHomePressed,
    );
    await add(homeButton);
  }

  /// 아이템 탭 핸들러
  void _onItemTap(ShopItemSlot item) {
    _selectedItem = item;
    debugPrint('Selected item: ${item.itemData.name}');
  }

  /// 탭 전환
  void _switchTab(ShopTab tab) {
    _currentTab = tab;
    debugPrint('Switched to ${tab.name} tab');
  }

  /// 거래 버튼 핸들러
  void _onTransactionPressed() {
    if (_selectedItem == null) return;

    if (_currentTab == ShopTab.buy) {
      _buyItem(_selectedItem!);
    } else {
      _sellItem(_selectedItem!);
    }
  }

  /// 아이템 구매
  void _buyItem(ShopItemSlot item) {
    debugPrint('Bought ${item.itemData.name} for ${item.itemData.price} gold');
    // 실제 구매 로직 구현
  }

  /// 아이템 판매
  void _sellItem(ShopItemSlot item) {
    debugPrint('Sold ${item.itemData.name} for ${item.itemData.price ~/ 2} gold');
    // 실제 판매 로직 구현
  }

  /// 홈 버튼 핸들러
  void _onHomePressed() {
    debugPrint('Navigate to home');
  }

  /// 현재 탭 반환
  ShopTab get currentTab => _currentTab;

  /// 선택된 아이템 반환
  ShopItemSlot? get selectedItem => _selectedItem;

  /// 상점 아이템들 반환
  List<ShopItemSlot> get shopItems => List.unmodifiable(_shopItems);
}

/// 상점 탭
enum ShopTab {
  buy,
  sell,
}

/// 상점 아이템 데이터
class ShopItemData {
  final String name;
  final int price;
  final String icon;
  final String description;

  ShopItemData({
    required this.name,
    required this.price,
    required this.icon,
    required this.description,
  });
}

/// 상점 아이템 슬롯 컴포넌트
class ShopItemSlot extends PositionComponent with TapCallbacks {
  final ShopItemData itemData;
  final VoidCallback onTap;

  ShopItemSlot({
    required this.itemData,
    required Vector2 position,
    required this.onTap,
  }) : super(
          position: position,
          size: Vector2(130, 100),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 슬롯 시각적 표현 (실제 구현에서는 스프라이트 추가)
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    onTap();
  }
}
