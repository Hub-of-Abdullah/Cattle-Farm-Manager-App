import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/expense.dart';
import '../../models/owner.dart';
import '../../providers/expense_provider.dart';
import '../../providers/owner_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final int? preselectedOwnerId;
  final Expense? expense;

  const AddExpenseScreen({
    super.key,
    this.preselectedOwnerId,
    this.expense,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _customCategoryController;
  DateTime _date = DateTime.now();
  ExpenseCategory _category = ExpenseCategory.food;
  Owner? _selectedOwner;
  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense != null
          ? widget.expense!.amount.toStringAsFixed(0)
          : '',
    );
    _noteController =
        TextEditingController(text: widget.expense?.note ?? '');
    _customCategoryController = TextEditingController(
        text: widget.expense?.customCategory ?? '');
    if (widget.expense != null) {
      _date = widget.expense!.date;
      _category = widget.expense!.category;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedOwner == null) {
      final owners = context.read<OwnerProvider>().owners;
      if (owners.isEmpty) return;
      final targetId =
          widget.expense?.ownerId ?? widget.preselectedOwnerId;
      if (targetId != null) {
        try {
          _selectedOwner = owners.firstWhere((o) => o.id == targetId);
        } catch (_) {
          _selectedOwner = owners.first;
        }
      } else {
        _selectedOwner = owners.first;
      }
    } else {
      final owners = context.read<OwnerProvider>().owners;
      try {
        _selectedOwner =
            owners.firstWhere((o) => o.id == _selectedOwner!.id);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOwner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an owner.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);

    final provider = context.read<ExpenseProvider>();
    final l = AppLocalizations.of(context);

    final expense = Expense(
      id: widget.expense?.id,
      ownerId: _selectedOwner!.id,
      date: _date,
      category: _category,
      customCategory: _category == ExpenseCategory.other
          ? _customCategoryController.text.trim().isEmpty
              ? null
              : _customCategoryController.text.trim()
          : null,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: widget.expense?.createdAt,
    );

    final success = _isEditing
        ? await provider.updateExpense(expense)
        : await provider.addExpense(expense);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? (_isEditing ? l.successUpdated : l.successSaved)
            : l.errorOccurred),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final owners = context.watch<OwnerProvider>().owners;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.expense : l.addExpense),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Owner dropdown
              DropdownButtonFormField<Owner>(
                value: _selectedOwner,
                decoration: InputDecoration(
                  labelText: l.owner,
                  prefixIcon: const Icon(Icons.person),
                ),
                items: owners.map((o) {
                  return DropdownMenuItem<Owner>(
                    value: o,
                    child: Text(o.name),
                  );
                }).toList(),
                onChanged: _isEditing
                    ? null
                    : (v) => setState(() => _selectedOwner = v),
                validator: (_) =>
                    _selectedOwner == null ? l.validationRequired : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<ExpenseCategory>(
                value: _category,
                decoration: InputDecoration(
                  labelText: l.category,
                  prefixIcon: Icon(_categoryIcon(_category)),
                ),
                items: ExpenseCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(_categoryIcon(cat),
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(_categoryLabel(cat, l)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),

              if (_category == ExpenseCategory.other) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    labelText: l.customCategoryLabel,
                    prefixIcon: const Icon(Icons.edit_note),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (_category == ExpenseCategory.other &&
                        (v == null || v.trim().isEmpty)) {
                      return l.validationRequired;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l.amount,
                  prefixIcon: const Icon(Icons.currency_exchange),
                  prefixText: '৳ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 16),

              // Date
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
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l.note,
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
