import 'package:flutter/material.dart';
import '../models/equivalence_format.dart';
import '../services/equivalence_service.dart';

class FovScreen extends StatefulWidget {
  const FovScreen({super.key});

  @override
  State<FovScreen> createState() => _FovScreenState();
}

class _FovScreenState extends State<FovScreen> {
  String _sourceFormatId = '120_6x7';
  int _focalLength = 90;
  double _aperture = 3.8;

  @override
  Widget build(BuildContext context) {
    final sourceFmt = defaultFormats.firstWhere(
      (f) => f.id == _sourceFormatId,
      orElse: () => defaultFormats.first,
    );

    final result = EquivalenceService.calculate(
      sourceFormat: sourceFmt,
      focalLengthMm: _focalLength,
      aperture: _aperture,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121418),
        elevation: 0,
        title: const Text(
          'Format & FOV Equivalence',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Source format card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121418),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E2229)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOURCE FILM / SENSOR FORMAT',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sourceFormatId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF181B20),
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    items: defaultFormats.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text('${f.name} (${f.category})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _sourceFormatId = val);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '$_focalLength',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Focal Length (mm)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            setState(() => _focalLength = parsed);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: '$_aperture',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Aperture (f/)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            setState(() => _aperture = parsed);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 35mm Equivalent Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2229), Color(0xFF121418)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A303A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '35MM FULL FRAME EQUIVALENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Framing & Field of View:',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  '~${result.equivalentFocalLength35mm}mm',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Depth of Field (DoF):',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  '~f/${result.equivalentAperture35mm}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF08090C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Horizontal FOV: ${result.horizontalFovDegrees}°',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Color(0xFF06B6D4),
                        ),
                      ),
                      Text(
                        'Crop Factor: ${result.cropFactorVs35mm}x',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
