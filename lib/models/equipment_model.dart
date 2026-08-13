class Equipment {
  final String? equipmentId;
  final String name;
  final bool isInWorkingCondition;
  final String? targetMuscle;

  const Equipment({
    this.equipmentId,
    required this.name,
    this.isInWorkingCondition = true,
    this.targetMuscle,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      equipmentId: json['equipmentId']?.toString(),
      name: json['name'] ?? '',
      isInWorkingCondition: json['isInWorkingCondition'] ?? true,
      targetMuscle: json['targetMuscle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (equipmentId != null) 'equipmentId': equipmentId,
      'name': name,
      'isInWorkingCondition': isInWorkingCondition,
      if (targetMuscle != null) 'targetMuscle': targetMuscle,
    };
  }
}
