import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/observacao.dart';
import 'message_helpers.dart';

class ObservacoesBottomSheet extends StatefulWidget {
  final String relatedId;
  final String title;
  final String subtitle;

  const ObservacoesBottomSheet({
    super.key,
    required this.relatedId,
    required this.title,
    required this.subtitle,
  });

  @override
  State<ObservacoesBottomSheet> createState() => _ObservacoesBottomSheetState();
}

class _ObservacoesBottomSheetState extends State<ObservacoesBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    final month = months[dt.month - 1];
    final minute = dt.minute.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    return '${dt.day} de $month. às $hour:$minute';
  }

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showAppSnackBar(context, 'Usuário não autenticado.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('observacoes').doc();
      final note = Observacao(
        id: docRef.id,
        uid: user.uid,
        relatedId: widget.relatedId,
        text: text,
        createdAt: DateTime.now(),
      );

      await docRef.set(note.toJson());
      _controller.clear();
      if (mounted) {
        // Encerra foco do teclado
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Erro ao adicionar anotação: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNote(Observacao note) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir anotação?',
      content: 'Esta anotação será removida permanentemente.',
      confirmLabel: 'Excluir',
      confirmColor: Colors.red.shade400,
      icon: Icons.delete_outline,
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('observacoes')
            .doc(note.id)
            .delete();
        if (mounted) {
          showAppSnackBar(context, 'Anotação excluída com sucesso!');
        }
      } catch (e) {
        if (mounted) {
          showAppSnackBar(context, 'Erro ao excluir anotação: $e', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF133E28) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF86EFAC).withValues(alpha: 0.6)
                                : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? const Color(0xFF86EFAC) : Colors.grey.shade600,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // Notes List (StreamBuilder)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('observacoes')
                    .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .where('relatedId', isEqualTo: widget.relatedId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final notes = docs.map((doc) {
                    return Observacao.fromJson(
                      doc.data() as Map<String, dynamic>,
                      docId: doc.id,
                    );
                  }).toList();

                  // Sort newest first
                  notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (notes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 48,
                              color: isDark
                                  ? const Color(0xFF86EFAC).withValues(alpha: 0.3)
                                  : Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma anotação ainda',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF86EFAC).withValues(alpha: 0.5)
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Adicione observações ou anotações rápidas usando o campo abaixo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF86EFAC).withValues(alpha: 0.35)
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDateTime(note.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? const Color(0xFF86EFAC).withValues(alpha: 0.5)
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _deleteNote(note),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Input Field Area
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              color: isDark ? const Color(0xFF0E2F1F) : Colors.grey.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addNote(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Adicionar anotação...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF86EFAC).withValues(alpha: 0.4)
                                : Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _isLoading
                      ? const SizedBox(
                          width: 44,
                          height: 44,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF86EFAC) : Colors.green.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded),
                            color: isDark ? const Color(0xFF133E28) : Colors.white,
                            onPressed: _addNote,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
