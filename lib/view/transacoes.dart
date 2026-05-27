import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transacao.dart';
import 'pesquisa.dart';
import 'widgets/app_drawer.dart';
import 'widgets/message_helpers.dart';
import 'widgets/observacoes_bottom_sheet.dart';
import 'adicionar_transacao.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView>
    with SingleTickerProviderStateMixin {
  String _filter = 'all'; // all, income, expense
  bool _isEditMode = false;

  late final AnimationController _editAnimController;
  late final Animation<double> _editAnim;

  @override
  void initState() {
    super.initState();
    _editAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _editAnim = CurvedAnimation(
      parent: _editAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _editAnimController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
    if (_isEditMode) {
      _editAnimController.forward();
    } else {
      _editAnimController.reverse();
    }
  }

  Future<void> _deleteTransaction(Transacao transaction) async {
    try {
      await FirebaseFirestore.instance.collection('transacoes').doc(transaction.id).delete();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Erro ao excluir transação: $e', isError: true);
      }
    }
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
      drawer: const AppDrawer(currentRoute: 'Transações'),
      appBar: AppBar(
        title: const Text('Transações'),
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _toggleEditMode,
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? const Color(0xFF86EFAC)
                    : Colors.green.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _isEditMode ? 'Concluir' : 'Editar',
                  key: ValueKey(_isEditMode),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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

            // Client-side filtering and sorting
            final filteredTransactions = transactions.where((t) {
              if (_filter == 'all') return true;
              return t.type == _filter;
            }).toList();

            filteredTransactions.sort((a, b) {
              final dateComp = b.date.compareTo(a.date);
              if (dateComp != 0) return dateComp;
              return b.createdAt.compareTo(a.createdAt);
            });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'all',
                          label: Text('Todas', style: TextStyle(fontSize: 14)),
                        ),
                        ButtonSegment(
                          value: 'income',
                          label: Text('Receitas', style: TextStyle(fontSize: 14)),
                        ),
                        ButtonSegment(
                          value: 'expense',
                          label: Text('Despesas', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                      selected: {_filter},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _filter = newSelection.first;
                        });
                      },
                    ),
                  ),
                ),
                // Edit mode banner
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _isEditMode
                      ? Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(
                              alpha: isDark ? 0.15 : 0.08,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.red.shade400,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Toque na lixeira para excluir um item',
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 56,
                                color: isDark
                                    ? const Color(0xFF86EFAC).withValues(alpha: 0.3)
                                    : Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhuma transação encontrada',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(
                                          0xFF86EFAC,
                                        ).withValues(alpha: 0.5)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            final isIncome = transaction.type == 'income';

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ListTile(
                                onTap: _isEditMode
                                    ? null
                                    : () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => ObservacoesBottomSheet(
                                            relatedId: transaction.id,
                                            title: transaction.description,
                                            subtitle: 'Transação - R\$ ${transaction.amount.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                                          ),
                                        );
                                      },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: isIncome
                                      ? const Color(
                                          0xFF4ADE80,
                                        ).withValues(alpha: isDark ? 0.2 : 0.15)
                                      : Colors.red.withValues(alpha: 0.15),
                                  child: Icon(
                                    isIncome
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: isIncome
                                        ? (isDark
                                              ? const Color(0xFF4ADE80)
                                              : Colors.green)
                                        : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        transaction.description,
                                        style: TextStyle(
                                          color: isDark ? const Color(0xFF86EFAC) : null,
                                          fontWeight: FontWeight.w500,
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
                                        ? const Color(
                                            0xFF86EFAC,
                                          ).withValues(alpha: 0.6)
                                        : null,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'R\$ ${transaction.amount.abs().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isIncome
                                            ? (isDark
                                                  ? const Color(0xFF4ADE80)
                                                  : Colors.green)
                                            : Colors.red.shade400,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    // Animated delete button
                                    SizeTransition(
                                      sizeFactor: _editAnim,
                                      axis: Axis.horizontal,
                                      child: FadeTransition(
                                        opacity: _editAnim,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: GestureDetector(
                                            onTap: () =>
                                                _confirmDelete(transaction),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: 0.12,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red.shade400,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionView()),
          );
        },
        backgroundColor: isDark ? const Color(0xFF86EFAC) : null,
        foregroundColor: isDark ? const Color(0xFF133E28) : null,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _confirmDelete(Transacao transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF133E28) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red.shade400, size: 24),
              const SizedBox(width: 10),
              Text(
                'Excluir transação?',
                style: TextStyle(
                  color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Tem certeza que deseja excluir "${transaction.description}"?',
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF86EFAC).withValues(alpha: 0.8)
                  : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF86EFAC)
                      : Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteTransaction(transaction);
      if (mounted) {
        showAppSnackBar(context, 'Transação excluída com sucesso!');
      }
    }
  }
}
