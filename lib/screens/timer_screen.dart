import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/film_stock.dart';
import '../services/reciprocity_service.dart';

class TimerScreen extends StatefulWidget {
  final List<FilmStock> filmStocks;
  final double initialSeconds;

  const TimerScreen({
    super.key,
    required this.filmStocks,
    this.initialSeconds = 4.0,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late double _baseSeconds;
  int _ndStops = 0;
  bool _nightMode = false;

  late String _selectedFilmId;

  Timer? _timer;
  int _secondsLeft = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _baseSeconds = widget.initialSeconds;
    _selectedFilmId = widget.filmStocks.isNotEmpty
        ? widget.filmStocks.first.id
        : 'portra-400';
    _recalcTimer();
  }

  void _recalcTimer() {
    final stock = widget.filmStocks.firstWhere(
      (f) => f.id == _selectedFilmId,
      orElse: () => widget.filmStocks.first,
    );
    final ndAdjusted = _baseSeconds * (1 << _ndStops);
    final result = ReciprocityService.calculate(
      baseSeconds: ndAdjusted,
      curve: stock.reciprocityCurve,
    );
    setState(() {
      _totalSeconds = result.finalSeconds.toInt();
      _secondsLeft = _totalSeconds;
    });
  }

  void _toggleTimer() {
    HapticFeedback.heavyImpact();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      if (_secondsLeft <= 0) {
        _secondsLeft = _totalSeconds;
      }
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsLeft <= 1) {
          t.cancel();
          HapticFeedback.vibrate();
          setState(() {
            _isRunning = false;
            _secondsLeft = 0;
          });
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }

  void _resetTimer() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsLeft = _totalSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = widget.filmStocks.firstWhere(
      (f) => f.id == _selectedFilmId,
      orElse: () => widget.filmStocks.first,
    );
    final ndAdjusted = _baseSeconds * (1 << _ndStops);
    final result = ReciprocityService.calculate(
      baseSeconds: ndAdjusted,
      curve: stock.reciprocityCurve,
    );

    final bgColor =
        _nightMode ? const Color(0xFF0D0202) : const Color(0xFF0B0C0E);
    final cardBg =
        _nightMode ? const Color(0xFF1E0606) : const Color(0xFF121418);
    final accentColor =
        _nightMode ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final textColor = _nightMode ? const Color(0xFFFCA5A5) : Colors.white;

    final progress = _totalSeconds > 0
        ? (_totalSeconds - _secondsLeft) / _totalSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        title: Text(
          'Reciprocity & Bulb Timer',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _nightMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: accentColor,
            ),
            tooltip: 'Darkroom / Night Vision Mode',
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _nightMode = !_nightMode);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emulsion Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _nightMode
                    ? const Color(0xFF450A0A)
                    : const Color(0xFF1E2229),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. SELECT FILM EMULSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilmId,
                    isExpanded: true,
                    dropdownColor: cardBg,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: textColor,
                    ),
                    items: widget.filmStocks.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text('${f.brand} ${f.name} (${f.type})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedFilmId = val);
                        _recalcTimer();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.notes,
                  style: TextStyle(
                      fontSize: 11,
                      color: _nightMode ? Colors.red[300] : Colors.amber[300]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Metered Exposure & ND filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _nightMode
                    ? const Color(0xFF450A0A)
                    : const Color(0xFF1E2229),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2. METERED TIME: ${_baseSeconds.round()}s',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      'ND: +$_ndStops Stops',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF06B6D4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _baseSeconds,
                  min: 1.0,
                  max: 120.0,
                  divisions: 119,
                  activeColor: accentColor,
                  onChanged: (val) {
                    setState(() => _baseSeconds = val);
                    _recalcTimer();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Timer Dial / Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _nightMode
                    ? const Color(0xFF7F1D1D)
                    : const Color(0xFF2A303A),
              ),
            ),
            child: Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: _nightMode
                      ? const Color(0xFF2E0909)
                      : const Color(0xFF181B20),
                  color: accentColor,
                  minHeight: 6,
                ),
                const SizedBox(height: 28),

                // Digital Numbers
                Text(
                  _formatCountdown(_secondsLeft),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRunning
                    ? 'SHUTTER OPEN (EXPOSING...)'
                    : 'BULB SHUTTER READY',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: _isRunning ? Colors.greenAccent : Colors.grey,
                  ),
                ),
                const SizedBox(height: 28),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(
                        _isRunning ? 'Pause' : 'Start Shutter',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    IconButton.filledTonal(
                      onPressed: _resetTimer,
                      style: IconButton.styleFrom(
                        backgroundColor: _nightMode
                            ? const Color(0xFF2E0909)
                            : const Color(0xFF1E2229),
                        padding: const EdgeInsets.all(12),
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCountdown(int secs) {
    final mins = secs ~/ 60;
    final rSecs = secs % 60;
    final mStr = mins.toString().padLeft(2, '0');
    final sStr = rSecs.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }
}
