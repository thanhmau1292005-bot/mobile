import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/workout_model.dart';
import '../services/api_service.dart';

class CalorieScreen extends StatefulWidget {
  const CalorieScreen({super.key});

  @override
  State<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends State<CalorieScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late Future<List<FoodCalorieItem>> _foodsFuture;
  int _plannedCaloriesToday = 0;

  @override
  void initState() {
    super.initState();
    _foodsFuture = ApiService.fetchFoodCalories();
  }

  void _triggerSearch() {
    setState(() {
      _foodsFuture = ApiService.fetchFoodCalories(
        query: _searchController.text,
      );
    });
  }

  Future<void> _launchGoogleSearch(String rawQuery) async {
    final term = rawQuery.trim().isEmpty ? 'món ăn' : rawQuery.trim();
    final url = Uri.parse(
      'https://www.google.com/search?q=${Uri.encodeComponent("calo món $term")}',
    );
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await launchUrl(url);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở trình duyệt tìm kiếm: "calo món $term"'),
          ),
        );
      }
    }
  }

  Future<void> _addMealToPlan(FoodCalorieItem food) async {
    setState(() {
      _plannedCaloriesToday += food.caloriesPerServing;
    });
    try {
      await ApiService.addFoodToMealPlanServer(food);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã thêm "${food.name}" (+${food.caloriesPerServing} kcal) vào thực đơn!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  void _showAddFoodDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController(text: '350');
    final cuisineCtrl = TextEditingController(text: 'Việt Nam');
    final formKey = GlobalKey<FormState>();
    final ImagePicker picker = ImagePicker();
    String? pickedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> pickImage(ImageSource source) async {
            try {
              final XFile? image = await picker.pickImage(
                source: source,
                maxWidth: 800,
                maxHeight: 800,
                imageQuality: 85,
              );
              if (image != null) {
                setSheetState(() {
                  pickedImagePath = image.path;
                });
              }
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Không thể chọn ảnh: $e')),
                );
              }
            }
          }

          return Padding(
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
                    const Row(
                      children: [
                        Icon(Icons.restaurant, color: Color(0xFF0F766E)),
                        SizedBox(width: 8),
                        Text(
                          'Thêm Món Ăn Tự Nhập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Phở bò',
                        'Bánh mì',
                        'Cơm tấm',
                        'Bún chả',
                        'Trà sữa',
                      ]
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
                        labelText: 'Tên món ăn (vd: Phở bò, Trà sữa...)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng nhập tên món'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: calCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Calo (kcal)',
                              border: OutlineInputBorder(),
                              prefixIcon:
                                  Icon(Icons.local_fire_department_outlined),
                            ),
                            validator: (v) => (int.tryParse(v ?? '') == null)
                                ? 'Nhập số hợp lệ'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: cuisineCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Ẩm thực',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.public_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Ghi chú & Nút tìm kiếm Google Calo theo yêu cầu
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.orange),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Tra cứu calo món ăn trên Google',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _launchGoogleSearch(nameCtrl.text),
                            child: const Row(
                              children: [
                                Icon(Icons.search, size: 16, color: Colors.blue),
                                SizedBox(width: 4),
                                Text(
                                  'Tra cứu nhanh Calo món này trên Google',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Chọn ảnh từ thiết bị (Gallery / Camera)
                    const Text(
                      'Hình ảnh món ăn (Chọn từ trong máy):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Thư viện máy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade50,
                            foregroundColor: const Color(0xFF0F766E),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Chụp ảnh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade50,
                            foregroundColor: const Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                    if (pickedImagePath != null &&
                        pickedImagePath!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(pickedImagePath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final newItem = FoodCalorieItem(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: nameCtrl.text.trim(),
                          caloriesPerServing: int.parse(calCtrl.text.trim()),
                          prepTimeMinutes: 10,
                          servings: 1,
                          cuisine: cuisineCtrl.text.trim().isEmpty
                              ? 'Món tự thêm'
                              : cuisineCtrl.text.trim(),
                          image: pickedImagePath ?? '',
                        );
                        ApiService.addCustomFood(newItem);
                        Navigator.pop(ctx);
                        _triggerSearch();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã thêm món "${newItem.name}" thành công!',
                              ),
                              backgroundColor: const Color(0xFF0F766E),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'LƯU MÓN ĂN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteCustomFood(FoodCalorieItem food) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa món ăn?'),
        content: Text('Bạn muốn xóa món "${food.name}" khỏi danh sách?'),
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
            onPressed: () {
              Navigator.pop(ctx);
              ApiService.deleteCustomFood(food.id);
              _triggerSearch();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(String imagePath) {
    if (imagePath.isEmpty) {
      return const Center(child: Icon(Icons.fastfood, size: 40));
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.fastfood, size: 40)),
      );
    }
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.fastfood, size: 40)),
      );
    }
    return const Center(child: Icon(Icons.fastfood, size: 40));
  }

  Widget _buildCalorieSummaryBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEA580C), Color(0xFFF97316)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thực đơn dự kiến hôm nay',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$_plannedCaloriesToday kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_plannedCaloriesToday > 0)
            TextButton(
              onPressed: () => setState(() => _plannedCaloriesToday = 0),
              child: const Text(
                'Đặt lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoogleInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF0F766E)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Tra cứu calo món ăn trên Google',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
            tooltip: 'Tìm trên Google',
            onPressed: () => _launchGoogleSearch(_searchController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({bool isLandscape = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: isLandscape
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _triggerSearch(),
                  decoration: InputDecoration(
                    hintText: 'Tìm món...',
                    prefixIcon: const Icon(Icons.restaurant_menu),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _triggerSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Tra cứu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _triggerSearch(),
                    decoration: InputDecoration(
                      hintText: 'Tìm món (vd: Phở, Cơm, Salad...)',
                      prefixIcon: const Icon(Icons.restaurant_menu),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _triggerSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Tra cứu'),
                ),
              ],
            ),
    );
  }

  Widget _buildFoodGrid({required bool isLandscape}) {
    return FutureBuilder<List<FoodCalorieItem>>(
      future: _foodsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Không thể tải dữ liệu REST API:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _triggerSearch,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(
            child: Text('Không tìm thấy món ăn phù hợp.'),
          );
        }

        final crossCount = isLandscape ? 2 : 2;
        final childAspectRatio = isLandscape ? 0.85 : 0.74;

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(14),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final food = items[i];
            final bool isCustom = food.id >= 900000;

            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFoodImage(food.image),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ẩm thực: ${food.cuisine}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${food.caloriesPerServing} kcal',
                                    style: const TextStyle(
                                      color: Color(0xFFEA580C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _addMealToPlan(food),
                                  child: const CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Color(0xFF0F766E),
                                    child: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isCustom)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Tự thêm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isCustom)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () => _deleteCustomFood(food),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        return Scaffold(
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'btn_add_custom_food',
                onPressed: _showAddFoodDialog,
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Thêm Món'),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.small(
                heroTag: 'btn_scroll_top',
                onPressed: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  }
                },
                tooltip: 'Lên đầu trang',
                child: const Icon(Icons.arrow_upward),
              ),
            ],
          ),
          body: isLandscape
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 270,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          children: [
                            _buildCalorieSummaryBanner(),
                            _buildGoogleInfoBanner(),
                            _buildSearchBar(isLandscape: true),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _buildFoodGrid(isLandscape: true),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildCalorieSummaryBanner(),
                    _buildGoogleInfoBanner(),
                    _buildSearchBar(isLandscape: false),
                    Expanded(
                      child: _buildFoodGrid(isLandscape: false),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
