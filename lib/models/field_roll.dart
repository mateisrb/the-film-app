class FieldLoggedFrame {
  final int frameNumber;
  final DateTime timestamp;
  final String shutterSpeed;
  final double aperture;
  final String lensModel;
  final double? latitude;
  final double? longitude;
  final String? notes;

  const FieldLoggedFrame({
    required this.frameNumber,
    required this.timestamp,
    required this.shutterSpeed,
    required this.aperture,
    required this.lensModel,
    this.latitude,
    this.longitude,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'frameNumber': frameNumber,
        'timestamp': timestamp.toIso8601String(),
        'shutterSpeed': shutterSpeed,
        'aperture': aperture,
        'lensModel': lensModel,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
      };

  factory FieldLoggedFrame.fromJson(Map<String, dynamic> json) =>
      FieldLoggedFrame(
        frameNumber: json['frameNumber'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        shutterSpeed: json['shutterSpeed'] as String,
        aperture: (json['aperture'] as num).toDouble(),
        lensModel: json['lensModel'] as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );
}

class FieldRoll {
  final String id;
  final String name;
  final String cameraName;
  final String filmStockName;
  final int ratedIso;
  final int pushPull;
  final int maxFrames;
  final DateTime createdAt;
  final List<FieldLoggedFrame> frames;

  FieldRoll({
    required this.id,
    required this.name,
    required this.cameraName,
    required this.filmStockName,
    required this.ratedIso,
    this.pushPull = 0,
    this.maxFrames = 36,
    required this.createdAt,
    List<FieldLoggedFrame>? frames,
  }) : frames = frames ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cameraName': cameraName,
        'filmStockName': filmStockName,
        'ratedIso': ratedIso,
        'pushPull': pushPull,
        'maxFrames': maxFrames,
        'createdAt': createdAt.toIso8601String(),
        'frames': frames.map((f) => f.toJson()).toList(),
      };

  factory FieldRoll.fromJson(Map<String, dynamic> json) => FieldRoll(
        id: json['id'] as String,
        name: json['name'] as String,
        cameraName: json['cameraName'] as String,
        filmStockName: json['filmStockName'] as String,
        ratedIso: json['ratedIso'] as int,
        pushPull: json['pushPull'] as int? ?? 0,
        maxFrames: json['maxFrames'] as int? ?? 36,
        createdAt: DateTime.parse(json['createdAt'] as String),
        frames: (json['frames'] as List<dynamic>?)
                ?.map((f) =>
                    FieldLoggedFrame.fromJson(f as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
