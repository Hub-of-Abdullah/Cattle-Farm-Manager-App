import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSheetsService {
  static const _scope = SheetsApi.spreadsheetsScope;
  static const _prefKey = 'sync_spreadsheet_id';

  static final _signIn = GoogleSignIn(scopes: [_scope]);

  static GoogleSignInAccount? get currentUser => _signIn.currentUser;

  static Future<bool> signIn() async {
    try {
      final account = await _signIn.signIn();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> trySilentSignIn() async {
    try {
      final account = await _signIn.signInSilently();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> signOut() async {
    await _signIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  static Future<bool> isSignedIn() => _signIn.isSignedIn();

  static Future<SheetsApi?> _api() async {
    final client = await _signIn.authenticatedClient();
    if (client == null) return null;
    return SheetsApi(client);
  }

  // Returns the spreadsheet ID — reuses the stored one or creates a new sheet.
  static Future<String> _spreadsheetId(SheetsApi api) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);

    if (stored != null) {
      try {
        await api.spreadsheets.get(stored, $fields: 'spreadsheetId');
        return stored;
      } catch (_) {
        // Spreadsheet deleted — fall through and create a new one
      }
    }

    final ss = await api.spreadsheets.create(
      Spreadsheet(
        properties: SpreadsheetProperties(title: 'Cattle Farm Manager'),
        sheets: [
          _tab('Owners'),
          _tab('Cattle'),
          _tab('Expenses'),
          _tab('Sales'),
          _tab('Firm Deposits'),
        ],
      ),
    );

    final id = ss.spreadsheetId!;
    await prefs.setString(_prefKey, id);
    return id;
  }

  static Sheet _tab(String title) =>
      Sheet(properties: SheetProperties(title: title));

  /// Pushes all local data to Google Sheets (full overwrite per tab).
  /// Returns the URL of the spreadsheet.
  static Future<String> syncAll({
    required List<List<Object?>> owners,
    required List<List<Object?>> cattle,
    required List<List<Object?>> expenses,
    required List<List<Object?>> sales,
    required List<List<Object?>> deposits,
  }) async {
    final api = await _api();
    if (api == null) throw Exception('Not signed in to Google');

    final ssId = await _spreadsheetId(api);

    final sheetData = {
      'Owners': [
        ['ID', 'Name', 'Phone', 'Address', 'Created At'],
        ...owners,
      ],
      'Cattle': [
        ['ID', 'Owner ID', 'Cattle ID', 'Purchase Date', 'Purchase Price (৳)', 'Sold', 'Created At'],
        ...cattle,
      ],
      'Expenses': [
        ['ID', 'Owner ID', 'Date', 'Category', 'Amount (৳)', 'Note', 'Created At'],
        ...expenses,
      ],
      'Sales': [
        ['ID', 'Cattle ID', 'Sale Date', 'Sale Price (৳)', 'Buyer Name', 'Created At'],
        ...sales,
      ],
      'Firm Deposits': [
        ['ID', 'Amount (৳)', 'Date', 'Note', 'Created At'],
        ...deposits,
      ],
    };

    // Clear all existing data first
    await api.spreadsheets.values.batchClear(
      BatchClearValuesRequest(
        ranges: sheetData.keys.map((s) => '$s!A:Z').toList(),
      ),
      ssId,
    );

    // Write fresh data
    await api.spreadsheets.values.batchUpdate(
      BatchUpdateValuesRequest(
        valueInputOption: 'RAW',
        data: sheetData.entries
            .map((e) => ValueRange(
                  range: '${e.key}!A1',
                  values: e.value
                      .map((row) => row.map((c) => c ?? '').toList())
                      .toList(),
                ))
            .toList(),
      ),
      ssId,
    );

    return 'https://docs.google.com/spreadsheets/d/$ssId';
  }
}
