import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/owner.dart';
import '../../providers/cattle_provider.dart';
import '../../providers/owner_provider.dart';
import 'add_edit_owner_screen.dart';
import 'owner_details_screen.dart';

class OwnerListScreen extends StatefulWidget {
  const OwnerListScreen({super.key});

  @override
  State<OwnerListScreen> createState() => _OwnerListScreenState();
}

class _OwnerListScreenState extends State<OwnerListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OwnerProvider>().loadOwners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.owners),
      ),
      body: Consumer<OwnerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.owners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    l.noOwners,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _openAddOwner(context),
                    icon: const Icon(Icons.person_add),
                    label: Text(l.addOwner),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                ],
              ),
            );
          }

          return Consumer<CattleProvider>(
            builder: (context, cattleProvider, _) {
              return ListView.builder(
                itemCount: provider.owners.length,
                itemBuilder: (context, index) {
                  final owner = provider.owners[index];
                  return _OwnerCard(
                    owner: owner,
                    cattleCount: cattleProvider
                        .getCattleByOwner(owner.id!)
                        .length,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddOwner(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddOwner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditOwnerScreen()),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final Owner owner;
  final int cattleCount;

  const _OwnerCard({required this.owner, required this.cattleCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            owner.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(owner.name),
        subtitle: Text(
          owner.phone ?? (owner.address ?? ''),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$cattleCount',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'cattle',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OwnerDetailsScreen(owner: owner),
            ),
          );
        },
      ),
    );
  }
}
