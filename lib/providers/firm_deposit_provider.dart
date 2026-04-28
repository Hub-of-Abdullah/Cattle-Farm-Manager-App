import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/firm_deposit.dart';

class FirmDepositProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<FirmDeposit> _deposits = [];
  bool _isLoading = false;
  String? _error;

  List<FirmDeposit> get deposits => _deposits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalDeposits =>
      _deposits.fold(0.0, (sum, d) => sum + d.amount);

  Future<void> loadDeposits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _deposits = await _db.getAllDeposits();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDeposit(FirmDeposit deposit) async {
    try {
      final id = await _db.insertDeposit(deposit);
      _deposits = [deposit.copyWith(id: id), ..._deposits];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDeposit(int id) async {
    try {
      await _db.deleteDeposit(id);
      _deposits = _deposits.where((d) => d.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
