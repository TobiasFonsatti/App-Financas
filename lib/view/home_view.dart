import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  double totalBalance = 5000.00;
  List<Map<String, dynamic>> recentTransactions = [
    {'description': 'Salário', 'amount': 3000.00, 'date': '2023-10-01', 'type': 'income'},
    {'description': 'Aluguel', 'amount': -800.00, 'date': '2023-10-02', 'type': 'expense'},
    {'description': 'Compras', 'amount': -150.00, 'date': '2023-10-03', 'type': 'expense'},
    {'description': 'Freelance', 'amount': 500.00, 'date': '2023-10-04', 'type': 'income'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: widget.isDarkMode ? 'Modo claro' : 'Modo escuro',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Saldo Total',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Chart
            const Text(
              'Receitas vs Despesas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 3500, // Income
                      title: 'Receitas',
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: 950, // Expenses
                      title: 'Despesas',
                      color: Colors.red,
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Recent Transactions
            const Text(
              'Últimas Transações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  return ListTile(
                    title: Text(transaction['description']),
                    subtitle: Text(transaction['date']),
                    trailing: Text(
                      'R\$ ${transaction['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction['type'] == 'income' ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add transaction screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adicionar Receita/Despesa')),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
