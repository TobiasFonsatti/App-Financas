import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'adicionar_transacao.dart';
import 'metas.dart';
import 'resumo_mensal.dart';
import 'transacoes.dart';
import 'widgets/app_drawer.dart';

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
  List<Map<String, dynamic>> recentTransactions = [
    {
      'description': 'Salário',
      'amount': 3000.00,
      'date': '2023-10-01',
      'type': 'income',
    },
    {
      'description': 'Aluguel',
      'amount': -800.00,
      'date': '2023-10-02',
      'type': 'expense',
    },
    {
      'description': 'Compras',
      'amount': -150.00,
      'date': '2023-10-03',
      'type': 'expense',
    },
    {
      'description': 'Freelance',
      'amount': 500.00,
      'date': '2023-10-04',
      'type': 'income',
    },
    {
      'description': 'Conta de Luz',
      'amount': -120.00,
      'date': '2023-10-05',
      'type': 'expense',
    },
    {
      'description': 'Internet',
      'amount': -99.90,
      'date': '2023-10-06',
      'type': 'expense',
    },
  ];

  double get totalIncome {
    return recentTransactions
        .where((t) => t['type'] == 'income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  double get totalExpense {
    return recentTransactions
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (sum, t) => sum + ((t['amount'] as double).abs()));
  }

  double get totalBalance {
    return totalIncome - totalExpense;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'Dashboard'),
      appBar: AppBar(
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
      body: Container(
        decoration: widget.isDarkMode
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF133E28), Color(0xFF0E2F1F)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              )
            : null,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Balance
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: widget.isDarkMode
                        ? LinearGradient(
                            colors: [
                              Colors.green.shade900,
                              Colors.green.shade800,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.green.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(
                          alpha: widget.isDarkMode ? 0.05 : 0.25,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Saldo Total',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${totalBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MonthlySummaryView(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.pie_chart_outline),
                        label: const Text('Resumo Mensal'),
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.isDarkMode
                              ? Colors.green.shade800
                              : Colors.green.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MetasView(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.track_changes_outlined),
                        label: const Text('Metas'),
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.isDarkMode
                              ? Colors.green.shade800
                              : Colors.green.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Income and Expenses Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: widget.isDarkMode ? 0 : 2,
                        color: widget.isDarkMode
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 12.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_circle_up,
                                    color: Color(0xFF4ADE80),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Receitas',
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? const Color(0xFF86EFAC)
                                          : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'R\$ ${totalIncome.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDarkMode
                                      ? const Color(0xFF4ADE80)
                                      : Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        elevation: widget.isDarkMode ? 0 : 2,
                        color: widget.isDarkMode
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 12.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_circle_down,
                                    color: Colors.red.shade400,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Despesas',
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? const Color(0xFF86EFAC)
                                          : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'R\$ ${totalExpense.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Chart
                Text(
                  'Visão Geral',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode
                        ? const Color(0xFF86EFAC)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: widget.isDarkMode ? 0 : 2,
                  color: widget.isDarkMode
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 160,
                      child: Builder(
                        builder: (context) {
                          final double totalSum = totalIncome + totalExpense;
                          final String incomePercentage = totalSum == 0
                              ? '0%'
                              : '${((totalIncome / totalSum) * 100).toStringAsFixed(0)}%';
                          final String expensePercentage = totalSum == 0
                              ? '0%'
                              : '${((totalExpense / totalSum) * 100).toStringAsFixed(0)}%';

                          return PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: [
                                if (totalIncome > 0)
                                  PieChartSectionData(
                                    value: totalIncome,
                                    title: incomePercentage,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    color: Colors.green.shade500,
                                    radius: 45,
                                  ),
                                if (totalExpense > 0)
                                  PieChartSectionData(
                                    value: totalExpense,
                                    title: expensePercentage,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    color: Colors.red.shade400,
                                    radius: 45,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Últimas Transações',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode
                            ? const Color(0xFF86EFAC)
                            : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TransactionsView(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        alignment: Alignment.centerRight,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver todas',
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.isDarkMode
                                  ? const Color(0xFF86EFAC)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: widget.isDarkMode
                                ? const Color(0xFF86EFAC)
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length > 5
                      ? 5
                      : recentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = recentTransactions[index];
                    return ListTile(
                      title: Text(
                        transaction['description'],
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? const Color(0xFF86EFAC)
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        transaction['date'],
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? const Color(0xFF86EFAC).withValues(alpha: 0.6)
                              : null,
                        ),
                      ),
                      trailing: Text(
                        'R\$ ${transaction['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: transaction['type'] == 'income'
                              ? const Color(0xFF4ADE80)
                              : Colors.red.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddTransactionView()));
        },
        backgroundColor: widget.isDarkMode ? const Color(0xFF86EFAC) : null,
        foregroundColor: widget.isDarkMode ? const Color(0xFF133E28) : null,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
