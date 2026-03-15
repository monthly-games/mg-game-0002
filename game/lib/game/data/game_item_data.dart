import 'package:mg_common_game/core/systems/rpg/item_data.dart';

class GameItemData extends ItemData {
  final String iconPath;
  final int tier;

  GameItemData({
    required super.id,
    required super.name,
    required super.description,
    required this.iconPath,
    this.tier = 1,
  });
}
