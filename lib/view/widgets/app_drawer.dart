import 'package:flutter/material.dart';
import '../about_view.dart';
import '../transactions_view.dart';
import '../radar_financeiro_view.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              if (currentRoute != 'Dashboard') {
                Navigator.of(context).pop(); // Returns to HomeView
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Transações'),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute == 'Transações') return;

              if (currentRoute == 'Dashboard') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TransactionsView()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const TransactionsView()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.candlestick_chart_outlined),
            title: const Text('Radar Financeiro'),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute == 'Radar Financeiro') return;

              if (currentRoute == 'Dashboard') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RadarFinanceiroView()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RadarFinanceiroView()),
                );
              }
            },
          ),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre'),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute == 'Sobre') return;

              if (currentRoute == 'Dashboard') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutView()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AboutView()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!context.mounted) return;
                if (currentRoute != 'Dashboard') {
                  Navigator.of(context).pop(); // go back to home first
                }
                Navigator.of(context).pop(); // go back to login
              });
            },
          ),
        ],
      ),
    );
  }
}
