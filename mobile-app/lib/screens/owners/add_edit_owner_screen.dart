import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/owner.dart';
import '../../providers/owner_provider.dart';

class AddEditOwnerScreen extends StatefulWidget {
  final Owner? owner;

  const AddEditOwnerScreen({super.key, this.owner});

  @override
  State<AddEditOwnerScreen> createState() => _AddEditOwnerScreenState();
}

class _AddEditOwnerScreenState extends State<AddEditOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isSaving = false;

  bool get _isEditing => widget.owner != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.owner?.name ?? '');
    _phoneController = TextEditingController(text: widget.owner?.phone ?? '');
    _addressController =
        TextEditingController(text: widget.owner?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<OwnerProvider>();
    final l = AppLocalizations.of(context);

    final owner = Owner(
      id: widget.owner?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      createdAt: widget.owner?.createdAt,
    );

    bool success;
    if (_isEditing) {
      success = await provider.updateOwner(owner);
    } else {
      success = await provider.addOwner(owner);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditing ? l.successUpdated : l.successSaved),
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
        title: Text(_isEditing ? l.editOwner : l.addOwner),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l.ownerName,
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l.validationRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 7 || digits.length > 15) {
                      return l.validationInvalidPhone;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l.address,
                  prefixIcon: const Icon(Icons.location_on),
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
