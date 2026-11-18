class BaiTapItem {
  final int? id;
  final String name;
  final int sets;
  final int reps;
  final int calories;
  final String createdAt;

  BaiTapItem({
    this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.calories,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'sets': sets,
      'reps': reps,
      'calories': calories,
      'createdAt': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory BaiTapItem.fromMap(Map<String, dynamic> map) {
    return BaiTapItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      calories: map['calories'] as int,
      createdAt: map['createdAt'] as String,
    );
  }
}

// Tên tương thích cũ
typedef WorkoutItem = BaiTapItem;

class MonAnCaloItem {
  final int id;
  final String name;
  final int caloriesPerServing;
  final int prepTimeMinutes;
  final int servings;
  final String cuisine;
  final String image;

  MonAnCaloItem({
    required this.id,
    required this.name,
    required this.caloriesPerServing,
    required this.prepTimeMinutes,
    required this.servings,
    required this.cuisine,
    required this.image,
  });

  factory MonAnCaloItem.fromJson(Map<String, dynamic> json) {
    return MonAnCaloItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Món ăn dinh dưỡng',
      caloriesPerServing: (json['caloriesPerServing'] as num?)?.toInt() ?? 250,
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 15,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      cuisine: json['cuisine']?.toString() ?? 'Quốc tế',
      image: json['image']?.toString() ?? '',
    );
  }
}

// Tên tương thích cũ
typedef FoodCalorieItem = MonAnCaloItem;

class BanGhiBmi {
  final double bmi;
  final String status;
  final double heightCm;
  final double weightKg;
  final String timestamp;

  BanGhiBmi({
    required this.bmi,
    required this.status,
    required this.heightCm,
    required this.weightKg,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'bmi': bmi,
      'status': status,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'timestamp': timestamp,
    };
  }

  factory BanGhiBmi.fromMap(Map<String, dynamic> map) {
    return BanGhiBmi(
      bmi: (map['bmi'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? '',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp']?.toString() ?? '',
    );
  }
}

// Tên tương thích cũ
typedef BmiRecord = BanGhiBmi;
