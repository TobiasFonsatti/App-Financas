import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';

class MonthlySummaryView extends StatefulWidget {
  const MonthlySummaryView({super.key});

  @override
  State<MonthlySummaryView> createState() => _MonthlySummaryViewState();
}

class _MonthlySummaryViewState extends State<MonthlySummaryView> {
  final List<Map<String, dynamic>> _monthSummaries = [
    {
      'monthName': 'Abril 2024',
      'income': 5100.0,
      'expense': 3420.0,
      'previousExpense': 3300.0,
      'topExpenses': [
        {'label': 'Aluguel', 'amount': 1200.0},
        {'label': 'Supermercado', 'amount': 820.0},
        {'label': 'Transporte', 'amount': 400.0},
      ],
      'topIncome': [
        {'label': 'Salário', 'amount': 3200.0},
        {'label': 'Freelance', 'amount': 900.0},
        {'label': 'Investimentos', 'amount': 1000.0},
      ],
      'transactions': [
        {
          'date': '05/04',
          'description': 'Salário',
          'amount': 3200.0,
          'type': 'income',
        },
        {
          'date': '08/04',
          'description': 'Aluguel',
          'amount': -1200.0,
          'type': 'expense',
        },
        {
          'date': '10/04',
          'description': 'Supermercado',
          'amount': -820.0,
          'type': 'expense',
        },
        {
          'date': '12/04',
          'description': 'Frete',
          'amount': -220.0,
          'type': 'expense',
        },
        {
          'date': '15/04',
          'description': 'Freelance',
          'amount': 900.0,
          'type': 'income',
        },
        {
          'date': '20/04',
          'description': 'Investimentos',
          'amount': 1000.0,
          'type': 'income',
        },
        {
          'date': '26/04',
          'description': 'Transporte',
          'amount': -400.0,
          'type': 'expense',
        },
      ],
    },
    {
      'monthName': 'Maio 2024',
      'income': 6200.0,
      'expense': 3890.0,
      'previousExpense': 3420.0,
      'topExpenses': [
        {'label': 'Supermercado', 'amount': 980.0},
        {'label': 'Aluguel', 'amount': 1250.0},
        {'label': 'Lazer', 'amount': 420.0},
      ],
      'topIncome': [
        {'label': 'Salário', 'amount': 3200.0},
        {'label': 'Freelance', 'amount': 1400.0},
        {'label': 'Investimentos', 'amount': 1600.0},
      ],
      'transactions': [
        {
          'date': '02/05',
          'description': 'Salário',
          'amount': 3200.0,
          'type': 'income',
        },
        {
          'date': '05/05',
          'description': 'Freelance',
          'amount': 1400.0,
          'type': 'income',
        },
        {
          'date': '08/05',
          'description': 'Aluguel',
          'amount': -1250.0,
          'type': 'expense',
        },
        {
          'date': '11/05',
          'description': 'Supermercado',
          'amount': -980.0,
          'type': 'expense',
        },
        {
          'date': '15/05',
          'description': 'Investimentos',
          'amount': 1600.0,
          'type': 'income',
        },
        {
          'date': '18/05',
          'description': 'Lazer',
          'amount': -420.0,
          'type': 'expense',
        },
        {
          'date': '22/05',
          'description': 'Internet',
          'amount': -350.0,
          'type': 'expense',
        },
        {
          'date': '28/05',
          'description': 'Restaurante',
          'amount': -320.0,
          'type': 'expense',
        },
      ],
    },
    {
      'monthName': 'Junho 2024',
      'income': 5850.0,
      'expense': 4120.0,
      'previousExpense': 3890.0,
      'topExpenses': [
        {'label': 'Aluguel', 'amount': 1275.0},
        {'label': 'Supermercado', 'amount': 910.0},
        {'label': 'Transporte', 'amount': 450.0},
      ],
      'topIncome': [
        {'label': 'Salário', 'amount': 3200.0},
        {'label': 'Bônus', 'amount': 900.0},
        {'label': 'Investimentos', 'amount': 1750.0},
      ],
      'transactions': [
        {
          'date': '03/06',
          'description': 'Salário',
          'amount': 3200.0,
          'type': 'income',
        },
        {
          'date': '07/06',
          'description': 'Bônus',
          'amount': 900.0,
          'type': 'income',
        },
        {
          'date': '10/06',
          'description': 'Aluguel',
          'amount': -1275.0,
          'type': 'expense',
        },
        {
          'date': '14/06',
          'description': 'Supermercado',
          'amount': -910.0,
          'type': 'expense',
        },
        {
          'date': '18/06',
          'description': 'Investimentos',
          'amount': 1750.0,
          'type': 'income',
        },
        {
          'date': '21/06',
          'description': 'Transporte',
          'amount': -450.0,
          'type': 'expense',
        },
        {
          'date': '25/06',
          'description': 'Academia',
          'amount': -335.0,
          'type': 'expense',
        },
      ],
    },
  ];

  int _selectedMonthIndex = 1;
  bool _showDetails = false;

  Map<String, dynamic> get _selectedMonth =>
      _monthSummaries[_selectedMonthIndex];

  double get _balance => _selectedMonth['income'] - _selectedMonth['expense'];

  double get _spendRatio {
    final income = _selectedMonth['income'] as double;
    final expense = _selectedMonth['expense'] as double;
    return income == 0 ? 0 : (expense / income).clamp(0.0, 1.0);
  }

  String get _expenseVariation {
    final previous = _selectedMonth['previousExpense'] as double;
    final current = _selectedMonth['expense'] as double;
    if (previous == 0) return 'Sem comparação anterior';

    final percent = ((current - previous) / previous) * 100;
    final prefix = percent >= 0 ? '+' : '';
    final label = percent >= 0 ? 'gastos' : 'menos gastos';
    return '$prefix${percent.toStringAsFixed(1)}% $label';
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _changeMonth(int delta) {
    final newIndex = _selectedMonthIndex + delta;
    if (newIndex < 0 || newIndex >= _monthSummaries.length) return;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final income = _selectedMonth['income'] as double;
    final expense = _selectedMonth['expense'] as double;
    final total = income + expense;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'Resumo Mensal'),
      appBar: AppBar(
        title: const Text('Resumo do Mês'),
        centerTitle: true,
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
                    onPressed: () => _changeMonth(-1),
                  ),
                  Text(
                    _selectedMonth['monthName'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                    onPressed: () => _changeMonth(1),
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
                              tween: Tween<double>(begin: 0, end: _spendRatio),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            _formatCurrency(_balance),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: _balance >= 0
                                  ? const Color(0xFF16A34A)
                                  : Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                            _expenseVariation,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _expenseVariation.startsWith('-')
                                  ? const Color(0xFF16A34A)
                                  : Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 560;
                  final leftCard = _buildTopList(
                    '3 maiores despesas',
                    _selectedMonth['topExpenses'] as List<Map<String, dynamic>>,
                    Colors.red.shade400,
                  );
                  final rightCard = _buildTopList(
                    '3 principais receitas',
                    _selectedMonth['topIncome'] as List<Map<String, dynamic>>,
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
                        headingRowColor: MaterialStateProperty.all(
                          Colors.grey.shade200,
                        ),
                        columns: const [
                          DataColumn(label: Text('Data')),
                          DataColumn(label: Text('Descrição')),
                          DataColumn(label: Text('Valor')),
                        ],
                        rows:
                            (_selectedMonth['transactions']
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
      ..color = isDark ? Colors.white.withOpacity(0.05) : Colors.red.shade50
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
      ..color = const Color(0xFFFF5252).withOpacity(0.4)
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
