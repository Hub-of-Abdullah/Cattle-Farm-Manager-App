import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/cattle.dart';

class CattleProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Cattle> _cattle = [];
  bool _isLoading = false;
  String? _error;

  List<Cattle> get cattle => _cattle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Cattle> get activeCattle => _cattle.where((c) => !c.isSold).toList();
  List<Cattle> get soldCattle => _cattle.where((c) => c.isSold).toList();

  List<Cattle> getCattleByOwner(int ownerId) =>
      _cattle.where((c) => c.ownerId == ownerId).toList();

  Future<void> loadCattle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cattle = await _db.getAllCattle();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCattle(Cattle cattle) async {
    try {
      final id = await _db.insertCattle(cattle);
      _cattle = [cattle.copyWith(id: id), ..._cattle];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCattle(Cattle cattle) async {
    try {
      await _db.updateCattle(cattle);
      final index = _cattle.indexWhere((c) => c.id == cattle.id);
      if (index != -1) _cattle[index] = cattle;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsSold(int cattleId) async {
    final index = _cattle.indexWhere((c) => c.id == cattleId);
    if (index == -1) return false;
    final updated = _cattle[index].copyWith(isSold: true);
    return updateCattle(updated);
  }

  Future<bool> deleteCattle(int id) async {
    try {
      await _db.deleteCattle(id);
      _cattle = _cattle.where((c) => c.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> isUniqueIdTaken(String uniqueId, {int? excludeId}) async {
    return _db.isCattleUniqueIdTaken(uniqueId, excludeId: excludeId);
  }

  Cattle? getCattleById(int id) {
    try {
      return _cattle.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
