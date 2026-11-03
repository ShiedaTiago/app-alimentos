import '../core/utils/enum_utils.dart';

enum StorageType { fridge, freezer, pantry }

/// Local de armazenamento da casa (geladeira, freezer, despensa).
class StoragePlace {
  const StoragePlace({
    required this.id,
    required this.name,
    required this.type,
    this.minTemp,
    this.maxTemp,
    this.deviceId,
  });

  final String id;
  final String name;
  final StorageType type;
  final double? minTemp; // [F] faixa segura (TCC)
  final double? maxTemp;
  final String? deviceId;

  factory StoragePlace.fromMap(String id, Map<String, dynamic> map) {
    return StoragePlace(
      id: id,
      name: map['name'] as String,
      type: enumByName(
        StorageType.values,
        map['type'] as String?,
        StorageType.pantry,
      ),
      minTemp: (map['minTemp'] as num?)?.toDouble(),
      maxTemp: (map['maxTemp'] as num?)?.toDouble(),
      deviceId: map['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'deviceId': deviceId,
    };
  }
}
