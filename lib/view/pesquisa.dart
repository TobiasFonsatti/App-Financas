import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transacao.dart';
import 'widgets/app_drawer.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _typeFilter = 'all'; // all, income, expense
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc, alpha_asc, alpha_desc

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _query = '';
    });
  }

  String _normalize(String text) {
    var str = text.toLowerCase();
    const withDiacritics = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const withoutDiacritics = 'aaaaaeeeeiiiiooooouuuucn';
    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return str;
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
      drawer: const AppDrawer(currentRoute: 'Pesquisa'),
      appBar: AppBar(
        title: const Text('Pesquisa de Transações'),
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
        child: Column(
          children: [
            // Search Input Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _query = val;
                    });
                  },
                  style: TextStyle(
                    color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar pela descrição...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? const Color(0xFF86EFAC).withValues(alpha: 0.5)
                          : Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? const Color(0xFF86EFAC) : Colors.green.shade600,
                    ),
                    suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          color: isDark ? const Color(0xFF86EFAC) : Colors.grey,
                          onPressed: _clearSearch,
                        )
                      : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                ),
              ),
            ),

            // Chips section for Filtering Type
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Todas', isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('income', 'Receitas', isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('expense', 'Despesas', isDark),
                    ],
                  ),
                ),
              ),
            ),

            // Sorting Label and Dropdown/Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_outlined,
                    size: 18,
                    color: isDark ? const Color(0xFF86EFAC) : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ordenar por:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF86EFAC).withValues(alpha: 0.8) : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSortChip('date_desc', 'Mais recentes', isDark),
                          const SizedBox(width: 6),
                          _buildSortChip('date_asc', 'Mais antigas', isDark),
                          const SizedBox(width: 6),
                          _buildSortChip('amount_desc', 'Maior valor', isDark),
                          const SizedBox(width: 6),
                          _buildSortChip('amount_asc', 'Menor valor', isDark),
                          const SizedBox(width: 6),
                          _buildSortChip('alpha_asc', 'A-Z', isDark),
                          const SizedBox(width: 6),
                          _buildSortChip('alpha_desc', 'Z-A', isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Results Section
            Expanded(
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

                  // Filter: Search query (accent-insensitive & case-insensitive description)
                  var filtered = transactions.where((t) {
                    final normalizedDescription = _normalize(t.description);
                    final normalizedQuery = _normalize(_query.trim());
                    final matchesQuery = normalizedDescription.contains(normalizedQuery);
                    
                    if (_typeFilter == 'all') {
                      return matchesQuery;
                    }
                    return matchesQuery && t.type == _typeFilter;
                  }).toList();

                  // Sort: Apply active sort criteria
                  filtered.sort((a, b) {
                    switch (_sortBy) {
                      case 'date_asc':
                        final dateComp = a.date.compareTo(b.date);
                        if (dateComp != 0) return dateComp;
                        return a.createdAt.compareTo(b.createdAt);
                      case 'amount_desc':
                        return b.amount.abs().compareTo(a.amount.abs());
                      case 'amount_asc':
                        return a.amount.abs().compareTo(b.amount.abs());
                      case 'alpha_asc':
                        return a.description.toLowerCase().compareTo(b.description.toLowerCase());
                      case 'alpha_desc':
                        return b.description.toLowerCase().compareTo(a.description.toLowerCase());
                      case 'date_desc':
                      default:
                        final dateComp = b.date.compareTo(a.date);
                        if (dateComp != 0) return dateComp;
                        return b.createdAt.compareTo(a.createdAt);
                    }
                  });

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 64,
                            color: isDark
                                ? const Color(0xFF86EFAC).withValues(alpha: 0.3)
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma transação encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF86EFAC).withValues(alpha: 0.6)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 40),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final transaction = filtered[index];
                      final isIncome = transaction.type == 'income';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: isDark ? 0 : 1,
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: isIncome
                                  ? const Color(0xFF4ADE80).withValues(alpha: isDark ? 0.2 : 0.15)
                                  : Colors.red.withValues(alpha: 0.15),
                              child: Icon(
                                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isIncome
                                    ? (isDark ? const Color(0xFF4ADE80) : Colors.green)
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
                                      color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                                      fontWeight: FontWeight.w600,
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
                                    : Colors.grey.shade600,
                              ),
                            ),
                            trailing: Text(
                              _formatCurrency(transaction.amount),
                              style: TextStyle(
                                color: isIncome
                                    ? (isDark ? const Color(0xFF4ADE80) : Colors.green.shade600)
                                    : Colors.red.shade400,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isDark) {
    final isSelected = _typeFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? (isDark ? const Color(0xFF133E28) : Colors.white)
              : (isDark ? const Color(0xFF86EFAC) : Colors.black87),
        ),
      ),
      selected: isSelected,
      selectedColor: isDark ? const Color(0xFF86EFAC) : Colors.green.shade600,
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _typeFilter = value;
          });
        }
      },
    );
  }

  Widget _buildSortChip(String value, String label, bool isDark) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? (isDark ? const Color(0xFF133E28) : Colors.white)
              : (isDark ? const Color(0xFF86EFAC).withValues(alpha: 0.8) : Colors.grey.shade700),
        ),
      ),
      selected: isSelected,
      selectedColor: isDark ? const Color(0xFF86EFAC) : Colors.green.shade500,
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = value;
          });
        }
      },
    );
  }
}
