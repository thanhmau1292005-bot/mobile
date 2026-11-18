import 'dart:async';
import 'package:flutter/material.dart';

class ManHinhDongHo extends StatefulWidget {
  const ManHinhDongHo({super.key});

  @override
  State<ManHinhDongHo> createState() => _ManHinhDongHoState();
}

// Tên tương thích cũ
typedef TimerScreen = ManHinhDongHo;

class _ManHinhDongHoState extends State<ManHinhDongHo> {
  int _secondsLeft = 60;
  int _initialSeconds = 60;
  Timer? _timer;
  bool _isRunning = false;

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _stopTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔔 Hết giờ nghỉ hiệp! Bắt đầu hiệp tiếp theo nào!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _secondsLeft = _initialSeconds);
  }

  void _setPresetSeconds(int secs) {
    _stopTimer();
    setState(() {
      _initialSeconds = secs;
      _secondsLeft = secs;
    });
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _initialSeconds > 0 ? _secondsLeft / _initialSeconds : 0.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đồng Hồ Đếm Giờ Nghỉ Hiệp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chọn khoảng thời gian hồi phục giữa các hiệp tập luyện',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 28),
            // Vòng tròn tiến trình đếm ngược
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey.withAlpha(50),
                    color: const Color(0xFF0F766E),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatTime(_secondsLeft),
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          _isRunning ? 'Đang đếm...' : 'Tạm dừng',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Nút bấm điều khiển Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  heroTag: 'btn_play_pause',
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: 'btn_reset',
                  onPressed: _resetTimer,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Các tùy chọn thời gian nhanh
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _presetChip(30, '30 giây', isDark),
                _presetChip(45, '45 giây', isDark),
                _presetChip(60, '1 phút', isDark),
                _presetChip(90, '1.5 phút', isDark),
                _presetChip(120, '2 phút', isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(int seconds, String label, bool isDark) {
    final isSelected = _initialSeconds == seconds;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0F766E),
      backgroundColor: isDark ? Colors.grey.shade800 : null,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => _setPresetSeconds(seconds),
    );
  }
}
