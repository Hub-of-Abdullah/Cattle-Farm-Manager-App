import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.reports),
      ),
      body: Center(
        child: Text(
          localizations.noData,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
