import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/mo_hinh_tap_luyen.dart';

class CoSoDuLieuHelper {
  static final CoSoDuLieuHelper instance = CoSoDuLieuHelper._init();
  static Database? _database;
  bool _useLocalFallback = false;

  final List<BaiTapItem> _localWorkouts = [];
  int _localNextId = 1;

  CoSoDuLieuHelper._init() {
    _initLocalPresets();
  }

  void _initLocalPresets() {
    final now = DateTime.now().toString().substring(0, 16);
    _localWorkouts.addAll([
      BaiTapItem(
        id: _localNextId++,
        name: 'Hít đất cơ ngực (Push-ups)',
        sets: 4,
        reps: 15,
        calories: 120,
        createdAt: now,
      ),
      BaiTapItem(
        id: _localNextId++,
        name: 'Gánh đùi mông (Squats)',
        sets: 4,
        reps: 20,
        calories: 180,
        createdAt: now,
      ),
      BaiTapItem(
        id: _localNextId++,
        name: 'Chạy bộ đốt mỡ (Cardio)',
        sets: 1,
        reps: 30,
        calories: 250,
        createdAt: now,
      ),
    ]);
  }

  Future<Database?> get database async {
    if (_useLocalFallback) return null;
    if (_database != null) return _database;
    try {
      _database = await _initDB('health_workout_v1.db');
      return _database;
    } catch (e) {
      debugPrint('Lỗi khởi tạo SQLite, chuyển sang bộ nhớ cục bộ: $e');
      _useLocalFallback = true;
      return null;
    }
  }

  Future<Database> _initDB(String fileName) async {
    final Directory docsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(docsDir.path, fileName);
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    final now = DateTime.now().toString().substring(0, 16);
    await db.insert('workouts', {
      'name': 'Hít đất cơ ngực (Push-ups)',
      'sets': 4,
      'reps': 15,
      'calories': 120,
      'createdAt': now,
    });
    await db.insert('workouts', {
      'name': 'Gánh đùi mông (Squats)',
      'sets': 4,
      'reps': 20,
      'calories': 180,
      'createdAt': now,
    });
    await db.insert('workouts', {
      'name': 'Chạy bộ đốt mỡ (Cardio)',
      'sets': 1,
      'reps': 30,
      'calories': 250,
      'createdAt': now,
    });
  }

  // TẠO BÀI TẬP MỚI
  Future<int> createWorkout(BaiTapItem item) async {
    try {
      final db = await database;
      if (db != null) {
        final newId = await db.insert('workouts', item.toMap());
        return newId;
      }
    } catch (e) {
      debugPrint('Lỗi SQLite createWorkout, chuyển sang danh sách bộ nhớ: $e');
      _useLocalFallback = true;
    }

    final newId = _localNextId++;
    final newItem = BaiTapItem(
      id: newId,
      name: item.name,
      sets: item.sets,
      reps: item.reps,
      calories: item.calories,
      createdAt: item.createdAt,
    );
    _localWorkouts.insert(0, newItem);
    return newId;
  }

  // ĐỌC DANH SÁCH BÀI TẬP
  Future<List<BaiTapItem>> readAllWorkouts() async {
    try {
      final db = await database;
      if (db != null) {
        final result = await db.query('workouts', orderBy: 'id DESC');
        return result.map((row) => BaiTapItem.fromMap(row)).toList();
      }
    } catch (e) {
      debugPrint('Lỗi SQLite readAllWorkouts, chuyển sang danh sách bộ nhớ: $e');
      _useLocalFallback = true;
    }
    return List<BaiTapItem>.from(_localWorkouts);
  }

  // CẬP NHẬT BÀI TẬP
  Future<int> updateWorkout(BaiTapItem item) async {
    try {
      final db = await database;
      if (db != null && item.id != null) {
        return await db.update(
          'workouts',
          item.toMap(),
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }
    } catch (e) {
      debugPrint('Lỗi SQLite updateWorkout, chuyển sang danh sách bộ nhớ: $e');
      _useLocalFallback = true;
    }

    final index = _localWorkouts.indexWhere((w) => w.id == item.id);
    if (index != -1) {
      _localWorkouts[index] = item;
      return 1;
    }
    return 0;
  }

  // XÓA BÀI TẬP
  Future<int> deleteWorkout(int id) async {
    try {
      final db = await database;
      if (db != null) {
        return await db.delete(
          'workouts',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      debugPrint('Lỗi SQLite deleteWorkout, chuyển sang danh sách bộ nhớ: $e');
      _useLocalFallback = true;
    }

    _localWorkouts.removeWhere((w) => w.id == id);
    return 1;
  }
}

// Tên tương thích cũ
typedef DatabaseHelper = CoSoDuLieuHelper;
