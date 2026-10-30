import 'dart:math' as math;
import '../models/film_stock.dart';

class ReciprocityResult {
  final double meteredSeconds;
  final double finalSeconds;
  final double compensationStops;
  final String notes;

  const ReciprocityResult({
    required this.meteredSeconds,
    required this.finalSeconds,
    required this.compensationStops,
    required this.notes,
  });
}

class ReciprocityService {
  static ReciprocityResult calculate({
    required double baseSeconds,
    required ReciprocityCurve curve,
  }) {
    if (baseSeconds <= 1.0) {
      return ReciprocityResult(
        meteredSeconds: baseSeconds,
        finalSeconds: baseSeconds,
        compensationStops: 0.0,
        notes: 'No reciprocity failure below 1 second.',
      );
    }

    double finalTime = baseSeconds;
    String notes = '';

    switch (curve) {
      case ReciprocityCurve.fujiAcros:
        if (baseSeconds <= 120) {
          finalTime = baseSeconds;
          notes = 'Fuji Acros II: Zero compensation up to 120 seconds!';
        } else {
          finalTime = baseSeconds * 1.414;
          notes = 'Fuji Acros II: +1/2 stop compensation past 120s.';
        }
        break;

      case ReciprocityCurve.ilfordHp5:
        finalTime = math.pow(baseSeconds, 1.31).toDouble();
        notes = 'Ilford formula: T^1.31';
        break;

      case ReciprocityCurve.ilfordDeltaFp4:
        finalTime = math.pow(baseSeconds, 1.26).toDouble();
        notes = 'Ilford Delta/FP4: T^1.26';
        break;

      case ReciprocityCurve.kodakPortra:
        finalTime = 1.3 * math.pow(baseSeconds, 1.24);
        notes = 'Kodak Portra: 1.3 * T^1.24';
        break;

      case ReciprocityCurve.kodakTmax:
        finalTime = math.pow(baseSeconds, 1.15).toDouble();
        notes = 'Kodak T-Max tabular grain: T^1.15';
        break;

      case ReciprocityCurve.kodakTriX:
        finalTime = math.pow(baseSeconds, 1.54).toDouble();
        notes = 'Kodak Tri-X traditional emulsion: T^1.54';
        break;

      case ReciprocityCurve.fomapan:
        finalTime = math.pow(baseSeconds, 1.58).toDouble();
        notes = 'Fomapan traditional emulsion: T^1.58';
        break;

      case ReciprocityCurve.cinestill:
        finalTime = 1.25 * math.pow(baseSeconds, 1.28);
        notes = 'CineStill (Vision3 base): 1.25 * T^1.28';
        break;

      case ReciprocityCurve.generic:
      default:
        finalTime = math.pow(baseSeconds, 1.30).toDouble();
        notes = 'Standard Schwarzschild curve (T^1.30)';
        break;
    }

    final ratio = finalTime / baseSeconds;
    final stops = math.log(ratio) / math.ln2;

    return ReciprocityResult(
      meteredSeconds: baseSeconds,
      finalSeconds: finalTime.roundToDouble(),
      compensationStops: (stops * 10).round() / 10.0,
      notes: notes,
    );
  }

  static String formatDuration(double seconds) {
    if (seconds < 1.0) {
      if (seconds <= 0) return '0s';
      final denom = (1.0 / seconds).round();
      return '1/${denom}s';
    }
    if (seconds < 60) {
      return '${seconds.round()}s';
    }
    final mins = seconds ~/ 60;
    final remSecs = (seconds % 60).round();
    if (mins < 60) {
      return '${mins}m ${remSecs}s';
    }
    final hours = mins ~/ 60;
    final remMins = mins % 60;
    return '${hours}h ${remMins}m ${remSecs}s';
  }
}
