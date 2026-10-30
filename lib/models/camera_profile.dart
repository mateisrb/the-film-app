class CameraProfile {
  final String id;
  final String make;
  final String model;
  final String format;

  const CameraProfile({
    required this.id,
    required this.make,
    required this.model,
    required this.format,
  });

  String get displayName => '$make $model ($format)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'format': format,
      };

  factory CameraProfile.fromJson(Map<String, dynamic> json) => CameraProfile(
        id: json['id'] as String,
        make: json['make'] as String,
        model: json['model'] as String,
        format: json['format'] as String,
      );
}

class LensProfile {
  final String id;
  final String model;
  final int focalLength;
  final double maxAperture;

  const LensProfile({
    required this.id,
    required this.model,
    required this.focalLength,
    required this.maxAperture,
  });

  String get displayName => '$model (${focalLength}mm f/$maxAperture)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'focalLength': focalLength,
        'maxAperture': maxAperture,
      };

  factory LensProfile.fromJson(Map<String, dynamic> json) => LensProfile(
        id: json['id'] as String,
        model: json['model'] as String,
        focalLength: json['focalLength'] as int,
        maxAperture: (json['maxAperture'] as num).toDouble(),
      );
}

final List<CameraProfile> defaultCameras = [
  const CameraProfile(id: 'leica-m6', make: 'Leica', model: 'M6', format: '35mm'),
  const CameraProfile(id: 'hasselblad-500cm', make: 'Hasselblad', model: '500 C/M', format: '6x6'),
  const CameraProfile(id: 'mamiya-rb67', make: 'Mamiya', model: 'RB67 Pro-S', format: '6x7'),
  const CameraProfile(id: 'canon-ae1', make: 'Canon', model: 'AE-1 Program', format: '35mm'),
  const CameraProfile(id: 'nikon-fm2', make: 'Nikon', model: 'FM2n', format: '35mm'),
  const CameraProfile(id: 'pentax-67', make: 'Pentax', model: '67 II', format: '6x7'),
  const CameraProfile(id: 'olympus-om1', make: 'Olympus', model: 'OM-1', format: '35mm'),
];

final List<LensProfile> defaultLenses = [
  const LensProfile(id: 'summicron-35', model: 'Summicron 35mm f/2', focalLength: 35, maxAperture: 2.0),
  const LensProfile(id: 'planar-80', model: 'Planar 80mm f/2.8', focalLength: 80, maxAperture: 2.8),
  const LensProfile(id: 'sekor-90', model: 'Sekor C 90mm f/3.8', focalLength: 90, maxAperture: 3.8),
  const LensProfile(id: 'nikkor-50', model: 'Nikkor 50mm f/1.8', focalLength: 50, maxAperture: 1.8),
  const LensProfile(id: 'canon-fd-50', model: 'Canon FD 50mm f/1.4', focalLength: 50, maxAperture: 1.4),
];
