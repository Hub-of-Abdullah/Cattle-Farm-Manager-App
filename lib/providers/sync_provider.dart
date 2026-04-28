import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../services/google_sheets_service.dart';
import 'cattle_provider.dart';
import 'expense_provider.dart';
import 'firm_deposit_provider.dart';
import 'owner_provider.dart';
import 'sale_provider.dart';

class SyncProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool _isSyncing = false;
  DateTime? _lastSync;
  String? _error;
  String? _spreadsheetUrl;

  bool get isSignedIn => _isSignedIn;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSync => _lastSync;
  String? get error => _error;
  String? get spreadsheetUrl => _spreadsheetUrl;
  String? get currentUserEmail =>
      GoogleSheetsService.currentUser?.email;

  SyncProvider() {
    _init();
  }

  Future<void> _init() async {
    _isSignedIn = await GoogleSheetsService.isSignedIn();
    if (_isSignedIn) {
      // Re-authenticate silently so the token is fresh
      await GoogleSheetsService.trySilentSignIn();
    }
    notifyListeners();
  }

  Future<void> signIn() async {
    _error = null;
    notifyListeners();
    final ok = await GoogleSheetsService.signIn();
    _isSignedIn = ok;
    if (!ok) _error = 'Google sign-in failed. Check Google Cloud setup.';
    notifyListeners();
  }

  Future<void> signOut() async {
    await GoogleSheetsService.signOut();
    _isSignedIn = false;
    _lastSync = null;
    _spreadsheetUrl = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> syncNow({
    required OwnerProvider ownerP,
    required CattleProvider cattleP,
    required ExpenseProvider expenseP,
    required SaleProvider saleP,
    required FirmDepositProvider depositP,
  }) async {
    if (!_isSignedIn) {
      _error = 'Sign in to Google first.';
      notifyListeners();
      return;
    }
    if (!await _isOnline()) {
      _error = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      final url = await GoogleSheetsService.syncAll(
        owners: ownerP.owners
            .map((o) => [
                  o.id,
                  o.name,
                  o.phone ?? '',
                  o.address ?? '',
                  o.createdAt.toIso8601String(),
                ])
            .toList(),
        cattle: cattleP.cattle
            .map((c) => [
                  c.id,
                  c.ownerId,
                  c.cattleUniqueId,
                  _date(c.purchaseDate),
                  c.purchasePrice,
                  c.isSold ? 'Yes' : 'No',
                  c.createdAt.toIso8601String(),
                ])
            .toList(),
        expenses: expenseP.expenses
            .map((e) => [
                  e.id,
                  e.ownerId ?? '',
                  _date(e.date),
                  e.category.name,
                  e.amount,
                  e.note ?? '',
                  e.createdAt.toIso8601String(),
                ])
            .toList(),
        sales: saleP.sales
            .map((s) => [
                  s.id,
                  s.cattleId,
                  _date(s.saleDate),
                  s.salePrice,
                  s.buyerName ?? '',
                  s.createdAt.toIso8601String(),
                ])
            .toList(),
        deposits: depositP.deposits
            .map((d) => [
                  d.id,
                  d.amount,
                  _date(d.date),
                  d.note ?? '',
                  d.createdAt.toIso8601String(),
                ])
            .toList(),
      );

      _spreadsheetUrl = url;
      _lastSync = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  static String _date(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
