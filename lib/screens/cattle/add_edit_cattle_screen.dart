import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cattle.dart';
import '../../models/owner.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/owner_provider.dart';

class AddEditCattleScreen extends StatefulWidget {
  final Cattle? cattle;
  final int? preselectedOwnerId;

  const AddEditCattleScreen({super.key, this.cattle, this.preselectedOwnerId});

  @override
  State<AddEditCattleScreen> createState() => _AddEditCattleScreenState();
}

class _AddEditCattleScreenState extends State<AddEditCattleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _uniqueIdController;
  late final TextEditingController _purchasePriceController;
  DateTime _purchaseDate = DateTime.now();
  Owner? _selectedOwner;
  bool _isSaving = false;

  bool get _isEditing => widget.cattle != null;

  @override
  void initState() {
    super.initState();
    _uniqueIdController =
        TextEditingController(text: widget.cattle?.cattleUniqueId ?? '');
    _purchasePriceController = TextEditingController(
      text: widget.cattle != null
          ? widget.cattle!.purchasePrice.toStringAsFixed(0)
          : '',
    );
    if (widget.cattle != null) {
      _purchaseDate = widget.cattle!.purchaseDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final owners = context.read<OwnerProvider>().owners;
    if (owners.isEmpty) return;

    if (_selectedOwner == null) {
      final targetId = widget.cattle?.ownerId ?? widget.preselectedOwnerId;
      if (targetId != null) {
        _selectedOwner = owners.firstWhere(
          (o) => o.id == targetId,
          orElse: () => owners.first,
        );
      } else {
        _selectedOwner = owners.first;
      }
    } else {
      // Refresh reference when the owners list is reloaded with new objects.
      final refreshed = owners.firstWhere(
        (o) => o.id == _selectedOwner!.id,
        orElse: () => owners.first,
      );
      _selectedOwner = refreshed;
    }
  }

  @override
  void dispose() {
    _uniqueIdController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOwner == null) return;

    setState(() => _isSaving = true);

    final provider = context.read<CattleProvider>();
    final l = AppLocalizations.of(context);

    final uniqueId = _uniqueIdController.text.trim();
    final isTaken = await provider.isUniqueIdTaken(
      uniqueId,
      excludeId: widget.cattle?.id,
    );

    if (!mounted) return;

    if (isTaken) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cattle ID "$uniqueId" is already used.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cattle = Cattle(
      id: widget.cattle?.id,
      ownerId: _selectedOwner!.id!,
      cattleUniqueId: uniqueId,
      purchaseDate: _purchaseDate,
      purchasePrice:
          double.tryParse(_purchasePriceController.text.trim()) ?? 0,
      isSold: widget.cattle?.isSold ?? false,
      createdAt: widget.cattle?.createdAt,
    );

    bool success;
    if (_isEditing) {
      success = await provider.updateCattle(cattle);
    } else {
      success = await provider.addCattle(cattle);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEditing ? l.successUpdated : l.successSaved),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.errorOccurred),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final owners = context.watch<OwnerProvider>().owners;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editCattle : l.addCattle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<Owner>(
                value: _selectedOwner,
                decoration: InputDecoration(
                  labelText: l.owner,
                  prefixIcon: const Icon(Icons.person),
                ),
                items: owners
                    .map((o) => DropdownMenuItem(value: o, child: Text(o.name)))
                    .toList(),
                onChanged: _isEditing
                    ? null
                    : (v) => setState(() => _selectedOwner = v),
                validator: (v) =>
                    v == null ? l.validationRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _uniqueIdController,
                decoration: InputDecoration(
                  labelText: l.cattleId,
                  prefixIcon: const Icon(Icons.tag),
                ),
                textCapitalization: TextCapitalization.characters,
                enabled: !(_isEditing && widget.cattle!.isSold),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l.validationRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purchasePriceController,
                decoration: InputDecoration(
                  labelText: l.purchasePrice,
                  prefixIcon: const Icon(Icons.currency_exchange),
                  prefixText: '৳ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                enabled: !(_isEditing && widget.cattle!.isSold),
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
              InkWell(
                onTap: (_isEditing && widget.cattle!.isSold) ? null : _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l.purchaseDate,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_purchaseDate.year}-${_purchaseDate.month.toString().padLeft(2, '0')}-${_purchaseDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_isSaving || (_isEditing && widget.cattle!.isSold))
                    ? null
                    : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l.save),
              ),
              if (_isEditing && widget.cattle!.isSold) ...[
                const SizedBox(height: 12),
                Text(
                  'This cattle has been sold and cannot be edited.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
