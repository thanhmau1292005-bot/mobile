


import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../services/bmi_service.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '65');
  final _ageController = TextEditingController(text: '21');

  double? _bmiResult;
  String _bmiCategory = '';
  String _healthAdvice = '';
  Color _statusColor = Colors.teal;

  void _calculateBmi() {
    if (!_formKey.currentState!.validate()) return;

    final double heightCm = double.parse(_heightController.text);
    final double weightKg = double.parse(_weightController.text);
    final double heightM = heightCm / 100;
    final double bmi = weightKg / (heightM * heightM);

    String category;
    String advice;
    Color color;

    if (bmi < 18.5) {
      category = 'Thiếu cân';
      color = Colors.blue;
      advice =
          'Tăng cường thực phẩm giàu đạm (thịt bò, ức gà, trứng, sữa), bổ sung bữa phụ và tập tạ nhẹ để tăng khối lượng cơ.';
    } else if (bmi < 25.0) {
      category = 'Cân đối (Chuẩn)';
      color = Colors.green;
      advice =
          'Chỉ số cơ thể lý tưởng! Hãy duy trì chế độ ăn cân bằng năng lượng và tập luyện thể thao 3-4 buổi/tuần.';
    } else if (bmi < 30.0) {
      category = 'Thừa cân';
      color = Colors.orange;
      advice =
          'Giảm tinh bột hấp thu nhanh và đồ uống có đường, tăng rau xanh, kết hợp chạy bộ/Cardio 30 phút mỗi ngày.';
    } else {
      category = 'Béo phì';
      color = Colors.redAccent;
      advice =
          'Cần kiểm soát thâm hụt Calo hằng ngày, hạn chế đồ chiên rán và ưu tiên đi bộ nhanh hoặc bơi lội để bảo vệ khớp.';
    }

    setState(() {
      _bmiResult = bmi;
      _bmiCategory = category;
      _healthAdvice = advice;
      _statusColor = color;
    });

    BmiService.instance.saveBmiRecord(
      BmiRecord(
        bmi: double.parse(bmi.toStringAsFixed(1)),
        status: category,
        heightCm: heightCm,
        weightKg: weightKg,
        timestamp: DateTime.now().toString().substring(0, 16),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        if (isLandscape) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildInputForm(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildResultCard(),
                      const SizedBox(height: 16),
                      _buildRealtimeHistorySection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputForm(),
              const SizedBox(height: 16),
              _buildResultCard(),
              const SizedBox(height: 16),
              _buildRealtimeHistorySection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Đo Chỉ Số Cơ Thể (BMI)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Chiều cao (cm)',
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n < 50 || n > 250) {
                          return '50 - 250 cm';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cân nặng (kg)',
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n < 15 || n > 300) {
                          return '15 - 300 kg';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tuổi tác',
                  prefixIcon: Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 5 || n > 120) {
                    return 'Nhập tuổi hợp lệ (5 - 120)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _calculateBmi,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text(
                  'TÍNH CHỈ SỐ BMI & LƯU ĐÁM MÂY',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_bmiResult == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Nhập chiều cao, cân nặng và nhấn Tính BMI để nhận phân tích thể trạng & lời khuyên dinh dưỡng.',
          style: TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_statusColor, const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'CHỈ SỐ BMI CỦA BẠN',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _bmiResult!.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _bmiCategory,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Thanh thước đo co dãn theo LayoutBuilder
          LayoutBuilder(
            builder: (context, constraints) {
              final normalized = ((_bmiResult! - 12) / (40 - 12)).clamp(0.0, 1.0);
              final indicatorLeft = (constraints.maxWidth - 16) * normalized;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.green,
                              Colors.orange,
                              Colors.red,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: indicatorLeft,
                        child: const Icon(
                          Icons.circle,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            _healthAdvice,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cleaning_services_outlined, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Dọn Dẹp Lịch Sử'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả lịch sử đo BMI không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              BmiService.instance.clearBmiRecords();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã dọn dẹp sạch lịch sử đo BMI.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Dọn Dẹp'),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeHistorySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<BmiRecord>>(
          stream: BmiService.instance.watchBmiRecords(),
          builder: (context, snapshot) {
            final records = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.cloud_sync_outlined, color: Color(0xFF0F766E)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lịch Sử Đo BMI (Realtime Stream)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (records.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _confirmClearHistory(context),
                        icon: const Icon(Icons.cleaning_services_outlined, size: 18, color: Colors.redAccent),
                        label: const Text(
                          'Dọn dẹp',
                          style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                const Divider(),
                if (records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Chưa có bản ghi BMI nào được lưu.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length > 5 ? 5 : records.length,
                    itemBuilder: (ctx, i) {
                      final r = records[i];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0F766E),
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                '${r.bmi}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        title: Text('${r.status} (${r.weightKg.toInt()}kg - ${r.heightCm.toInt()}cm)'),
                        subtitle: Text('Thời gian: ${r.timestamp}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                          tooltip: 'Xóa bản ghi này',
                          onPressed: () {
                            BmiService.instance.removeBmiRecordAt(i);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa bản ghi BMI.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
