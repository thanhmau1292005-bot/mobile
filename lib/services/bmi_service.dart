import 'dart:async';
import '../models/workout_model.dart';

class BmiService {
  static final BmiService instance = BmiService._();
  BmiService._();

  final List<BmiRecord> _bmiRecords = [];
  final StreamController<List<BmiRecord>> _bmiController =
      StreamController<List<BmiRecord>>.broadcast();

  Future<void> saveBmiRecord(BmiRecord record) async {
    _bmiRecords.insert(0, record);
    _bmiController.add(List<BmiRecord>.from(_bmiRecords));
  }

  Future<void> clearBmiRecords() async {
    _bmiRecords.clear();
    _bmiController.add(List<BmiRecord>.from(_bmiRecords));
  }

  Future<void> removeBmiRecordAt(int index) async {
    if (index >= 0 && index < _bmiRecords.length) {
      _bmiRecords.removeAt(index);
      _bmiController.add(List<BmiRecord>.from(_bmiRecords));
    }
  }

  Stream<List<BmiRecord>> watchBmiRecords() async* {
    yield List<BmiRecord>.from(_bmiRecords);
    yield* _bmiController.stream;
  }
}
