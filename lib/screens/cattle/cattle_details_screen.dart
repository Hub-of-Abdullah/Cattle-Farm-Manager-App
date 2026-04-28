import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cattle.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/owner_provider.dart';
import '../../providers/sale_provider.dart';
import '../sales/sell_cattle_screen.dart';
import 'add_edit_cattle_screen.dart';

class CattleDetailsScreen extends StatelessWidget {
  final Cattle cattle;

  const CattleDetailsScreen({super.key, required this.cattle});

  Future<void> _confirmDelete(
      BuildContext context, AppLocalizations l) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDelete),
        content: Text(l.deleteCattleMessage),
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
        await context.read<CattleProvider>().deleteCattle(cattle.id!);
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Consumer2<CattleProvider, SaleProvider>(
      builder: (context, cattleProvider, saleProvider, _) {
        final current =
            cattleProvider.getCattleById(cattle.id!) ?? cattle;
        final sale = saleProvider.getSaleForCattle(current.id!);
        final profitLoss =
            sale != null ? sale.salePrice - current.purchasePrice : null;
        final owner =
            context.read<OwnerProvider>().getOwnerById(current.ownerId);

        return Scaffold(
          appBar: AppBar(
            title: Text(l.cattleDetails),
            actions: [
              if (!current.isSold)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditCattleScreen(cattle: current),
                      ),
                    );
                  },
                ),
              if (!current.isSold)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context, l),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Info card ──
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
                            radius: 28,
                            backgroundColor: current.isSold
                                ? AppColors.warning
                                : AppColors.success,
                            child: const Icon(Icons.pets,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current.cattleUniqueId,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                Chip(
                                  label: Text(
                                    current.isSold ? l.sold : l.active,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: current.isSold
                                      ? AppColors.warning
                                      : AppColors.success,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                          label: l.owner, value: owner?.name ?? '-'),
                      _InfoRow(
                        label: l.purchaseDate,
                        value:
                            '${current.purchaseDate.year}-${current.purchaseDate.month.toString().padLeft(2, '0')}-${current.purchaseDate.day.toString().padLeft(2, '0')}',
                      ),
                      _InfoRow(
                        label: l.purchasePrice,
                        value:
                            '৳ ${current.purchasePrice.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Financial summary ──
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Financial Summary',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: l.purchasePrice,
                        value:
                            '৳ ${current.purchasePrice.toStringAsFixed(0)}',
                      ),
                      if (sale != null) ...[
                        const Divider(),
                        _InfoRow(
                          label: l.salePrice,
                          value:
                              '৳ ${sale.salePrice.toStringAsFixed(0)}',
                          valueColor: AppColors.success,
                        ),
                        _InfoRow(
                          label: l.profitLoss,
                          value:
                              '৳ ${profitLoss!.toStringAsFixed(0)}',
                          valueColor: profitLoss >= 0
                              ? AppColors.profit
                              : AppColors.loss,
                          bold: true,
                        ),
                        if (sale.buyerName != null)
                          _InfoRow(
                              label: l.buyerName,
                              value: sale.buyerName!),
                        _InfoRow(
                          label: l.saleDate,
                          value:
                              '${sale.saleDate.year}-${sale.saleDate.month.toString().padLeft(2, '0')}-${sale.saleDate.day.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (!current.isSold) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SellCattleScreen(cattle: current),
                      ),
                    );
                  },
                  icon: const Icon(Icons.sell),
                  label: Text(l.sellCattle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: bold ? FontWeight.bold : null,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: bold ? FontWeight.bold : null,
                ),
          ),
        ],
      ),
    );
  }
}
