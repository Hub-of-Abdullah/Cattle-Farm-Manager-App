import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cattle.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/owner_provider.dart';
import 'add_edit_cattle_screen.dart';
import 'cattle_details_screen.dart';

class CattleListScreen extends StatefulWidget {
  const CattleListScreen({super.key});

  @override
  State<CattleListScreen> createState() => _CattleListScreenState();
}

class _CattleListScreenState extends State<CattleListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CattleProvider>().loadCattle();
      final op = context.read<OwnerProvider>();
      if (op.owners.isEmpty && !op.isLoading) op.loadOwners();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.cattle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: l.all),
            Tab(text: l.active),
            Tab(text: l.sold),
          ],
        ),
      ),
      body: Consumer<CattleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _CattleList(cattle: provider.cattle),
              _CattleList(cattle: provider.activeCattle),
              _CattleList(cattle: provider.soldCattle),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final op = context.read<OwnerProvider>();
          if (op.owners.isEmpty && !op.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please add an owner first.'),
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditCattleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CattleList extends StatelessWidget {
  final List<Cattle> cattle;

  const _CattleList({required this.cattle});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (cattle.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(l.noCattle,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return Consumer<OwnerProvider>(
      builder: (context, ownerProvider, _) {
        return ListView.builder(
          itemCount: cattle.length,
          itemBuilder: (context, index) {
            final c = cattle[index];
            final owner = ownerProvider.getOwnerById(c.ownerId);
            return _CattleCard(
              cattle: c,
              ownerName: owner?.name,
            );
          },
        );
      },
    );
  }
}

class _CattleCard extends StatelessWidget {
  final Cattle cattle;
  final String? ownerName;

  const _CattleCard({
    required this.cattle,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              cattle.isSold ? AppColors.warning : AppColors.success,
          child: const Icon(Icons.pets, color: Colors.white, size: 20),
        ),
        title: Text(cattle.cattleUniqueId,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ownerName != null) Text(ownerName!),
            Text('${l.purchasePrice}: ৳ ${cattle.purchasePrice.toStringAsFixed(0)}'),
          ],
        ),
        isThreeLine: ownerName != null,
        trailing: Chip(
          label: Text(
            cattle.isSold ? l.sold : l.active,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          backgroundColor:
              cattle.isSold ? AppColors.warning : AppColors.success,
          padding: EdgeInsets.zero,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CattleDetailsScreen(cattle: cattle),
            ),
          );
        },
      ),
    );
  }
}
