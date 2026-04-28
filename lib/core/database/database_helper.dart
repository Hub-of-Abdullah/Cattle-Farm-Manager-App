import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../models/owner.dart';
import '../../models/cattle.dart';
import '../../models/expense.dart';
import '../../models/firm_deposit.dart';
import '../../models/sale.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cattle_farm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final Directory dbPath = await getApplicationDocumentsDirectory();
    final String path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullableType = 'INTEGER';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';

    await db.execute('''
      CREATE TABLE owners (
        id $idType,
        name $textType,
        phone $textNullableType,
        address $textNullableType,
        created_at $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE cattle (
        id $idType,
        owner_id $integerType,
        cattle_unique_id $textType UNIQUE,
        purchase_date $textType,
        purchase_price $realType,
        is_sold $boolType,
        created_at $textType,
        FOREIGN KEY (owner_id) REFERENCES owners (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        owner_id $integerNullableType,
        date $textType,
        category $textType,
        custom_category $textNullableType,
        amount $realType,
        note $textNullableType,
        created_at $textType,
        FOREIGN KEY (owner_id) REFERENCES owners (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        cattle_id $integerType UNIQUE,
        sale_date $textType,
        sale_price $realType,
        buyer_name $textNullableType,
        created_at $textType,
        FOREIGN KEY (cattle_id) REFERENCES cattle (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE firm_deposits (
        id $idType,
        amount $realType,
        date $textType,
        note $textNullableType,
        created_at $textType
      )
    ''');

    await db.execute('CREATE INDEX idx_cattle_owner ON cattle(owner_id)');
    await db.execute('CREATE INDEX idx_expenses_owner ON expenses(owner_id)');
    await db.execute('CREATE INDEX idx_sales_cattle ON sales(cattle_id)');
    await db.execute('CREATE INDEX idx_cattle_sold ON cattle(is_sold)');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS firm_deposits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add owner_id column; old cattle_id rows will have owner_id = null
      await db.execute(
          'ALTER TABLE expenses ADD COLUMN owner_id INTEGER REFERENCES owners(id) ON DELETE CASCADE');
    }
    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE expenses ADD COLUMN custom_category TEXT');
    }
  }

  // ── Owner CRUD ──────────────────────────────────────────────────────────────

  Future<int> insertOwner(Owner owner) async {
    final db = await database;
    final map = owner.toMap()..remove('id');
    return await db.insert('owners', map);
  }

  Future<List<Owner>> getOwners() async {
    final db = await database;
    final rows = await db.query('owners', orderBy: 'name ASC');
    return rows.map(Owner.fromMap).toList();
  }

  Future<Owner?> getOwnerById(int id) async {
    final db = await database;
    final rows = await db.query('owners', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Owner.fromMap(rows.first);
  }

  Future<int> updateOwner(Owner owner) async {
    final db = await database;
    return await db.update(
      'owners',
      owner.toMap(),
      where: 'id = ?',
      whereArgs: [owner.id],
    );
  }

  Future<int> deleteOwner(int id) async {
    final db = await database;
    return await db.delete('owners', where: 'id = ?', whereArgs: [id]);
  }

  // ── Cattle CRUD ─────────────────────────────────────────────────────────────

  Future<int> insertCattle(Cattle cattle) async {
    final db = await database;
    final map = cattle.toMap()..remove('id');
    return await db.insert('cattle', map);
  }

  Future<List<Cattle>> getAllCattle() async {
    final db = await database;
    final rows = await db.query('cattle', orderBy: 'created_at DESC');
    return rows.map(Cattle.fromMap).toList();
  }

  Future<List<Cattle>> getCattleByOwner(int ownerId) async {
    final db = await database;
    final rows = await db.query(
      'cattle',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(Cattle.fromMap).toList();
  }

  Future<Cattle?> getCattleById(int id) async {
    final db = await database;
    final rows = await db.query('cattle', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Cattle.fromMap(rows.first);
  }

  Future<bool> isCattleUniqueIdTaken(String uniqueId, {int? excludeId}) async {
    final db = await database;
    List<Map<String, dynamic>> rows;
    if (excludeId != null) {
      rows = await db.query(
        'cattle',
        where: 'cattle_unique_id = ? AND id != ?',
        whereArgs: [uniqueId, excludeId],
      );
    } else {
      rows = await db.query(
        'cattle',
        where: 'cattle_unique_id = ?',
        whereArgs: [uniqueId],
      );
    }
    return rows.isNotEmpty;
  }

  Future<int> updateCattle(Cattle cattle) async {
    final db = await database;
    return await db.update(
      'cattle',
      cattle.toMap(),
      where: 'id = ?',
      whereArgs: [cattle.id],
    );
  }

  Future<int> deleteCattle(int id) async {
    final db = await database;
    return await db.delete('cattle', where: 'id = ?', whereArgs: [id]);
  }

  // ── Expense CRUD ─────────────────────────────────────────────────────────────

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    final map = expense.toMap()..remove('id');
    return await db.insert('expenses', map);
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'date DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getExpensesByOwner(int ownerId) async {
    final db = await database;
    final rows = await db.query(
      'expenses',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<double> getTotalExpensesForOwner(int ownerId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE owner_id = ?',
      [ownerId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ── Sale CRUD ────────────────────────────────────────────────────────────────

  Future<int> insertSale(Sale sale) async {
    final db = await database;
    final map = sale.toMap()..remove('id');
    return await db.insert('sales', map);
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final rows = await db.query('sales', orderBy: 'sale_date DESC');
    return rows.map(Sale.fromMap).toList();
  }

  Future<Sale?> getSaleByCattle(int cattleId) async {
    final db = await database;
    final rows = await db.query(
      'sales',
      where: 'cattle_id = ?',
      whereArgs: [cattleId],
    );
    if (rows.isEmpty) return null;
    return Sale.fromMap(rows.first);
  }

  Future<int> deleteSale(int id) async {
    final db = await database;
    return await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  // ── Firm Deposit CRUD ────────────────────────────────────────────────────────

  Future<int> insertDeposit(FirmDeposit deposit) async {
    final db = await database;
    final map = deposit.toMap()..remove('id');
    return await db.insert('firm_deposits', map);
  }

  Future<List<FirmDeposit>> getAllDeposits() async {
    final db = await database;
    final rows = await db.query('firm_deposits', orderBy: 'date DESC');
    return rows.map(FirmDeposit.fromMap).toList();
  }

  Future<int> deleteDeposit(int id) async {
    final db = await database;
    return await db.delete('firm_deposits', where: 'id = ?', whereArgs: [id]);
  }

  // ── Dashboard Stats ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    final ownerCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM owners'),
        ) ??
        0;

    final totalCattle = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cattle'),
        ) ??
        0;

    final activeCattle = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cattle WHERE is_sold = 0'),
        ) ??
        0;

    final soldCattle = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cattle WHERE is_sold = 1'),
        ) ??
        0;

    final totalExpenses = (await db.rawQuery(
              'SELECT SUM(amount) as total FROM expenses',
            ))
            .first['total'] as num? ??
        0;

    final totalRevenue = (await db.rawQuery(
              'SELECT SUM(sale_price) as total FROM sales',
            ))
            .first['total'] as num? ??
        0;

    final totalPurchaseCost = (await db.rawQuery(
              'SELECT SUM(purchase_price) as total FROM cattle WHERE is_sold = 1',
            ))
            .first['total'] as num? ??
        0;

    final totalCost = totalPurchaseCost.toDouble() + totalExpenses.toDouble();
    final profitLoss = totalRevenue.toDouble() - totalCost;

    return {
      'ownerCount': ownerCount,
      'totalCattle': totalCattle,
      'activeCattle': activeCattle,
      'soldCattle': soldCattle,
      'totalExpenses': totalExpenses.toDouble(),
      'totalRevenue': totalRevenue.toDouble(),
      'profitLoss': profitLoss,
    };
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
