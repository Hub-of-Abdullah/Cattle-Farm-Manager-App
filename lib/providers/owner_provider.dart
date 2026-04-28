import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/owner.dart';

class OwnerProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Owner> _owners = [];
  bool _isLoading = false;
  String? _error;

  List<Owner> get owners => _owners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOwners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _owners = await _db.getOwners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addOwner(Owner owner) async {
    try {
      final id = await _db.insertOwner(owner);
      _owners = [..._owners, owner.copyWith(id: id)];
      _owners.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOwner(Owner owner) async {
    try {
      await _db.updateOwner(owner);
      final index = _owners.indexWhere((o) => o.id == owner.id);
      if (index != -1) {
        _owners[index] = owner;
        _owners.sort((a, b) => a.name.compareTo(b.name));
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOwner(int id) async {
    try {
      await _db.deleteOwner(id);
      _owners = _owners.where((o) => o.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Owner? getOwnerById(int id) {
    try {
      return _owners.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
