import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/film_stock.dart';
import '../models/scene_preset.dart';
import '../services/transposer_service.dart';
import '../services/reciprocity_service.dart';

class TransposerScreen extends StatefulWidget {
  final List<FilmStock> filmStocks;
  final Function(double seconds)? onNavigateToTimer;

  const TransposerScreen({
    super.key,
    required this.filmStocks,
    this.onNavigateToTimer,
  });

  @override
  State<TransposerScreen> createState() => _TransposerScreenState();
}

class _TransposerScreenState extends State<TransposerScreen> {
  int _meterIso = 1600;
  double _meterAperture = 5.6;
  double _meterShutterSeconds = 1.0 / 125.0;

  String _selectedPresetId = 'neutral';
  double _customCompensationEv = 0.0;

  int _targetIso = 400;
  bool _solveForShutter = true;
  double _targetAperture = 1.8;
  double _targetShutterSeconds = 1.0 / 60.0;

  late String _selectedFilmId;

  @override
  void initState() {
    super.initState();
    _selectedFilmId = widget.filmStocks.isNotEmpty
        ? widget.filmStocks.first.id
        : 'portra-400';
  }

  @override
  Widget build(BuildContext context) {
    final selectedPreset = scenePresets.firstWhere(
      (p) => p.id === _selectedPresetId,
      orElse: () => scenePresets.first,
    );

    final activeCompEv = _selectedPresetId == 'custom'
        ? _customCompensationEv
        : selectedPreset.compensationEv;

    final selectedStock = widget.filmStocks.firstWhere(
      (f) => f.id == _selectedFilmId,
      orElse: () => widget.filmStocks.first,
    );

    // Calculate raw scene EV at ISO 100
    final sceneEv100 = TransposerService.calculateSceneEv(
      iso: _meterIso,
      fNumber: _meterAperture,
      seconds: _meterShutterSeconds,
    );

    double finalShutterSeconds = 0.0;
    double finalAperture = 0.0;

    if (_solveForShutter) {
      finalShutterSeconds = TransposerService.solveTargetShutterSeconds(
        sceneEv100: sceneEv100,
        compensationEv: activeCompEv,
        targetIso: _targetIso,
        targetAperture: _targetAperture,
      );
      finalAperture = _targetAperture;
    } else {
      finalAperture = TransposerService.solveTargetAperture(
        sceneEv100: sceneEv100,
        compensationEv: activeCompEv,
        targetIso: _targetIso,
        targetSeconds: _targetShutterSeconds,
      );
      finalShutterSeconds = _targetShutterSeconds;
    }

    final vintageNotch =
        TransposerService.findClosestVintageShutter(finalShutterSeconds);
    final isReciprocity = finalShutterSeconds >= 1.0;
    final reciprocityResult = isReciprocity
        ? ReciprocityService.calculate(
            baseSeconds: finalShutterSeconds,
            curve: selectedStock.reciprocityCurve,
          )
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121418),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.tune, color: Color(0xFFF59E0B), size: 20),
            SizedBox(width: 8),
            Text(
              'Meter Transposer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF181B20),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF2A303A)),
            ),
            child: Text(
              'Scene EV: ${(sceneEv100 * 10).round() / 10}',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. In-Camera Meter Card
          _buildCard(
            title: '1. What Your Camera Meter Shows',
            accentColor: const Color(0xFFF59E0B),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIsoSelector(
                  title: 'Meter Dial ISO',
                  currentIso: _meterIso,
                  onChanged: (iso) => setState(() => _meterIso = iso),
                  accentColor: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown<double>(
                        label: 'Meter Aperture',
                        value: _meterAperture,
                        items: commonApertures,
                        itemLabel: (v) => 'f/$v',
                        onChanged: (v) => setState(() => _meterAperture = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown<double>(
                        label: 'Meter Shutter',
                        value: _meterShutterSeconds,
                        items: vintageShutters.map((s) => s.seconds).toList(),
                        itemLabel: (v) =>
                            TransposerService.formatShutterDisplay(v),
                        onChanged: (v) =>
                            setState(() => _meterShutterSeconds = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Scene Lighting / Meter Bias Presets
          _buildCard(
            title: '2. Scene Lighting & Meter Bias',
            accentColor: const Color(0xFF06B6D4),
            trailing: Text(
              activeCompEv >= 0 ? '+$activeCompEv EV' : '$activeCompEv EV',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Color(0xFF06B6D4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: scenePresets.map((p) {
                    final isSel = _selectedPresetId == p.id;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPresetId = p.id);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFF06B6D4).withOpacity(0.18)
                              : const Color(0xFF181B20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel
                                ? const Color(0xFF06B6D4)
                                : const Color(0xFF2A303A),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(p.icon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSel ? Colors.white : Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF08090C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E2229)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Color(0xFF06B6D4)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${selectedPreset.name}: ${selectedPreset.why}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Real Loaded Film & Target Setup
          _buildCard(
            title: '3. Your Real Shooting Parameters',
            accentColor: const Color(0xFF10B981),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIsoSelector(
                  title: 'Real Loaded Film ISO',
                  currentIso: _targetIso,
                  onChanged: (iso) => setState(() => _targetIso = iso),
                  accentColor: const Color(0xFF10B981),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('I want to set:',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                            value: true,
                            label: Text('Aperture', style: TextStyle(fontSize: 11))),
                        ButtonSegment(
                            value: false,
                            label: Text('Shutter', style: TextStyle(fontSize: 11))),
                      ],
                      selected: {_solveForShutter},
                      onSelectionChanged: (set) =>
                          setState(() => _solveForShutter = set.first),
                      style: SegmentedButton.styleFrom(
                        backgroundColor: const Color(0xFF181B20),
                        selectedBackgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.grey,
                        selectedForegroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_solveForShutter)
                  _buildDropdown<double>(
                    label: 'Desired Lens Aperture',
                    value: _targetAperture,
                    items: commonApertures,
                    itemLabel: (v) => 'f/$v',
                    onChanged: (v) => setState(() => _targetAperture = v!),
                  )
                else
                  _buildDropdown<double>(
                    label: 'Desired Shutter Speed',
                    value: _targetShutterSeconds,
                    items: vintageShutters.map((s) => s.seconds).toList(),
                    itemLabel: (v) => TransposerService.formatShutterDisplay(v),
                    onChanged: (v) =>
                        setState(() => _targetShutterSeconds = v!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Result Solution Card
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BALANCED EXPOSURE SOLUTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      '✓ EV Balanced',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_solveForShutter) ...[
                  const Text('Set Shutter Speed to:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    TransposerService.formatShutterDisplay(finalShutterSeconds),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF08090C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E2229)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Vintage SLR Dial Notch:',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFF59E0B).withOpacity(0.3)),
                          ),
                          child: Text(
                            vintageNotch.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Text('Set Lens Aperture to:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    'f/$finalAperture',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Reciprocity Failure Warning Banner (if >= 1s)
          if (isReciprocity && reciprocityResult != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3F0B0B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'RECIPROCITY FAILURE ACTIVE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exposure is ${TransposerService.formatShutterDisplay(finalShutterSeconds)}. Film loses sensitivity on long exposures. Compensated physical shutter time required:',
                    style: TextStyle(fontSize: 11, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ReciprocityService.formatDuration(
                        reciprocityResult.finalSeconds),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        if (widget.onNavigateToTimer != null) {
                          widget.onNavigateToTimer!(
                              reciprocityResult.finalSeconds);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.timer, size: 18),
                      label: const Text(
                        'Open Shutter Countdown Timer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Color accentColor,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
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
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildIsoSelector({
    required String title,
    required int currentIso,
    required ValueChanged<int> onChanged,
    required Color accentColor,
  }) {
    const isos = [100, 200, 400, 800, 1600, 3200];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              'ISO $currentIso',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: isos.map((iso) {
              final isSel = currentIso == iso;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('$iso',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isSel ? Colors.black : Colors.white,
                      )),
                  selected: isSel,
                  selectedColor: accentColor,
                  backgroundColor: const Color(0xFF181B20),
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      onChanged(iso);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF181B20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A303A)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF181B20),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Colors.white,
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                );
              }).toList(),
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
