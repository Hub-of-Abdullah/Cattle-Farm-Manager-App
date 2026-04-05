import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class CattleListScreen extends StatelessWidget {
  const CattleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.cattle),
      ),
      body: Center(
        child: Text(
          localizations.noCattle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add cattle screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
