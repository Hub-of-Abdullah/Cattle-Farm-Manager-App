import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cattle.dart';
import '../../models/sale.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/sale_provider.dart';

class SellCattleScreen extends StatefulWidget {
  final Cattle cattle;

  const SellCattleScreen({super.key, required this.cattle});

  @override
  State<SellCattleScreen> createState() => _SellCattleScreenState();
}

class _SellCattleScreenState extends State<SellCattleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salePriceController = TextEditingController();
  final _buyerNameController = TextEditingController();
  DateTime _saleDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _salePriceController.dispose();
    _buyerNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: widget.cattle.purchaseDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _saleDate = picked);
  }

  Future<void> _sell() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final saleProvider = context.read<SaleProvider>();
    final cattleProvider = context.read<CattleProvider>();
    final l = AppLocalizations.of(context);

    final sale = Sale(
      cattleId: widget.cattle.id!,
      saleDate: _saleDate,
      salePrice: double.tryParse(_salePriceController.text.trim()) ?? 0,
      buyerName: _buyerNameController.text.trim().isEmpty
          ? null
          : _buyerNameController.text.trim(),
    );

    final saleOk = await saleProvider.recordSale(sale);
    if (!mounted) return;

    if (saleOk) {
      await cattleProvider.markAsSold(widget.cattle.id!);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (saleOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.successSaved),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l.sellCattle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.cattleId}: ${widget.cattle.cattleUniqueId}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l.purchasePrice}: ৳ ${widget.cattle.purchasePrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _salePriceController,
                decoration: InputDecoration(
                  labelText: l.salePrice,
                  prefixIcon: const Icon(Icons.sell),
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
              TextFormField(
                controller: _buyerNameController,
                decoration: InputDecoration(
                  labelText: l.buyerName,
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l.saleDate,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_saleDate.year}-${_saleDate.month.toString().padLeft(2, '0')}-${_saleDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _sell,
                icon: const Icon(Icons.sell),
                label: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l.sellCattle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
