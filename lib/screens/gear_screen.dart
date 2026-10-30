import 'package:flutter/material.dart';
import '../models/camera_profile.dart';
import '../models/film_stock.dart';
import '../services/storage_service.dart';

class GearScreen extends StatefulWidget {
  final List<CameraProfile> cameras;
  final List<LensProfile> lenses;
  final List<FilmStock> filmStocks;
  final VoidCallback onGearUpdated;

  const GearScreen({
    super.key,
    required this.cameras,
    required this.lenses,
    required this.filmStocks,
    required this.onGearUpdated,
  });

  @override
  State<GearScreen> createState() => _GearScreenState();
}

class _GearScreenState extends State<GearScreen> {
  int _tabIndex = 0;

  void _addCameraDialog() {
    String make = '';
    String model = '';
    String format = '35mm';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181B20),
        title: const Text('Add Camera Body', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Make (e.g. Leica, Nikon)'),
              onChanged: (v) => make = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Model (e.g. M6, FM2)'),
              onChanged: (v) => model = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (make.trim().isNotEmpty && model.trim().isNotEmpty) {
                final newCam = CameraProfile(
                  id: 'cam-${DateTime.now().millisecondsSinceEpoch}',
                  make: make.trim(),
                  model: model.trim(),
                  format: format,
                );
                widget.cameras.insert(0, newCam);
                StorageService.saveCameras(widget.cameras);
                widget.onGearUpdated();
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121418),
        elevation: 0,
        title: const Text(
          'Gear Closet',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFF59E0B)),
            onPressed: _addCameraDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF121418),
            child: Row(
              children: [
                _buildTab(0, 'Cameras (${widget.cameras.length})'),
                _buildTab(1, 'Lenses (${widget.lenses.length})'),
                _buildTab(2, 'Film (${widget.filmStocks.length})'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tabIndex == 0
                  ? widget.cameras.length
                  : _tabIndex == 1
                      ? widget.lenses.length
                      : widget.filmStocks.length,
              itemBuilder: (ctx, i) {
                if (_tabIndex == 0) {
                  final c = widget.cameras[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121418),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E2229)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${c.make} ${c.model}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            c.format,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (_tabIndex == 1) {
                  final l = widget.lenses[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121418),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E2229)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.model,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('${l.focalLength}mm f/${l.maxAperture}',
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFF06B6D4))),
                      ],
                    ),
                  );
                } else {
                  final f = widget.filmStocks[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121418),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E2229)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${f.brand} ${f.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text(f.type,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[400])),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ISO ${f.boxIso}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int idx, String title) {
    final isSel = _tabIndex == idx;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabIndex = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSel ? const Color(0xFFF59E0B) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              color: isSel ? const Color(0xFFF59E0B) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
