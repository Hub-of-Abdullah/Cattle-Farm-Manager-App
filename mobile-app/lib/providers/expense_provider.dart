import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Expense> getExpensesForOwner(int ownerId) =>
      _expenses.where((e) => e.ownerId == ownerId).toList();

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double totalForOwner(int ownerId) =>
      getExpensesForOwner(ownerId).fold(0.0, (sum, e) => sum + e.amount);

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _expenses = await _db.getAllExpenses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      final id = await _db.insertExpense(expense);
      _expenses = [expense.copyWith(id: id), ..._expenses];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      await _db.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) _expenses[index] = expense;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _db.deleteExpense(id);
      _expenses = _expenses.where((e) => e.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
