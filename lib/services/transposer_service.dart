import 'dart:math' as math;

class VintageShutter {
  final String label;
  final double seconds;

  const VintageShutter(this.label, this.seconds);
}

const List<VintageShutter> vintageShutters = [
  VintageShutter('1/1000', 1 / 1000),
  VintageShutter('1/500', 1 / 500),
  VintageShutter('1/250', 1 / 250),
  VintageShutter('1/125', 1 / 125),
  VintageShutter('1/60', 1 / 60),
  VintageShutter('1/30', 1 / 30),
  VintageShutter('1/15', 1 / 15),
  VintageShutter('1/8', 1 / 8),
  VintageShutter('1/4', 1 / 4),
  VintageShutter('1/2', 0.5),
  VintageShutter('1s', 1.0),
  VintageShutter('2s', 2.0),
  VintageShutter('4s', 4.0),
  VintageShutter('8s', 8.0),
  VintageShutter('15s', 15.0),
  VintageShutter('30s', 30.0),
  VintageShutter('60s', 60.0),
];

const List<double> commonApertures = [
  0.95, 1.2, 1.4, 1.8, 2.0, 2.8, 4.0, 5.6, 8.0, 11.0, 16.0, 22.0
];

const List<int> commonIsos = [
  25, 50, 100, 160, 200, 400, 800, 1600, 3200, 6400
];

class VintageNotchResult {
  final String label;
  final double notchSeconds;
  final double evDifference;

  const VintageNotchResult({
    required this.label,
    required this.notchSeconds,
    required this.evDifference,
  });
}

class TransposerService {
  static double calculateSceneEv({
    required int iso,
    required double fNumber,
    required double seconds,
  }) {
    if (iso <= 0 || fNumber <= 0 || seconds <= 0) return 0.0;
    final evAtIso = math.log((fNumber * fNumber) / seconds) / math.ln2;
    final isoOffset = math.log(iso / 100.0) / math.ln2;
    return evAtIso - isoOffset;
  }

  static double solveTargetShutterSeconds({
    required double sceneEv100,
    required double compensationEv,
    required int targetIso,
    required double targetAperture,
  }) {
    final targetIsoOffset = math.log(targetIso / 100.0) / math.ln2;
    final targetEv = sceneEv100 - compensationEv + targetIsoOffset;
    final denominator = math.pow(2.0, targetEv);
    final seconds = (targetAperture * targetAperture) / denominator;
    return math.max(0.0001, seconds);
  }

  static double solveTargetAperture({
    required double sceneEv100,
    required double compensationEv,
    required int targetIso,
    required double targetSeconds,
  }) {
    final targetIsoOffset = math.log(targetIso / 100.0) / math.ln2;
    final targetEv = sceneEv100 - compensationEv + targetIsoOffset;
    final nSquared = targetSeconds * math.pow(2.0, targetEv);
    final result = math.sqrt(nSquared);
    return math.max(0.7, (result * 10).round() / 10.0);
  }

  static VintageNotchResult findClosestVintageShutter(double seconds) {
    VintageShutter closest = vintageShutters[0];
    double minLogDiff = double.infinity;

    for (final s in vintageShutters) {
      final diff =
          (math.log(s.seconds) / math.ln2 - math.log(seconds) / math.ln2).abs();
      if (diff < minLogDiff) {
        minLogDiff = diff;
        closest = s;
      }
    }

    final evDiff =
        math.log(closest.seconds / seconds) / math.ln2;

    return VintageNotchResult(
      label: closest.label,
      notchSeconds: closest.seconds,
      evDifference: (evDiff * 10).round() / 10.0,
    );
  }

  static String formatShutterDisplay(double seconds) {
    if (seconds <= 0) return '0s';
    if (seconds < 0.8) {
      final denominator = (1.0 / seconds).round();
      return '1/${denominator}s';
    }
    if (seconds < 60) {
      return '${(seconds * 10).round() / 10}s';
    }
    final mins = seconds ~/ 60;
    final rem = (seconds % 60).round();
    return '${mins}m ${rem}s';
  }
}
