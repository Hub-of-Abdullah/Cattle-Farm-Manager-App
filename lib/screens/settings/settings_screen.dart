import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/firm_deposit_provider.dart';
import '../../providers/owner_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sync_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final sync = context.watch<SyncProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          // ── Language ──────────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            subtitle: Text(
              settings.locale.languageCode == 'en'
                  ? l.english
                  : l.bangla,
            ),
            trailing: Switch(
              value: settings.locale.languageCode == 'bn',
              onChanged: (_) => settings.toggleLanguage(),
            ),
            onTap: () => settings.toggleLanguage(),
          ),
          const Divider(),

          // ── Google Sheets Sync ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Google Sheets Sync',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 0.8,
                  ),
            ),
          ),

          // Account tile
          ListTile(
            leading: CircleAvatar(
              backgroundColor: sync.isSignedIn
                  ? AppColors.primary
                  : AppColors.surfaceVariant,
              child: Icon(
                sync.isSignedIn ? Icons.person : Icons.person_outline,
                color: sync.isSignedIn
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
            title: Text(
              sync.isSignedIn
                  ? (sync.currentUserEmail ?? 'Google Account')
                  : 'Not signed in',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: sync.isSignedIn
                ? sync.lastSync != null
                    ? Text(
                        'Last sync: ${_formatTime(sync.lastSync!)}',
                        style: const TextStyle(
                            color: AppColors.success, fontSize: 12),
                      )
                    : const Text('Not synced yet')
                : const Text(
                    'Sign in to back up data to Google Sheets'),
            trailing: sync.isSignedIn
                ? TextButton(
                    onPressed: () => sync.signOut(),
                    child: const Text('Sign Out',
                        style: TextStyle(color: AppColors.error)),
                  )
                : ElevatedButton(
                    onPressed: () => sync.signIn(),
                    child: const Text('Sign In'),
                  ),
          ),

          // Sync now button (only when signed in)
          if (sync.isSignedIn)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: ElevatedButton.icon(
                onPressed: sync.isSyncing
                    ? null
                    : () => _syncNow(context, sync),
                icon: sync.isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                    sync.isSyncing ? 'Syncing…' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),

          // Spreadsheet link
          if (sync.isSignedIn && sync.spreadsheetUrl != null)
            ListTile(
              leading: const Icon(Icons.open_in_new,
                  color: AppColors.info),
              title: const Text('View Spreadsheet'),
              subtitle: Text(
                sync.spreadsheetUrl!,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Error banner
          if (sync.error != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sync.error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Setup instructions (when not signed in)
          if (!sync.isSignedIn)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.info_outline,
                          color: AppColors.info, size: 16),
                      SizedBox(width: 6),
                      Text('Setup required',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.info)),
                    ]),
                    SizedBox(height: 8),
                    Text(
                      '1. Go to console.cloud.google.com\n'
                      '2. Create a project & enable Google Sheets API\n'
                      '3. Create an Android OAuth 2.0 client ID\n'
                      '   • Package: com.example.cattle_farm_manager\n'
                      '   • Add your app\'s SHA-1 fingerprint\n'
                      '4. Download google-services.json → android/app/\n'
                      '5. Rebuild the app',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.6),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(),

          // ── About ─────────────────────────────────────────────────────────
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  void _syncNow(BuildContext context, SyncProvider sync) {
    sync.syncNow(
      ownerP: context.read<OwnerProvider>(),
      cattleP: context.read<CattleProvider>(),
      expenseP: context.read<ExpenseProvider>(),
      saleP: context.read<SaleProvider>(),
      depositP: context.read<FirmDepositProvider>(),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
