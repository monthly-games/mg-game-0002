// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 0;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      gold: fields[0] as int,
      gems: fields[1] as int,
      workshopLevel: fields[2] as int,
      reputation: fields[3] as int,
      playerExp: fields[4] as int,
      inventory: (fields[5] as Map?)?.cast<String, int>(),
      discoveredRecipes: (fields[6] as List?)?.cast<String>(),
      lastLoginTime: fields[7] as DateTime?,
      catState: (fields[8] as Map?)?.cast<String, dynamic>(),
      craftingQueue: (fields[9] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      activeOrders: (fields[10] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      dailyInteractions: (fields[11] as Map?)?.cast<String, int>(),
      tutorialCompleted: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.gold)
      ..writeByte(1)
      ..write(obj.gems)
      ..writeByte(2)
      ..write(obj.workshopLevel)
      ..writeByte(3)
      ..write(obj.reputation)
      ..writeByte(4)
      ..write(obj.playerExp)
      ..writeByte(5)
      ..write(obj.inventory)
      ..writeByte(6)
      ..write(obj.discoveredRecipes)
      ..writeByte(7)
      ..write(obj.lastLoginTime)
      ..writeByte(8)
      ..write(obj.catState)
      ..writeByte(9)
      ..write(obj.craftingQueue)
      ..writeByte(10)
      ..write(obj.activeOrders)
      ..writeByte(11)
      ..write(obj.dailyInteractions)
      ..writeByte(12)
      ..write(obj.tutorialCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
