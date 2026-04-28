import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/expense.dart';
import '../../models/owner.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/owner_provider.dart';
import '../cattle/cattle_details_screen.dart';
import '../cattle/add_edit_cattle_screen.dart';
import '../expenses/add_expense_screen.dart';
import 'add_edit_owner_screen.dart';

class OwnerDetailsScreen extends StatelessWidget {
  final Owner owner;

  const OwnerDetailsScreen({super.key, required this.owner});

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDelete),
        content: Text(l.deleteOwnerMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l.yes),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success =
        await context.read<OwnerProvider>().deleteOwner(owner.id!);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.successDeleted),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.errorOccurred),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteExpense(
      BuildContext context, AppLocalizations l, int expenseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDelete),
        content: Text(l.deleteExpenseMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l.yes),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    context.read<ExpenseProvider>().deleteExpense(expenseId);
  }

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

  Color _categoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return AppColors.success;
      case ExpenseCategory.medicine:
        return AppColors.info;
      case ExpenseCategory.doctor:
        return const Color(0xFF7B2D8B);
      case ExpenseCategory.takeProfit:
        return const Color(0xFFC8963E);
      case ExpenseCategory.other:
        return AppColors.textSecondary;
    }
  }

  IconData _categoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return Icons.grass;
      case ExpenseCategory.medicine:
        return Icons.medication;
      case ExpenseCategory.doctor:
        return Icons.medical_services;
      case ExpenseCategory.takeProfit:
        return Icons.trending_up;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddExpenseScreen(preselectedOwnerId: owner.id),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text(
              l.addExpense,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(l.ownerDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditOwnerScreen(owner: owner),
                ),
              );
              if (updated == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, l),
          ),
        ],
      ),
      body: Consumer2<CattleProvider, ExpenseProvider>(
        builder: (context, cattleProvider, expenseProvider, _) {
          final ownerCattle = cattleProvider.getCattleByOwner(owner.id!);
          final active = ownerCattle.where((c) => !c.isSold).length;
          final sold = ownerCattle.where((c) => c.isSold).length;
          final expenses = expenseProvider.getExpensesForOwner(owner.id!);
          final totalExpenses =
              expenses.fold(0.0, (sum, e) => sum + e.amount);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Owner info card ──
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              owner.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(owner.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium),
                                if (owner.phone != null)
                                  Text(owner.phone!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (owner.address != null) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(owner.address!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Stats row ──
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      label: l.totalCattle,
                      value: '${ownerCattle.length}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      label: l.activeCattle,
                      value: '$active',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatChip(
                      label: l.soldCattle,
                      value: '$sold',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Cattle section ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.cattle,
                      style: Theme.of(context).textTheme.headlineMedium),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditCattleScreen(
                              preselectedOwnerId: owner.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l.addCattle),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (ownerCattle.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l.noCattle,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                )
              else
                ...ownerCattle.map(
                  (cattle) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cattle.isSold
                            ? AppColors.warning
                            : AppColors.success,
                        child: const Icon(Icons.pets,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(cattle.cattleUniqueId),
                      subtitle: Text(
                          '৳ ${cattle.purchasePrice.toStringAsFixed(0)}'),
                      trailing: Chip(
                        label: Text(
                          cattle.isSold ? l.sold : l.active,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: cattle.isSold
                            ? AppColors.warning
                            : AppColors.success,
                        padding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CattleDetailsScreen(cattle: cattle),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ── Expenses section ──
              Text(l.expenses,
                  style: Theme.of(context).textTheme.headlineMedium),

              if (expenses.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.totalExpenses,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                      Text(
                        '৳ ${totalExpenses.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 4),

              if (expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l.noExpenses,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                )
              else
                ...expenses.map(
                  (exp) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _categoryColor(exp.category),
                        child: Icon(_categoryIcon(exp.category),
                            color: Colors.white, size: 18),
                      ),
                      title: Text(exp.displayCategory(_categoryLabel(exp.category, l))),
                      subtitle: Text(
                        '${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}-${exp.date.day.toString().padLeft(2, '0')}'
                        '${exp.note != null ? ' · ${exp.note}' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '৳ ${exp.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20),
                            onPressed: () => _confirmDeleteExpense(
                                context, l, exp.id!),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddExpenseScreen(expense: exp),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
