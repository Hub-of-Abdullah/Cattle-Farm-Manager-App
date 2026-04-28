import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/expense.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/firm_deposit_provider.dart';
import '../../providers/owner_provider.dart';
import '../../providers/sale_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  String _categoryLabel(ExpenseCategory cat, AppLocalizations l) {
    switch (cat) {
      case ExpenseCategory.food:
        return l.categoryFood;
      case ExpenseCategory.medicine:
        return l.categoryMedicine;
      case ExpenseCategory.doctor:
        return l.categoryDoctor;
      case ExpenseCategory.takeProfit:
        return l.categoryTakeProfit;
      case ExpenseCategory.other:
        return l.categoryOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.reports)),
      body: Consumer5<OwnerProvider, CattleProvider, ExpenseProvider,
          SaleProvider, FirmDepositProvider>(
        builder: (context, ownerProvider, cattleProvider, expenseProvider,
            saleProvider, depositProvider, _) {
          final allCattle = cattleProvider.cattle;
          final activeCattle = cattleProvider.activeCattle;
          final soldCattle = cattleProvider.soldCattle;

          final totalExpenses = expenseProvider.totalExpenses;
          final totalRevenue = saleProvider.totalRevenue;

          final totalAllPurchases =
              allCattle.fold(0.0, (sum, c) => sum + c.purchasePrice);
          final totalDeposits = depositProvider.totalDeposits;
          final firmBalance = totalRevenue + totalDeposits -
              totalAllPurchases - totalExpenses;

          // Profit/loss on sold cattle (purchase cost vs sale price only)
          final totalPurchaseCostSold =
              soldCattle.fold(0.0, (sum, c) => sum + c.purchasePrice);
          final profitLoss = totalRevenue - totalPurchaseCostSold;

          final categoryTotals = <ExpenseCategory, double>{};
          for (final cat in ExpenseCategory.values) {
            categoryTotals[cat] = expenseProvider.expenses
                .where((e) => e.category == cat)
                .fold(0.0, (sum, e) => sum + e.amount);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Overview ──
              Text('Overview',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pets,
                      label: l.totalCattle,
                      value: '${allCattle.length}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      label: l.activeCattle,
                      value: '${activeCattle.length}',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.sell,
                      label: l.soldCattle,
                      value: '${soldCattle.length}',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Financial Summary ──
              Text('Financial Summary',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _FinRow(
                        label: l.totalExpenses,
                        value:
                            '৳ ${totalExpenses.toStringAsFixed(0)}',
                        color: AppColors.error,
                      ),
                      const Divider(),
                      _FinRow(
                        label: l.totalRevenue,
                        value:
                            '৳ ${totalRevenue.toStringAsFixed(0)}',
                        color: AppColors.success,
                      ),
                      const Divider(),
                      _FinRow(
                        label: l.profitLoss,
                        value: '৳ ${profitLoss.toStringAsFixed(0)}',
                        color: profitLoss >= 0
                            ? AppColors.profit
                            : AppColors.loss,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Firm Account ──
              Text(l.firmAccount,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                color: firmBalance >= 0
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.error.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: firmBalance >= 0
                        ? AppColors.success
                        : AppColors.error,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _FinRow(
                        label: l.totalRevenue,
                        value:
                            '+ ৳ ${totalRevenue.toStringAsFixed(0)}',
                        color: AppColors.success,
                      ),
                      if (totalDeposits > 0) ...[
                        const Divider(),
                        _FinRow(
                          label: l.totalDeposits,
                          value:
                              '+ ৳ ${totalDeposits.toStringAsFixed(0)}',
                          color: AppColors.success,
                        ),
                      ],
                      const Divider(),
                      _FinRow(
                        label: l.firmAccountTotalInvested,
                        value:
                            '- ৳ ${totalAllPurchases.toStringAsFixed(0)}',
                        color: AppColors.error,
                      ),
                      const Divider(),
                      _FinRow(
                        label: l.totalExpenses,
                        value:
                            '- ৳ ${totalExpenses.toStringAsFixed(0)}',
                        color: AppColors.error,
                      ),
                      const Divider(thickness: 1.5),
                      _FinRow(
                        label: l.firmAccountAvailable,
                        value: '৳ ${firmBalance.toStringAsFixed(0)}',
                        color: firmBalance >= 0
                            ? AppColors.profit
                            : AppColors.loss,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Expenses by Category ──
              Text('Expenses by Category',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: ExpenseCategory.values.map((cat) {
                      final total = categoryTotals[cat] ?? 0;
                      return Column(
                        children: [
                          _FinRow(
                            label: _categoryLabel(cat, l),
                            value: '৳ ${total.toStringAsFixed(0)}',
                            color: AppColors.textPrimary,
                          ),
                          if (cat != ExpenseCategory.values.last)
                            const Divider(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Per-Owner Report ──
              if (ownerProvider.owners.isNotEmpty) ...[
                Text('Per-Owner Report',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                ...ownerProvider.owners.map((owner) {
                  final ownerCattle =
                      cattleProvider.getCattleByOwner(owner.id!);
                  final ownerSoldCattle =
                      ownerCattle.where((c) => c.isSold).toList();
                  final ownerRevenue = ownerSoldCattle.fold(
                    0.0,
                    (sum, c) =>
                        sum +
                        (saleProvider.getSaleForCattle(c.id!)?.salePrice ??
                            0),
                  );
                  final ownerPurchases = ownerCattle.fold(
                      0.0, (sum, c) => sum + c.purchasePrice);
                  final ownerExpenses =
                      expenseProvider.totalForOwner(owner.id!);
                  final ownerBalance =
                      ownerRevenue - ownerPurchases - ownerExpenses;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  owner.name[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  owner.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                              ),
                              Text(
                                '৳ ${ownerBalance.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: ownerBalance >= 0
                                      ? AppColors.profit
                                      : AppColors.loss,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          _FinRow(
                            label: '${l.cattle} (${ownerCattle.length})',
                            value:
                                '- ৳ ${ownerPurchases.toStringAsFixed(0)}',
                            color: AppColors.error,
                          ),
                          _FinRow(
                            label: l.totalExpenses,
                            value:
                                '- ৳ ${ownerExpenses.toStringAsFixed(0)}',
                            color: AppColors.error,
                          ),
                          _FinRow(
                            label: l.totalRevenue,
                            value:
                                '+ ৳ ${ownerRevenue.toStringAsFixed(0)}',
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              // ── Per-Cattle Profit ──
              if (soldCattle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Per-Cattle Profit',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                ...soldCattle.map((c) {
                  final sale = saleProvider.getSaleForCattle(c.id!);
                  final pl = sale != null
                      ? sale.salePrice - c.purchasePrice
                      : null;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.pets,
                          color: AppColors.warning),
                      title: Text(c.cattleUniqueId),
                      subtitle: Text(
                          '${l.purchasePrice}: ৳ ${c.purchasePrice.toStringAsFixed(0)}'),
                      trailing: pl != null
                          ? Text(
                              '৳ ${pl.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: pl >= 0
                                    ? AppColors.profit
                                    : AppColors.loss,
                              ),
                            )
                          : null,
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),
            ],
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FinRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _FinRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: bold ? FontWeight.bold : null,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: bold ? FontWeight.bold : null,
                ),
          ),
        ],
      ),
    );
  }
}
