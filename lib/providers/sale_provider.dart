import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/sale.dart';

class SaleProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Sale> _sales = [];
  bool _isLoading = false;
  String? _error;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalRevenue =>
      _sales.fold(0.0, (sum, s) => sum + s.salePrice);

  Sale? getSaleForCattle(int cattleId) {
    try {
      return _sales.firstWhere((s) => s.cattleId == cattleId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sales = await _db.getAllSales();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordSale(Sale sale) async {
    try {
      final id = await _db.insertSale(sale);
      _sales = [sale.copyWith(id: id), ..._sales];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSale(int id, int cattleId) async {
    try {
      await _db.deleteSale(id);
      _sales = _sales.where((s) => s.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
