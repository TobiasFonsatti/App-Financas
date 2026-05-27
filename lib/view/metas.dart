import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/financial_goal.dart';
import 'widgets/app_drawer.dart';
import 'widgets/observacoes_bottom_sheet.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    double value = double.parse(newText) / 100;
    String formattedValue = value.toStringAsFixed(2).replaceAll('.', ',');

    List<String> parts = formattedValue.split(',');
    String intPart = parts[0];
    String decPart = parts[1];

    String finalIntPart = "";
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        finalIntPart = ".$finalIntPart";
        count = 0;
      }
      finalIntPart = intPart[i] + finalIntPart;
      count++;
    }

    String newString = '$finalIntPart,$decPart';

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────
class MetasView extends StatefulWidget {
  const MetasView({super.key});

  @override
  State<MetasView> createState() => _MetasViewState();
}

class _MetasViewState extends State<MetasView> {

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Color _barColor(double ratio) {
    if (ratio >= 0.5) return const Color(0xFF4ADE80);
    if (ratio >= 0.2) return const Color(0xFFFBBF24);
    return Colors.red.shade400;
  }

  Future<void> _togglePause(FinancialGoal goal) async {
    try {
      await FirebaseFirestore.instance
          .collection('metas')
          .doc(goal.id)
          .update({'paused': !goal.paused});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar status: $e')),
        );
      }
    }
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
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
                    onPressed: () async {
                      final raw = ctrl.text
                          .replaceAll('.', '')
                          .replaceAll(',', '.');
                      final val = double.tryParse(raw) ?? 0;
                      if (val <= 0) return;

                      final newAmount = (goal.currentAmount + val).clamp(0.0, goal.targetAmount);

                      try {
                        await FirebaseFirestore.instance
                            .collection('metas')
                            .doc(goal.id)
                            .update({'currentAmount': newAmount});
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Erro ao salvar: $e')),
                          );
                        }
                      }
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
      text: isNew ? '' : goal.targetAmount.toStringAsFixed(2).replaceAll('.', ','),
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
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
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final target = double.tryParse(
                            targetCtrl.text
                                .replaceAll('.', '')
                                .replaceAll(',', '.'),
                          ) ??
                          0;
                      final months =
                          int.tryParse(monthsCtrl.text.trim()) ?? 0;

                      if (name.isEmpty || target <= 0 || months <= 0) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text('Preencha todos os campos.')),
                        );
                        return;
                      }

                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Usuário não autenticado.')),
                        );
                        return;
                      }

                      try {
                        if (isNew) {
                          final docRef = FirebaseFirestore.instance.collection('metas').doc();
                          final newGoal = FinancialGoal(
                            id: docRef.id,
                            uid: user.uid,
                            name: name,
                            emoji: emojiCtrl.text.trim().isEmpty ? '🎯' : emojiCtrl.text.trim(),
                            targetAmount: target,
                            currentAmount: 0.0,
                            monthsLeft: months,
                            paused: false,
                            createdAt: DateTime.now(),
                          );
                          await docRef.set(newGoal.toJson());
                        } else {
                          await FirebaseFirestore.instance
                              .collection('metas')
                              .doc(goal.id)
                              .update({
                            'name': name,
                            'emoji': emojiCtrl.text.trim().isEmpty ? '🎯' : emojiCtrl.text.trim(),
                            'targetAmount': target,
                            'monthsLeft': months,
                          });
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Erro ao salvar meta: $e')),
                          );
                        }
                      }
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
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir meta?'),
        content:
            Text('A meta "${goal.name}" será removida permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('metas')
                    .doc(goal.id)
                    .delete();
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              } catch (e) {
                if (dialogCtx.mounted) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir meta: $e')),
                  );
                }
              }
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
                        color: Colors.amber.withValues(alpha: 0.15),
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
                        _togglePause(goal);
                      }
                      if (v == 'notes') {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ObservacoesBottomSheet(
                            relatedId: goal.id,
                            title: '${goal.emoji} ${goal.name}',
                            subtitle: 'Meta - Objetivo R\$ ${goal.targetAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                          ),
                        );
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
                        value: 'notes',
                        child: Row(children: [
                          Icon(
                            Icons.description_outlined,
                            color: isDark
                                ? const Color(0xFF86EFAC)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          const Text('Anotações'),
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
    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('metas')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            final goals = docs.map((doc) {
              return FinancialGoal.fromJson(
                doc.data() as Map<String, dynamic>,
                docId: doc.id,
              );
            }).toList();

            // Client-side sort by createdAt
            goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (goals.isEmpty) {
              return _buildEmpty();
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: goals.length,
              itemBuilder: (_, i) => _buildGoalCard(goals[i]),
            );
          },
        ),
      ),
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
