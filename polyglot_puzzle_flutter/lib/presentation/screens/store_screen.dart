import 'package:flutter/material.dart';

import '../../monetization/purchase_manager.dart';
import '../../l10n/app_localizations.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = PurchaseManager.instance;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.store)),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: pm.entitlements,
        builder: (context, ent, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTile(context, loc.removeAds, pm.price('remove_ads'), ent.contains('remove_ads'), pm.buyRemoveAds),
              _buildTile(context, loc.premiumPack, pm.price('premium_pack'), ent.contains('premium_pack'), pm.buyPremiumPack),
              _buildTile(context, '10 ' + loc.hintBundle, pm.price('hints_10'), ent.contains('hints_10'), pm.buyHintBundle),
              _buildTile(context, loc.monthlySub, pm.price('monthly_sub'), ent.contains('monthly_sub'), pm.buyMonthlySub),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, String? price, bool owned, Future<void> Function() onBuy) {
    final loc = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: owned ? Text(loc.purchased) : Text(price ?? ''),
        trailing: owned
            ? const Icon(Icons.check, color: Colors.green)
            : ElevatedButton(
                onPressed: () async {
                  await onBuy();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing purchase...')));
                },
                child: Text(loc.buy),
              ),
      ),
    );
  }
}