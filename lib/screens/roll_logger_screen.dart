import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/camera_profile.dart';
import '../models/film_stock.dart';
import '../models/field_roll.dart';
import '../services/storage_service.dart';

class RollLoggerScreen extends StatefulWidget {
  final List<CameraProfile> cameras;
  final List<LensProfile> lenses;
  final List<FilmStock> filmStocks;

  const RollLoggerScreen({
    super.key,
    required this.cameras,
    required this.lenses,
    required this.filmStocks,
  });

  @override
  State<RollLoggerScreen> createState() => _RollLoggerScreenState();
}

class _RollLoggerScreenState extends State<RollLoggerScreen> {
  List<FieldRoll> _rolls = [];
  int _activeRollIndex = 0;

  double _currentAperture = 2.8;
  String _currentShutter = '1/125';
  String _currentLens = '50mm f/1.8';
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await StorageService.loadRolls();
    setState(() {
      _rolls = loaded;
      _isLoading = false;
    });
  }

  FieldRoll? get _activeRoll =>
      _rolls.isNotEmpty && _activeRollIndex < _rolls.length
          ? _rolls[_activeRollIndex]
          : null;

  void _logFrame() {
    final roll = _activeRoll;
    if (roll == null) return;

    if (roll.frames.length >= roll.maxFrames) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Roll is full! (${roll.maxFrames} frames)')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final newFrame = FieldLoggedFrame(
      frameNumber: roll.frames.length + 1,
      timestamp: DateTime.now(),
      shutterSpeed: _currentShutter,
      aperture: _currentAperture,
      lensModel: _currentLens,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    setState(() {
      roll.frames.add(newFrame);
      _notesController.clear();
    });

    StorageService.saveRolls(_rolls);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Frame #${newFrame.frameNumber} Logged!'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _exportJson() {
    final roll = _activeRoll;
    if (roll == null) return;
    final jsonStr = jsonEncode(roll.toJson());
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Roll JSON copied to clipboard for CamUtils Desktop!'),
        backgroundColor: Color(0xFFF59E0B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0C0E),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final roll = _activeRoll;
    final nextFrame = roll != null ? roll.frames.length + 1 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121418),
        elevation: 0,
        title: const Text(
          'Field Roll Logger',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF06B6D4)),
            tooltip: 'Copy JSON for Desktop EXIF Injector',
            onPressed: _exportJson,
          ),
        ],
      ),
      body: roll == null
          ? const Center(child: Text('No active rolls.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Active Roll Summary
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            roll.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          Text(
                            '${roll.frames.length} / ${roll.maxFrames}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '📷 ${roll.cameraName}  •  🎞️ ${roll.filmStockName} (ISO ${roll.ratedIso})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: roll.maxFrames > 0
                            ? roll.frames.length / roll.maxFrames
                            : 0,
                        backgroundColor: const Color(0xFF1E2229),
                        color: const Color(0xFFF59E0B),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Frame Entry Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181B20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A303A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LOG FRAME #$nextFrame',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<double>(
                              value: _currentAperture,
                              decoration: const InputDecoration(
                                labelText: 'Aperture',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [1.4, 1.8, 2.0, 2.8, 4.0, 5.6, 8.0, 11.0, 16.0]
                                  .map((a) => DropdownMenuItem(
                                      value: a, child: Text('f/$a')))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _currentAperture = v!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: _currentShutter,
                              decoration: const InputDecoration(
                                labelText: 'Shutter',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (v) => _currentShutter = v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional: e.g. Portrait, Street)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _logFrame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(
                            'Record Frame #$nextFrame',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Logged Frames
                const Text(
                  'RECORDED FRAMES',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ...roll.frames.reversed.map((f) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121418),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E2229)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2229),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${f.frameNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'f/${f.aperture}  •  ${f.shutterSpeed}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (f.notes != null)
                                Text(
                                  '"${f.notes}"',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[400]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
