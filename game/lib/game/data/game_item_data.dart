import 'package:mg_common_game/core/systems/rpg/item_data.dart';

class GameItemData extends ItemData {
  final String iconPath;
  final int tier;

  GameItemData({
    required String id,
    required String name,
    required String description,
    required this.iconPath,
    this.tier = 1,
  }) : super(id: id, name: name, description: description);
}
