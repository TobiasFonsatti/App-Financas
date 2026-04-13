import 'package:flutter/material.dart';
import '../sobre.dart';
import '../metas.dart';
import '../resumo_mensal.dart';
import '../transacoes.dart';
import '../radar_financeiro.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF133E28) : null,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF133E28) : Colors.green.shade600,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menu',
                style: TextStyle(
                  color: isDark ? const Color(0xFF86EFAC) : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard,
              color: isDark ? const Color(0xFF86EFAC) : null,
            ),
            title: Text(
              'Dashboard',
              style: TextStyle(color: isDark ? const Color(0xFF86EFAC) : null),
            ),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              if (currentRoute != 'Dashboard') {
                Navigator.of(context).pop(); // Returns to HomeView
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.list_alt,
              color: isDark ? const Color(0xFF86EFAC) : null,
            ),
            title: Text(
              'Transações',
              style: TextStyle(color: isDark ? const Color(0xFF86EFAC) : null),
            ),
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
            leading: Icon(
              Icons.pie_chart_outline,
              color: isDark ? const Color(0xFF86EFAC) : null,
            ),
            title: Text(
              'Resumo Mensal',
              style: TextStyle(color: isDark ? const Color(0xFF86EFAC) : null),
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute == 'Resumo Mensal') return;

              if (currentRoute == 'Dashboard') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MonthlySummaryView()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MonthlySummaryView()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.candlestick_chart_outlined,
              color: isDark ? const Color(0xFF86EFAC) : null,
            ),
            title: Text(
              'Radar Financeiro',
              style: TextStyle(color: isDark ? const Color(0xFF86EFAC) : null),
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute == 'Radar Financeiro') return;

              if (currentRoute == 'Dashboard') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RadarFinanceiroView(),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const RadarFinanceiroView(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.track_changes_outlined,
              color: isDark ? const Color(0xFF86EFAC) : null,
            ),
            title: Text(
              'Metas',
              style: TextStyle(color: isDark ? const Color(0xFF86EFAC) : null),
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute == 'Metas') return;

              if (currentRoute == 'Dashboard') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MetasView()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MetasView()),
                );
              }
            },
          ),
          Divider(
            color: isDark
                ? const Color(0xFF86EFAC).withValues(alpha: 0.25)
                : null,
          ),
          const Spacer(),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: isDark ? const Color(0xFF86EFAC) : null,
            ),
            title: Text(
              'Sobre',
              style: TextStyle(color: isDark ? const Color(0xFF86EFAC) : null),
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute == 'Sobre') return;

              if (currentRoute == 'Dashboard') {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AboutView()));
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AboutView()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: isDark ? const Color(0xFF86EFAC) : null,
            ),
            title: Text(
              'Logout',
              style: TextStyle(color: isDark ? const Color(0xFF86EFAC) : null),
            ),
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
