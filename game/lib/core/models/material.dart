/// Material model representing collectible resources
class Material {
  final String id;
  final String name;
  final int tier;
  final String icon;
  final String description;
  final double productionRate; // items per hour
  final int maxStorage;
  final String category;
  final int? unlockLevel;
  final String? obtainMethod;

  const Material({
    required this.id,
    required this.name,
    required this.tier,
    required this.icon,
    required this.description,
    required this.productionRate,
    required this.maxStorage,
    required this.category,
    this.unlockLevel,
    this.obtainMethod,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: json['tier'] as int,
      icon: json['icon'] as String,
      description: json['description'] as String,
      productionRate: (json['productionRate'] as num).toDouble(),
      maxStorage: json['maxStorage'] as int,
      category: json['category'] as String,
      unlockLevel: json['unlockLevel'] as int?,
      obtainMethod: json['obtainMethod'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier,
      'icon': icon,
      'description': description,
      'productionRate': productionRate,
      'maxStorage': maxStorage,
      'category': category,
      if (unlockLevel != null) 'unlockLevel': unlockLevel,
      if (obtainMethod != null) 'obtainMethod': obtainMethod,
    };
  }

  /// Check if material is unlocked based on workshop level
  bool isUnlocked(int workshopLevel) {
    if (unlockLevel == null) return true;
    return workshopLevel >= unlockLevel!;
  }

  /// Check if material is idle-produced or special
  bool get isIdleProduced => productionRate > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Material && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Material($id: $name)';
}
