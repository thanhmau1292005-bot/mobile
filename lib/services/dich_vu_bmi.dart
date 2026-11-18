import 'dart:async';
import '../models/mo_hinh_tap_luyen.dart';

class DichVuBmi {
  static final DichVuBmi instance = DichVuBmi._();
  DichVuBmi._();

  final List<BanGhiBmi> _bmiRecords = [];
  final StreamController<List<BanGhiBmi>> _bmiController =
      StreamController<List<BanGhiBmi>>.broadcast();

  Future<void> saveBmiRecord(BanGhiBmi record) async {
    _bmiRecords.insert(0, record);
    _bmiController.add(List<BanGhiBmi>.from(_bmiRecords));
  }

  Future<void> clearBmiRecords() async {
    _bmiRecords.clear();
    _bmiController.add(List<BanGhiBmi>.from(_bmiRecords));
  }

  Future<void> removeBmiRecordAt(int index) async {
    if (index >= 0 && index < _bmiRecords.length) {
      _bmiRecords.removeAt(index);
      _bmiController.add(List<BanGhiBmi>.from(_bmiRecords));
    }
  }

  Stream<List<BanGhiBmi>> watchBmiRecords() async* {
    yield List<BanGhiBmi>.from(_bmiRecords);
    yield* _bmiController.stream;
  }
}

// Tên tương thích cũ
typedef BmiService = DichVuBmi;
