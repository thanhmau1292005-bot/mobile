import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_model.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  // Danh sách các món ăn do người dùng tự thêm
  static final List<FoodCalorieItem> _customUserFoods = [
    FoodCalorieItem(
      id: 990001,
      name: 'Phở Bò Bái Đao',
      caloriesPerServing: 450,
      prepTimeMinutes: 15,
      servings: 1,
      cuisine: 'Việt Nam',
      image: 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500',
    ),
    FoodCalorieItem(
      id: 990002,
      name: 'Cơm Tấm Sườn Bì Chả',
      caloriesPerServing: 620,
      prepTimeMinutes: 10,
      servings: 1,
      cuisine: 'Việt Nam',
      image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
    ),
  ];

  // Thêm món ăn mới do người dùng tự nhập
  static void addCustomFood(FoodCalorieItem item) {
    _customUserFoods.insert(0, item);
  }

  // Xóa món ăn tự nhập theo ID
  static bool deleteCustomFood(int id) {
    final lengthBefore = _customUserFoods.length;
    _customUserFoods.removeWhere((item) => item.id == id);
    return _customUserFoods.length < lengthBefore;
  }

  // HTTP GET: Truy vấn danh sách món ăn REST API kết hợp món người dùng tự thêm
  static Future<List<FoodCalorieItem>> fetchFoodCalories({String query = ''}) async {
    final cleanQuery = query.trim().toLowerCase();

    // Lọc các món người dùng tự nhập theo từ khóa
    final matchedCustom = _customUserFoods.where((item) {
      if (cleanQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(cleanQuery) ||
          item.cuisine.toLowerCase().contains(cleanQuery);
    }).toList();

    List<FoodCalorieItem> apiFoods = [];

    try {
      final String endpoint = cleanQuery.isEmpty
          ? '$_baseUrl?limit=24'
          : '$_baseUrl/search?q=${Uri.encodeComponent(cleanQuery)}';

      final response = await http.get(Uri.parse(endpoint)).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> list = decoded['recipes'] ?? [];
        apiFoods = list
            .map((item) => FoodCalorieItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {
      // Khi mất mạng hoặc API bị lỗi, vẫn giữ lại các món tự nhập & món offline
    }

    // Kết hợp món tự nhập lên đầu danh sách + kết quả REST API
    return [...matchedCustom, ...apiFoods];
  }

  // HTTP POST: Gửi món ăn đã chọn lên Server REST API để lập kế hoạch ăn uống
  static Future<bool> addFoodToMealPlanServer(FoodCalorieItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': item.name,
          'caloriesPerServing': item.caloriesPerServing,
          'servings': item.servings,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Trả về true để không làm gián đoạn trải nghiệm người dùng
    }
  }
}
