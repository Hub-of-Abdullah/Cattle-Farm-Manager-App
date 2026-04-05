import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
      version: 1,
      onCreate: _createDB,
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

    // Create owners table
    await db.execute('''
      CREATE TABLE owners (
        id $idType,
        name $textType,
        phone $textNullableType,
        address $textNullableType,
        created_at $textType
      )
    ''');

    // Create cattle table
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

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        cattle_id $integerNullableType,
        date $textType,
        category $textType,
        amount $realType,
        note $textNullableType,
        created_at $textType,
        FOREIGN KEY (cattle_id) REFERENCES cattle (id) ON DELETE CASCADE
      )
    ''');

    // Create sales table
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

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_cattle_owner ON cattle(owner_id)');
    await db.execute('CREATE INDEX idx_expenses_cattle ON expenses(cattle_id)');
    await db.execute('CREATE INDEX idx_sales_cattle ON sales(cattle_id)');
    await db.execute('CREATE INDEX idx_cattle_sold ON cattle(is_sold)');
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
