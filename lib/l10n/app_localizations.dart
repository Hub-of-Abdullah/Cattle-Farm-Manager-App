import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle
        .loadString('lib/l10n/app_${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Convenience getters for commonly used strings
  String get appTitle => translate('appTitle');
  String get home => translate('home');
  String get owners => translate('owners');
  String get cattle => translate('cattle');
  String get reports => translate('reports');
  String get settings => translate('settings');
  String get owner => translate('owner');
  String get ownerName => translate('ownerName');
  String get phone => translate('phone');
  String get address => translate('address');
  String get addOwner => translate('addOwner');
  String get editOwner => translate('editOwner');
  String get ownerDetails => translate('ownerDetails');
  String get totalCattle => translate('totalCattle');
  String get activeCattle => translate('activeCattle');
  String get soldCattle => translate('soldCattle');
  String get cattleId => translate('cattleId');
  String get purchaseDate => translate('purchaseDate');
  String get purchasePrice => translate('purchasePrice');
  String get addCattle => translate('addCattle');
  String get editCattle => translate('editCattle');
  String get cattleDetails => translate('cattleDetails');
  String get status => translate('status');
  String get active => translate('active');
  String get sold => translate('sold');
  String get expense => translate('expense');
  String get expenses => translate('expenses');
  String get addExpense => translate('addExpense');
  String get category => translate('category');
  String get amount => translate('amount');
  String get date => translate('date');
  String get note => translate('note');
  String get totalExpenses => translate('totalExpenses');
  String get categoryFood => translate('categoryFood');
  String get categoryMedicine => translate('categoryMedicine');
  String get categoryDoctor => translate('categoryDoctor');
  String get categoryOther => translate('categoryOther');
  String get sale => translate('sale');
  String get sellCattle => translate('sellCattle');
  String get saleDate => translate('saleDate');
  String get salePrice => translate('salePrice');
  String get buyerName => translate('buyerName');
  String get profit => translate('profit');
  String get loss => translate('loss');
  String get profitLoss => translate('profitLoss');
  String get totalCost => translate('totalCost');
  String get totalRevenue => translate('totalRevenue');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get search => translate('search');
  String get filter => translate('filter');
  String get all => translate('all');
  String get confirmDelete => translate('confirmDelete');
  String get deleteOwnerMessage => translate('deleteOwnerMessage');
  String get deleteCattleMessage => translate('deleteCattleMessage');
  String get deleteExpenseMessage => translate('deleteExpenseMessage');
  String get yes => translate('yes');
  String get no => translate('no');
  String get language => translate('language');
  String get english => translate('english');
  String get bangla => translate('bangla');
  String get noData => translate('noData');
  String get noOwners => translate('noOwners');
  String get noCattle => translate('noCattle');
  String get noExpenses => translate('noExpenses');
  String get dashboard => translate('dashboard');
  String get statistics => translate('statistics');
  String get recentActivities => translate('recentActivities');
  String get validationRequired => translate('validationRequired');
  String get validationInvalidPhone => translate('validationInvalidPhone');
  String get validationInvalidAmount => translate('validationInvalidAmount');
  String get validationInvalidDate => translate('validationInvalidDate');
  String get validationFutureDate => translate('validationFutureDate');
  String get validationPositiveAmount => translate('validationPositiveAmount');
  String get errorOccurred => translate('errorOccurred');
  String get successSaved => translate('successSaved');
  String get successDeleted => translate('successDeleted');
  String get successUpdated => translate('successUpdated');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
