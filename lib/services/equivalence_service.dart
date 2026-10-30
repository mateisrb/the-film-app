import 'dart:math' as math;
import '../models/equivalence_format.dart';

class EquivalenceResult {
  final int equivalentFocalLength35mm;
  final double equivalentAperture35mm;
  final double horizontalFovDegrees;
  final double diagonalFovDegrees;
  final double cropFactorVs35mm;

  const EquivalenceResult({
    required this.equivalentFocalLength35mm,
    required this.equivalentAperture35mm,
    required this.horizontalFovDegrees,
    required this.diagonalFovDegrees,
    required this.cropFactorVs35mm,
  });
}

class EquivalenceService {
  static EquivalenceResult calculate({
    required FilmFormat sourceFormat,
    required int focalLengthMm,
    required double aperture,
  }) {
    final diagFormat = math.sqrt(
      sourceFormat.sensorWidthMm * sourceFormat.sensorWidthMm +
          sourceFormat.sensorHeightMm * sourceFormat.sensorHeightMm,
    );
    const diag35mm = 43.2666; // sqrt(36*36 + 24*24)
    final cropFactor = diag35mm / diagFormat;

    final eqFocal = (focalLengthMm * cropFactor).round();
    final eqAperture = ((aperture * cropFactor) * 10).round() / 10.0;

    final horizFovRad =
        2 * math.atan(sourceFormat.sensorWidthMm / (2 * focalLengthMm));
    final diagFovRad = 2 * math.atan(diagFormat / (2 * focalLengthMm));

    double toDeg(double rad) => ((rad * 180.0 / math.pi) * 10).round() / 10.0;

    return EquivalenceResult(
      equivalentFocalLength35mm: eqFocal,
      equivalentAperture35mm: eqAperture,
      horizontalFovDegrees: toDeg(horizFovRad),
      diagonalFovDegrees: toDeg(diagFovRad),
      cropFactorVs35mm: (cropFactor * 100).round() / 100.0,
    );
  }
}
