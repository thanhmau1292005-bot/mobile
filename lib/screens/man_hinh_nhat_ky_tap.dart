import 'package:flutter/material.dart';
import '../models/mo_hinh_tap_luyen.dart';
import '../services/co_so_du_lieu_helper.dart';

class ManHinhNhatKyTap extends StatefulWidget {
  const ManHinhNhatKyTap({super.key});

  @override
  State<ManHinhNhatKyTap> createState() => _ManHinhNhatKyTapState();
}

// Tên tương thích cũ
typedef WorkoutScreen = ManHinhNhatKyTap;

class _ManHinhNhatKyTapState extends State<ManHinhNhatKyTap> {
  List<BaiTapItem> _workouts = [];
  bool _isLoading = true;
  String _searchText = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshWorkouts();
  }

  Future<void> _refreshWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final data = await CoSoDuLieuHelper.instance.readAllWorkouts();
      if (mounted) {
        setState(() {
          _workouts = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openWorkoutForm({BaiTapItem? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final setsCtrl = TextEditingController(text: existing?.sets.toString() ?? '3');
    final repsCtrl = TextEditingController(text: existing?.reps.toString() ?? '12');
    final calCtrl = TextEditingController(text: existing?.calories.toString() ?? '150');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null ? 'Thêm Bài Tập Mới' : 'Cập Nhật Bài Tập',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['Hít đất', 'Squat', 'Plank', 'Nhảy dây', 'Đạp xe']
                      .map(
                        (preset) => ActionChip(
                          label: Text(preset),
                          onPressed: () => nameCtrl.text = preset,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên bài tập',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập tên bài tập' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: setsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số hiệp (Sets)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (int.tryParse(v ?? '') == null) ? 'Nhập số' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: repsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số lần lặp (Reps)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (int.tryParse(v ?? '') == null) ? 'Nhập số' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: calCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calo tiêu thụ (kcal)',
                    prefixIcon: Icon(Icons.local_fire_department_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (int.tryParse(v ?? '') == null) ? 'Nhập lượng Calo' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      final item = BaiTapItem(
                        id: existing?.id,
                        name: nameCtrl.text.trim(),
                        sets: int.parse(setsCtrl.text.trim()),
                        reps: int.parse(repsCtrl.text.trim()),
                        calories: int.parse(calCtrl.text.trim()),
                        createdAt: existing?.createdAt ??
                            DateTime.now().toString().substring(0, 16),
                      );
                      if (existing == null) {
                        await CoSoDuLieuHelper.instance.createWorkout(item);
                      } else {
                        await CoSoDuLieuHelper.instance.updateWorkout(item);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _refreshWorkouts();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              existing == null
                                  ? 'Đã thêm bài tập "${item.name}"!'
                                  : 'Đã cập nhật bài tập "${item.name}"!',
                            ),
                            backgroundColor: const Color(0xFF0F766E),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi lưu bài tập: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(existing == null ? 'LƯU BÀI TẬP' : 'CẬP NHẬT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BaiTapItem item) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bài tập?'),
        content: Text('Bạn chắc chắn muốn xóa "${item.name}" khỏi nhật ký?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await CoSoDuLieuHelper.instance.deleteWorkout(item.id!);
              _refreshWorkouts();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _workouts
        .where((w) => w.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    final totalCalories =
        filtered.fold<int>(0, (sum, item) => sum + item.calories);
    final totalSets = filtered.fold<int>(0, (sum, item) => sum + item.sets);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWorkoutForm(),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm Bài Tập'),
      ),
      body: Column(
        children: [
          // Thẻ tổng kết năng lượng đốt cháy
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _statCol('Bài tập', '${filtered.length}')),
                Expanded(child: _statCol('Tổng hiệp', '$totalSets sets')),
                Expanded(child: _statCol('Đốt cháy', '$totalCalories kcal')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchText = v),
              decoration: InputDecoration(
                hintText: 'Tìm bài tập trong nhật ký...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('Chưa có bài tập nào phù hợp.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 80),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final w = filtered[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.withAlpha(35),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                              title: Text(
                                w.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${w.sets} hiệp × ${w.reps} lần  •  🔥 ${w.calories} kcal\nNgày: ${w.createdAt}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                    onPressed: () => _openWorkoutForm(existing: w),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(w),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statCol(String label, String value) {
    return Column(
      children: [
        FittedBox(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
