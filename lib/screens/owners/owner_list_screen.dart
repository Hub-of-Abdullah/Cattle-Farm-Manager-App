import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class OwnerListScreen extends StatelessWidget {
  const OwnerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.owners),
      ),
      body: Center(
        child: Text(
          localizations.noOwners,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add owner screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
