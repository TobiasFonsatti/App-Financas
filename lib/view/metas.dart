import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/app_drawer.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class FinancialGoal {
  String id;
  String name;
  String emoji;
  double targetAmount;
  double currentAmount;
  int monthsLeft;
  bool paused;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthsLeft,
    this.paused = false,
  });

  double get progress =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  double get remaining =>
      (targetAmount - currentAmount).clamp(0, double.infinity);

  double get monthlyNeeded =>
      monthsLeft <= 0 ? remaining : remaining / monthsLeft;
}

// ─── View ─────────────────────────────────────────────────────────────────────
class MetasView extends StatefulWidget {
  const MetasView({super.key});

  @override
  State<MetasView> createState() => _MetasViewState();
}

class _MetasViewState extends State<MetasView> {
  final List<FinancialGoal> _goals = [
    FinancialGoal(
      id: '1',
      name: 'Viagem Europa',
      emoji: '✈️',
      targetAmount: 15000,
      currentAmount: 6200,
      monthsLeft: 11,
    ),
    FinancialGoal(
      id: '2',
      name: 'Carro novo',
      emoji: '🚗',
      targetAmount: 45000,
      currentAmount: 3500,
      monthsLeft: 32,
    ),
    FinancialGoal(
      id: '3',
      name: 'Reserva de emergência',
      emoji: '🛡️',
      targetAmount: 10000,
      currentAmount: 7800,
      monthsLeft: 2,
    ),
  ];

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Color _barColor(double ratio) {
    if (ratio >= 0.5) return const Color(0xFF4ADE80);
    if (ratio >= 0.2) return const Color(0xFFFBBF24);
    return Colors.red.shade400;
  }

  // ── Add value dialog ─────────────────────────────────────────────────────
  void _showAddValue(FinancialGoal goal) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF133E28) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${goal.emoji}  Adicionar a "${goal.name}"',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Valor (R\$)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      backgroundColor: const Color(0xFF4ADE80),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final raw = ctrl.text
                          .replaceAll(',', '.')
                          .replaceAll(RegExp(r'[^\d.]'), '');
                      final val = double.tryParse(raw) ?? 0;
                      if (val <= 0) return;
                      setState(() {
                        goal.currentAmount =
                            (goal.currentAmount + val)
                                .clamp(0, goal.targetAmount);
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Goal form ────────────────────────────────────────────────────────────
  void _showGoalForm({FinancialGoal? goal}) {
    final isNew = goal == null;
    final nameCtrl = TextEditingController(text: goal?.name ?? '');
    final emojiCtrl = TextEditingController(text: goal?.emoji ?? '🎯');
    final targetCtrl = TextEditingController(
      text: isNew ? '' : goal.targetAmount.toStringAsFixed(0),
    );
    final monthsCtrl = TextEditingController(
      text: isNew ? '' : goal.monthsLeft.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF133E28) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNew ? 'Nova Meta' : 'Editar Meta',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: TextField(
                          controller: emojiCtrl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22),
                          decoration: InputDecoration(
                            labelText: 'Emoji',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nome da meta',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Valor objetivo (R\$)',
                      prefixIcon: const Icon(Icons.flag_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: monthsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Meses restantes',
                      prefixIcon:
                          const Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final target = double.tryParse(
                            targetCtrl.text
                                .replaceAll(',', '.')
                                .replaceAll(RegExp(r'[^\d.]'), ''),
                          ) ??
                          0;
                      final months =
                          int.tryParse(monthsCtrl.text.trim()) ?? 0;

                      if (name.isEmpty || target <= 0 || months <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Preencha todos os campos.')),
                        );
                        return;
                      }

                      setState(() {
                        if (isNew) {
                          _goals.add(FinancialGoal(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: name,
                            emoji: emojiCtrl.text.trim().isEmpty
                                ? '🎯'
                                : emojiCtrl.text.trim(),
                            targetAmount: target,
                            currentAmount: 0,
                            monthsLeft: months,
                          ));
                        } else {
                          goal.name = name;
                          goal.emoji = emojiCtrl.text.trim().isEmpty
                              ? '🎯'
                              : emojiCtrl.text.trim();
                          goal.targetAmount = target;
                          goal.monthsLeft = months;
                        }
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text(isNew ? 'Criar Meta' : 'Salvar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Delete confirm ───────────────────────────────────────────────────────
  void _confirmDelete(FinancialGoal goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir meta?'),
        content:
            Text('A meta "${goal.name}" será removida permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() => _goals.remove(goal));
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // ── Progress bar (mesmo estilo do monthly_summary) ───────────────────────
  Widget _buildProgressBar(FinancialGoal goal, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(goal.progress * 100).toStringAsFixed(1)}% concluído',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              _formatCurrency(goal.targetAmount),
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
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
              widthFactor: goal.progress,
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

  // ── Card (mesmo estilo de Card do monthly_summary) ───────────────────────
  Widget _buildGoalCard(FinancialGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _barColor(goal.progress);

    return AnimatedOpacity(
      opacity: goal.paused ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Text(goal.emoji,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${goal.monthsLeft} ${goal.monthsLeft == 1 ? 'mês restante' : 'meses restantes'}',
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF86EFAC)
                                  : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  if (goal.paused)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Pausada',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onSelected: (v) {
                      if (v == 'edit') _showGoalForm(goal: goal);
                      if (v == 'pause') {
                        setState(() => goal.paused = !goal.paused);
                      }
                      if (v == 'delete') _confirmDelete(goal);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_outlined,
                              color: isDark
                                  ? const Color(0xFF86EFAC)
                                  : null),
                          const SizedBox(width: 10),
                          const Text('Editar'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'pause',
                        child: Row(children: [
                          Icon(
                            goal.paused
                                ? Icons.play_arrow_outlined
                                : Icons.pause_outlined,
                            color: isDark
                                ? const Color(0xFF86EFAC)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(goal.paused ? 'Retomar' : 'Pausar'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: const [
                          Icon(Icons.delete_outline,
                              color: Colors.red),
                          SizedBox(width: 10),
                          Text('Excluir',
                              style: TextStyle(color: Colors.red)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Progress bar ──
              _buildProgressBar(goal, color),
              const SizedBox(height: 20),

              // ── Stats row (mesmo padrão dos stat cards do monthly_summary) ──
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.savings_outlined,
                    label: 'Guardado',
                    value: _formatCurrency(goal.currentAmount),
                    color: const Color(0xFF4ADE80),
                  ),
                  _buildStatItem(
                    icon: Icons.hourglass_bottom_outlined,
                    label: 'Faltam',
                    value: _formatCurrency(goal.remaining),
                    color: Colors.red.shade400,
                  ),
                  _buildStatItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Por mês',
                    value: _formatCurrency(goal.monthlyNeeded),
                    color: isDark
                        ? const Color(0xFF86EFAC)
                        : Colors.grey.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Add button ──
              ElevatedButton(
                onPressed: goal.paused ? null : () => _showAddValue(goal),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Adicionar valor'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'Metas'),
      appBar: AppBar(
        title: const Text('Metas Financeiras'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoalForm(),
        backgroundColor:
            isDark ? const Color(0xFF86EFAC) : null,
        foregroundColor:
            isDark ? const Color(0xFF133E28) : null,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        child: _goals.isEmpty ? _buildEmpty() : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _goals.length,
      itemBuilder: (_, i) => _buildGoalCard(_goals[i]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma meta ainda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Crie sua primeira meta financeira!',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Nova Meta'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () => _showGoalForm(),
          ),
        ],
      ),
    );
  }
}
