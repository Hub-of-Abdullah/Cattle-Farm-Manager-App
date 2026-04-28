import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/expense.dart';
import '../../models/firm_deposit.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/firm_deposit_provider.dart';
import '../../providers/owner_provider.dart';
import '../../providers/sale_provider.dart';

class FirmAccountScreen extends StatefulWidget {
  const FirmAccountScreen({super.key});

  @override
  State<FirmAccountScreen> createState() => _FirmAccountScreenState();
}

class _FirmAccountScreenState extends State<FirmAccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FirmDepositProvider>().loadDeposits();
    });
  }

  void _showTransactionDialog(BuildContext context,
      {required bool isWithdrawal}) {
    final depositProvider = context.read<FirmDepositProvider>();
    showDialog(
      context: context,
      builder: (_) => _TransactionDialog(
        isWithdrawal: isWithdrawal,
        depositProvider: depositProvider,
      ),
    );
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

  void _confirmDelete(BuildContext context, FirmDeposit deposit) {
    final l = AppLocalizations.of(context);
    final depositProvider = context.read<FirmDepositProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDelete),
        content: Text(l.deleteDepositMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.no),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await depositProvider.deleteDeposit(deposit.id!);
            },
            child: Text(l.yes,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.firmAccount)),
      body: Consumer5<OwnerProvider, CattleProvider, ExpenseProvider, SaleProvider,
          FirmDepositProvider>(
        builder: (context, ownerP, cattleP, expenseP, saleP, depositP, _) {
          final totalRevenue = saleP.totalRevenue;
          final totalAllPurchases =
              cattleP.cattle.fold(0.0, (sum, c) => sum + c.purchasePrice);
          final totalExpenses = expenseP.totalExpenses;
          final totalDeposits = depositP.totalDeposits;
          final balance = totalRevenue + totalDeposits -
              totalAllPurchases - totalExpenses;

          final cattleMap = {
            for (final c in cattleP.cattle) if (c.id != null) c.id!: c
          };
          final ownerMap = {
            for (final o in ownerP.owners) if (o.id != null) o.id!: o
          };
          final List<_Tx> txList = [
            ...depositP.deposits.map((d) => _Tx(
                  date: d.date,
                  amount: d.amount,
                  title: d.amount < 0 ? l.subtractDeposit : l.addDeposit,
                  subtitle: d.note,
                  icon: d.amount < 0
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  onDelete: () => _confirmDelete(context, d),
                )),
            ...saleP.sales.map((s) {
              final uid = cattleMap[s.cattleId]?.cattleUniqueId ?? '#${s.cattleId}';
              return _Tx(
                date: s.saleDate,
                amount: s.salePrice,
                title: 'Sale: $uid',
                subtitle: s.buyerName != null ? 'Buyer: ${s.buyerName}' : null,
                icon: Icons.sell,
              );
            }),
            ...expenseP.expenses.map((e) {
              final label = _categoryLabel(e.category, l);
              final display = e.displayCategory(label);
              final ownerName = ownerMap[e.ownerId]?.name;
              return _Tx(
                date: e.date,
                amount: -e.amount,
                title: 'Expense: $display',
                subtitle: ownerName,
                icon: Icons.receipt_long,
              );
            }),
          ]..sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              // ── Balance card ──
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: balance >= 0
                        ? [
                            const Color(0xFF0E3D22),
                            const Color(0xFF1B5E38),
                          ]
                        : [
                            const Color(0xFF7B1A14),
                            const Color(0xFFC0392B),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (balance >= 0
                              ? AppColors.success
                              : AppColors.error)
                          .withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.firmAccountAvailable,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳ ${balance.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    _SummaryRow(
                        label: l.totalRevenue,
                        value:
                            '+ ৳ ${totalRevenue.toStringAsFixed(0)}',
                        positive: true),
                    _SummaryRow(
                        label: l.totalDeposits,
                        value:
                            '+ ৳ ${totalDeposits.toStringAsFixed(0)}',
                        positive: totalDeposits >= 0),
                    _SummaryRow(
                        label: l.firmAccountTotalInvested,
                        value:
                            '- ৳ ${totalAllPurchases.toStringAsFixed(0)}',
                        positive: false),
                    _SummaryRow(
                        label: l.totalExpenses,
                        value:
                            '- ৳ ${totalExpenses.toStringAsFixed(0)}',
                        positive: false),
                  ],
                ),
              ),

              // ── Transaction history header ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(l.transactionHistory,
                        style:
                            Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),

              // ── Transaction list ──
              Expanded(
                child: txList.isEmpty
                    ? Center(
                        child: Text(l.noDeposits,
                            style: Theme.of(context).textTheme.bodyLarge),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: txList.length,
                        itemBuilder: (_, i) => _TxCard(tx: txList[i]),
                      ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: AppLocalizations.of(context).subtractDeposit,
                  icon: Icons.remove_circle_outline,
                  color: AppColors.error,
                  onPressed: () => _showTransactionDialog(context,
                      isWithdrawal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: AppLocalizations.of(context).addDeposit,
                  icon: Icons.add_circle_outline,
                  color: AppColors.success,
                  onPressed: () => _showTransactionDialog(context,
                      isWithdrawal: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable bottom action button ───────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
    );
  }
}

// ── Summary row inside the balance card ────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool positive;

  const _SummaryRow(
      {required this.label,
      required this.value,
      required this.positive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value,
              style: TextStyle(
                color: positive
                    ? const Color(0xFF81C784)
                    : const Color(0xFFEF9A9A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}

// ── Unified transaction data class ──────────────────────────────────────────────

class _Tx {
  final DateTime date;
  final double amount;
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onDelete;

  const _Tx({
    required this.date,
    required this.amount,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onDelete,
  });
}

// ── Unified transaction card ─────────────────────────────────────────────────────

class _TxCard extends StatelessWidget {
  final _Tx tx;

  const _TxCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.amount >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final dateStr =
        '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(tx.icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tx.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            Text(
              '${isPositive ? '+' : '-'} ৳ ${tx.amount.abs().toStringAsFixed(0)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15),
            ),
          ],
        ),
        subtitle: Text(
          tx.subtitle != null ? '$dateStr · ${tx.subtitle}' : dateStr,
        ),
        trailing: tx.onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.textTertiary),
                onPressed: tx.onDelete,
              )
            : null,
      ),
    );
  }
}

// ── Add / Subtract dialog ────────────────────────────────────────────────────────

class _TransactionDialog extends StatefulWidget {
  final bool isWithdrawal;
  final FirmDepositProvider depositProvider;

  const _TransactionDialog({
    required this.isWithdrawal,
    required this.depositProvider,
  });

  @override
  State<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<_TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final rawAmount = double.parse(_amountController.text.trim());
    final amount = widget.isWithdrawal ? -rawAmount : rawAmount;

    final deposit = FirmDeposit(
      amount: amount,
      date: _date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    final success = await widget.depositProvider.addDeposit(deposit);

    if (!mounted) return;
    setState(() => _isSaving = false);

    // Close dialog first, then show snackbar on the parent scaffold
    Navigator.pop(context);
    if (mounted) return; // already gone
    // Use root scaffold messenger (survives dialog pop)
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(success
            ? AppLocalizations.of(context).successSaved
            : AppLocalizations.of(context).errorOccurred),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWithdrawal = widget.isWithdrawal;
    final color = isWithdrawal ? AppColors.error : AppColors.success;
    final title =
        isWithdrawal ? l.subtractDeposit : l.addDeposit;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isWithdrawal ? Icons.remove_circle : Icons.add_circle,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l.depositAmount,
                prefixIcon: Icon(Icons.currency_exchange, color: color),
                prefixText: '৳ ',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l.validationRequired;
                }
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) {
                  return l.validationPositiveAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l.date,
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l.note,
                prefixIcon: const Icon(Icons.notes),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: color),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(l.save),
        ),
      ],
    );
  }
}
