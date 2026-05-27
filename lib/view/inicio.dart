import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transacao.dart';
import 'adicionar_transacao.dart';
import 'metas.dart';
import 'resumo_mensal.dart';
import 'transacoes.dart';
import 'pesquisa.dart';
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

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'Dashboard'),
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pesquisar transações',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchView()),
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Modo claro' : 'Modo escuro',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF133E28), Color(0xFF0E2F1F)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              )
            : null,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transacoes')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            final transactions = docs.map((doc) {
              return Transacao.fromJson(
                doc.data() as Map<String, dynamic>,
                docId: doc.id,
              );
            }).toList();

            // Client-side sorting by date desc, then createdAt desc
            transactions.sort((a, b) {
              final dateComp = b.date.compareTo(a.date);
              if (dateComp != 0) return dateComp;
              return b.createdAt.compareTo(a.createdAt);
            });

            double income = 0.0;
            double expense = 0.0;
            for (var t in transactions) {
              if (t.type == 'income') {
                income += t.amount;
              } else {
                expense += t.amount.abs();
              }
            }
            double balance = income - expense;

            return SingleChildScrollView(
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
                        gradient: isDark
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
                              alpha: isDark ? 0.05 : 0.25,
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
                            'R\$ ${balance.toStringAsFixed(2)}',
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
                              backgroundColor: isDark
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
                              backgroundColor: isDark
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
                            elevation: isDark ? 0 : 2,
                            color: isDark
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
                                          color: isDark
                                              ? const Color(0xFF86EFAC)
                                              : Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'R\$ ${income.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
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
                                          color: isDark
                                              ? const Color(0xFF86EFAC)
                                              : Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'R\$ ${expense.toStringAsFixed(2)}',
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
                        color: isDark
                            ? const Color(0xFF86EFAC)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: isDark ? 0 : 2,
                      color: isDark
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
                              final double totalSum = income + expense;
                              final String incomePercentage = totalSum == 0
                                  ? '0%'
                                  : '${((income / totalSum) * 100).toStringAsFixed(0)}%';
                              final String expensePercentage = totalSum == 0
                                  ? '0%'
                                  : '${((expense / totalSum) * 100).toStringAsFixed(0)}%';

                              return PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 40,
                                  sections: [
                                    if (income > 0)
                                      PieChartSectionData(
                                        value: income,
                                        title: incomePercentage,
                                        titleStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        color: Colors.green.shade500,
                                        radius: 45,
                                      ),
                                    if (expense > 0)
                                      PieChartSectionData(
                                        value: expense,
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
                            color: isDark
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
                                  color: isDark
                                      ? const Color(0xFF86EFAC)
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: isDark
                                    ? const Color(0xFF86EFAC)
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    transactions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                'Nenhuma transação recente',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF86EFAC).withValues(alpha: 0.6)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length > 5
                                ? 5
                                : transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              final isIncome = transaction.type == 'income';
                              return ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        transaction.description,
                                        style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFF86EFAC)
                                              : null,
                                        ),
                                      ),
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('observacoes')
                                          .where('relatedId', isEqualTo: transaction.id)
                                          .snapshots(),
                                      builder: (context, noteSnapshot) {
                                        if (noteSnapshot.hasData &&
                                            noteSnapshot.data!.docs.isNotEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 6.0),
                                            child: Icon(
                                              Icons.sticky_note_2_outlined,
                                              size: 15,
                                              color: isDark
                                                  ? const Color(0xFF4ADE80)
                                                  : Colors.green.shade600,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  transaction.date,
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF86EFAC).withValues(alpha: 0.6)
                                        : null,
                                  ),
                                ),
                                trailing: Text(
                                  'R\$ ${transaction.amount.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isIncome
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddTransactionView()));
        },
        backgroundColor: isDark ? const Color(0xFF86EFAC) : null,
        foregroundColor: isDark ? const Color(0xFF133E28) : null,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
