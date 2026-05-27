import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transacao.dart';
import 'widgets/app_drawer.dart';

class MonthlySummaryView extends StatefulWidget {
  const MonthlySummaryView({super.key});

  @override
  State<MonthlySummaryView> createState() => _MonthlySummaryViewState();
}

class _MonthlySummaryViewState extends State<MonthlySummaryView> {
  int _selectedMonthIndex = 0;
  bool _showDetails = false;

  String _getMonthName(int monthNumber) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    if (monthNumber < 1 || monthNumber > 12) return '';
    return months[monthNumber - 1];
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _changeMonth(int delta, int maxLen) {
    final newIndex = _selectedMonthIndex + delta;
    if (newIndex < 0 || newIndex >= maxLen) return;
    setState(() {
      _selectedMonthIndex = newIndex;
      _showDetails = false;
    });
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double amount,
    required double ratio,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              _formatCurrency(amount),
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopList(
    String title,
    List<Map<String, dynamic>> items,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(List<Map<String, dynamic>>.from(items)
                  ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double)))
                .map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['label'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrency(item['amount']),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

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
      drawer: const AppDrawer(currentRoute: 'Resumo Mensal'),
      appBar: AppBar(
        title: const Text('Resumo do Mês'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transacoes')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final allUserTransactions = docs.map((doc) {
            return Transacao.fromJson(
              doc.data() as Map<String, dynamic>,
              docId: doc.id,
            );
          }).toList();

          // 1. Group transactions by month (format "yyyy-MM")
          final groups = <String, List<Transacao>>{};
          for (var tx in allUserTransactions) {
            final parts = tx.date.split('-');
            if (parts.length >= 2) {
              final yearMonth = "${parts[0]}-${parts[1]}";
              groups.putIfAbsent(yearMonth, () => []).add(tx);
            }
          }

          // 2. Sort months chronologically
          final sortedMonthKeys = groups.keys.toList()..sort();

          // If no transactions, display empty state or simple info
          if (sortedMonthKeys.isEmpty) {
            return Container(
              decoration: isDark
                  ? const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF133E28), Color(0xFF0E2F1F)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    )
                  : null,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 64,
                      color: isDark ? const Color(0xFF86EFAC) : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum dado para exibir no resumo.',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Build month Summaries list
          final List<Map<String, dynamic>> monthSummaries = [];
          for (int i = 0; i < sortedMonthKeys.length; i++) {
            final key = sortedMonthKeys[i]; // "yyyy-MM"
            final monthTx = groups[key]!;
            final parts = key.split('-');
            final year = int.tryParse(parts[0]) ?? DateTime.now().year;
            final month = int.tryParse(parts[1]) ?? DateTime.now().month;

            double income = 0.0;
            double expense = 0.0;
            for (var tx in monthTx) {
              if (tx.type == 'income') {
                income += tx.amount;
              } else {
                expense += tx.amount.abs();
              }
            }

            // Group top expenses by description
            final expGroups = <String, double>{};
            final incGroups = <String, double>{};
            for (var tx in monthTx) {
              if (tx.type == 'expense') {
                expGroups[tx.description] = (expGroups[tx.description] ?? 0.0) + tx.amount.abs();
              } else {
                incGroups[tx.description] = (incGroups[tx.description] ?? 0.0) + tx.amount;
              }
            }

            final topExpenses = expGroups.entries
                .map((e) => {'label': e.key, 'amount': e.value})
                .toList()
              ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

            final topIncome = incGroups.entries
                .map((e) => {'label': e.key, 'amount': e.value})
                .toList()
              ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

            // Map transactions list to match original format
            final transactionsList = monthTx.map((tx) {
              String displayDate = tx.date;
              final parts = tx.date.split('-');
              if (parts.length >= 3) {
                displayDate = "${parts[2]}/${parts[1]}";
              }
              return {
                'date': displayDate,
                'description': tx.description,
                'amount': tx.amount,
                'type': tx.type,
              };
            }).toList();

            monthSummaries.add({
              'monthName': "${_getMonthName(month)} $year",
              'income': income,
              'expense': expense,
              'previousExpense': 0.0, // will compute next
              'topExpenses': topExpenses.take(3).toList(),
              'topIncome': topIncome.take(3).toList(),
              'transactions': transactionsList,
            });
          }

          // 4. Fill in previousExpense
          for (int i = 0; i < monthSummaries.length; i++) {
            if (i > 0) {
              monthSummaries[i]['previousExpense'] = monthSummaries[i - 1]['expense'] as double;
            }
          }

          // 5. Bounds-check on selectedIndex
          int selectedIndex = _selectedMonthIndex;
          if (selectedIndex >= monthSummaries.length) {
            selectedIndex = monthSummaries.length - 1;
          }
          if (selectedIndex < 0) {
            selectedIndex = 0;
          }
          _selectedMonthIndex = selectedIndex; // silently assign to keep state consistent

          final selectedMonth = monthSummaries[selectedIndex];
          final income = selectedMonth['income'] as double;
          final expense = selectedMonth['expense'] as double;
          final total = income + expense;
          final balance = income - expense;
          final spendRatio = income == 0 ? 0.0 : (expense / income).clamp(0.0, 1.0);

          // Variation calculation
          final previous = selectedMonth['previousExpense'] as double;
          String expenseVariation = 'Sem comparação anterior';
          if (previous > 0) {
            final percent = ((expense - previous) / previous) * 100;
            final prefix = percent >= 0 ? '+' : '';
            final label = percent >= 0 ? 'gastos' : 'menos gastos';
            expenseVariation = '$prefix${percent.toStringAsFixed(1)}% $label';
          }

          return Container(
            decoration: isDark
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF133E28), Color(0xFF0E2F1F)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  )
                : null,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                        onPressed: () => _changeMonth(-1, monthSummaries.length),
                      ),
                      Text(
                        selectedMonth['monthName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                        onPressed: () => _changeMonth(1, monthSummaries.length),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useRow = constraints.maxWidth > 640;
                      return Flex(
                        direction: useRow ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStatCard(
                            label: 'Total Ganho',
                            value: _formatCurrency(income),
                            color: const Color(0xFF4ADE80),
                            icon: Icons.arrow_upward,
                          ),
                          SizedBox(width: useRow ? 16 : 0, height: useRow ? 0 : 16),
                          _buildStatCard(
                            label: 'Total Gasto',
                            value: _formatCurrency(expense),
                            color: Colors.red.shade400,
                            icon: Icons.arrow_downward,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comparação',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildProgressBar(
                            label: 'Ganho',
                            amount: income,
                            ratio: total == 0 ? 0 : income / total,
                            color: const Color(0xFF4ADE80),
                          ),
                          const SizedBox(height: 16),
                          _buildProgressBar(
                            label: 'Gasto',
                            amount: expense,
                            ratio: total == 0 ? 0 : expense / total,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Percentual gasto em relação ao ganho',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? const Color(0xFF86EFAC)
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: spendRatio),
                                  duration: const Duration(milliseconds: 1500),
                                  curve: Curves.fastOutSlowIn,
                                  builder: (context, value, child) {
                                    return SizedBox(
                                      height: 220,
                                      width: 220,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CustomPaint(
                                            size: const Size(220, 220),
                                            painter: DonutArcPainter(value, isDark),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${(value * 100).toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                                  height: 1.0,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Gasto',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? Colors.white60 : Colors.black45,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 440;
                          return Flex(
                            direction: isNarrow ? Axis.vertical : Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Saldo do mês',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _formatCurrency(balance),
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: balance >= 0
                                          ? const Color(0xFF16A34A)
                                          : Colors.red.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              if (isNarrow) const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Variação',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? const Color(0xFF86EFAC)
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    expenseVariation,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: expenseVariation.startsWith('-') || expenseVariation == 'Sem comparação anterior'
                                          ? const Color(0xFF16A34A)
                                          : Colors.red.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 560;
                      final List<Map<String, dynamic>> expensesList = List<Map<String, dynamic>>.from(selectedMonth['topExpenses']);
                      final List<Map<String, dynamic>> incomeList = List<Map<String, dynamic>>.from(selectedMonth['topIncome']);

                      final leftCard = _buildTopList(
                        '3 maiores despesas',
                        expensesList,
                        Colors.red.shade400,
                      );
                      final rightCard = _buildTopList(
                        '3 principais receitas',
                        incomeList,
                        const Color(0xFF4ADE80),
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            leftCard,
                            const SizedBox(height: 16),
                            rightCard,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: leftCard),
                          const SizedBox(width: 16),
                          Expanded(child: rightCard),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _showDetails = !_showDetails);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(_showDetails ? 'Ocultar detalhes' : 'Ver detalhes'),
                  ),
                  const SizedBox(height: 16),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Colors.grey.shade200,
                            ),
                            columns: const [
                              DataColumn(label: Text('Data')),
                              DataColumn(label: Text('Descrição')),
                              DataColumn(label: Text('Valor')),
                            ],
                            rows:
                                (selectedMonth['transactions']
                                        as List<Map<String, dynamic>>)
                                    .map(
                                      (transaction) => DataRow(
                                        cells: [
                                          DataCell(Text(transaction['date'])),
                                          DataCell(
                                            Text(transaction['description']),
                                          ),
                                          DataCell(
                                            Text(
                                              _formatCurrency(
                                                (transaction['amount'] as double)
                                                    .abs(),
                                              ),
                                              style: TextStyle(
                                                color:
                                                    transaction['type'] == 'income'
                                                    ? const Color(0xFF16A34A)
                                                    : Colors.red.shade400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                    ),
                    crossFadeState: _showDetails
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DonutArcPainter extends CustomPainter {
  final double value;
  final bool isDark;

  DonutArcPainter(this.value, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    final trackPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.red.shade50
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;

    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) return;

    final sweepAngle = 2 * 3.141592653589793 * value;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFF5252), // Vibrant red top
        Color(0xFFC62828), // Deep red bottom
      ],
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 24;

    final shadowPaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 24
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(arcRect, -1.5707963267948966, sweepAngle, false, shadowPaint);
    canvas.drawArc(arcRect, -1.5707963267948966, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant DonutArcPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.isDark != isDark;
  }
}
