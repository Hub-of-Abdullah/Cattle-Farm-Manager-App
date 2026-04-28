import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/owner_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/firm_deposit_provider.dart';
import '../cattle/add_edit_cattle_screen.dart';
import '../firm_account/firm_account_screen.dart';
import '../owners/add_edit_owner_screen.dart';
import '../owners/owner_list_screen.dart';
import '../cattle/cattle_list_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _DashboardHome(),
      const OwnerListScreen(),
      const CattleListScreen(),
      const ReportsScreen(),
      const FirmAccountScreen(),
    ];
    _loadAllData();
  }

  void _loadAllData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerP = context.read<OwnerProvider>();
      final cattleP = context.read<CattleProvider>();
      final expenseP = context.read<ExpenseProvider>();
      final saleP = context.read<SaleProvider>();
      final depositP = context.read<FirmDepositProvider>();
      ownerP.loadOwners();
      cattleP.loadCattle();
      expenseP.loadExpenses();
      saleP.loadSales();
      depositP.loadDeposits();
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: localizations.owners,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pets),
            label: localizations.cattle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: localizations.reports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: localizations.firmAccount,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          Consumer<SyncProvider>(
            builder: (context, sync, _) {
              if (!sync.isSignedIn) {
                return IconButton(
                  icon: const Icon(Icons.cloud_off_outlined),
                  tooltip: 'Set up Google Sheets sync in Settings',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  ),
                );
              }
              if (sync.isSyncing) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                );
              }
              return IconButton(
                icon: Icon(
                  sync.error != null
                      ? Icons.cloud_off_outlined
                      : Icons.cloud_done_outlined,
                ),
                tooltip: sync.error ??
                    (sync.lastSync != null
                        ? 'Synced. Tap to sync again.'
                        : 'Tap to sync to Google Sheets'),
                onPressed: () => sync.syncNow(
                  ownerP: context.read<OwnerProvider>(),
                  cattleP: context.read<CattleProvider>(),
                  expenseP: context.read<ExpenseProvider>(),
                  saleP: context.read<SaleProvider>(),
                  depositP: context.read<FirmDepositProvider>(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer5<OwnerProvider, CattleProvider, ExpenseProvider,
          SaleProvider, FirmDepositProvider>(
        builder:
            (context, ownerP, cattleP, expenseP, saleP, depositP, _) {
          final totalExpenses = expenseP.totalExpenses;
          final totalRevenue = saleP.totalRevenue;

          // Firm account: deposits + revenue minus all purchases and expenses
          final totalAllPurchases = cattleP.cattle
              .fold(0.0, (sum, c) => sum + c.purchasePrice);
          final firmBalance = totalRevenue + depositP.totalDeposits -
              totalAllPurchases - totalExpenses;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Firm Account balance — always shown first
                _FirmBalanceBanner(
                  balance: firmBalance,
                  label: l.firmAccountAvailable,
                  firmAccountLabel: l.firmAccount,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FirmAccountScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l.statistics,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.pets,
                        label: l.totalCattle,
                        value: '${cattleP.cattle.length}',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people,
                        label: l.owners,
                        value: '${ownerP.owners.length}',
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: l.activeCattle,
                        value: '${cattleP.activeCattle.length}',
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.sell,
                        label: l.soldCattle,
                        value: '${cattleP.soldCattle.length}',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddEditOwnerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: Text(l.addOwner),
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final owners =
                              context.read<OwnerProvider>().owners;
                          if (owners.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please add an owner first.'),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddEditCattleScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l.addCattle),
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FirmBalanceBanner extends StatelessWidget {
  final double balance;
  final String label;
  final String firmAccountLabel;
  final VoidCallback onTap;

  const _FirmBalanceBanner({
    required this.balance,
    required this.label,
    required this.firmAccountLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPositive
                ? [const Color(0xFF0E3D22), const Color(0xFF1B5E38)]
                : [const Color(0xFF7B1A14), const Color(0xFFC0392B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        firmAccountLabel,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '৳ ${balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_right, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
