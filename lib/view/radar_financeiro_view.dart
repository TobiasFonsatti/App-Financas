import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';

// ──────────────────────────────────────────────
// Data models (will be replaced by API models)
// ──────────────────────────────────────────────
class _CurrencyItem {
  final String code;
  final String name;
  final String flagEmoji;
  final double value;
  final double change;

  const _CurrencyItem({
    required this.code,
    required this.name,
    required this.flagEmoji,
    required this.value,
    required this.change,
  });
}

class _IndicatorItem {
  final String name;
  final String description;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _IndicatorItem({
    required this.name,
    required this.description,
    required this.value,
    required this.icon,
    required this.accentColor,
  });
}

class _StockItem {
  final String ticker;
  final String name;
  final double price;
  final double change;

  const _StockItem({
    required this.ticker,
    required this.name,
    required this.price,
    required this.change,
  });
}

// ──────────────────────────────────────────────
// Mock data (to be replaced by BRAPI responses)
// ──────────────────────────────────────────────
const _currencies = [
  _CurrencyItem(
    code: 'USD',
    name: 'Dólar Americano',
    flagEmoji: '🇺🇸',
    value: 5.67,
    change: 0.32,
  ),
  _CurrencyItem(
    code: 'EUR',
    name: 'Euro',
    flagEmoji: '🇪🇺',
    value: 6.18,
    change: -0.14,
  ),
];

final _indicators = [
  _IndicatorItem(
    name: 'Selic - Teste',
    description: 'Taxa básica de juros',
    value: '13,75% a.a.',
    icon: Icons.account_balance_outlined,
    accentColor: const Color(0xFF2196F3),
  ),
  _IndicatorItem(
    name: 'IPCA',
    description: 'Inflação acumulada 12m',
    value: '4,83%',
    icon: Icons.show_chart,
    accentColor: const Color(0xFFFBBF24),
  ),
];

const _stocks = [
  _StockItem(ticker: 'PETR4', name: 'Petrobras', price: 38.72, change: 1.24),
  _StockItem(ticker: 'VALE3', name: 'Vale', price: 62.15, change: -0.87),
  _StockItem(ticker: 'ITUB4', name: 'Itaú Unibanco', price: 34.90, change: 0.53),
  _StockItem(ticker: 'MGLU3', name: 'Magazine Luiza', price: 9.87, change: -0.45),
];

// ──────────────────────────────────────────────
// Main View
// ──────────────────────────────────────────────
class RadarFinanceiroView extends StatefulWidget {
  const RadarFinanceiroView({super.key});

  @override
  State<RadarFinanceiroView> createState() => _RadarFinanceiroViewState();
}

class _RadarFinanceiroViewState extends State<RadarFinanceiroView>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Simulates last update timestamp
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isLoading = false;
      _lastUpdated = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'Radar Financeiro'),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Opacity(
                opacity: _pulseAnimation.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Radar Financeiro'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
            onPressed: _isLoading ? null : _refresh,
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
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF4ADE80),
          backgroundColor: isDark ? const Color(0xFF133E28) : Colors.white,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Last updated chip ──
              _buildLastUpdatedChip(isDark),
              const SizedBox(height: 20),

              // ── Section: Câmbio ──
              _buildSectionHeader(
                isDark,
                icon: Icons.currency_exchange,
                title: 'Câmbio',
                subtitle: 'Cotações em tempo real',
              ),
              const SizedBox(height: 12),
              _buildCurrencySection(isDark),
              const SizedBox(height: 28),

              // ── Section: Indicadores ──
              _buildSectionHeader(
                isDark,
                icon: Icons.analytics_outlined,
                title: 'Indicadores Econômicos',
                subtitle: 'Taxas e índices do Brasil',
              ),
              const SizedBox(height: 12),
              _buildIndicatorsGrid(isDark),
              const SizedBox(height: 28),

              // ── Section: Ações ──
              _buildSectionHeader(
                isDark,
                icon: Icons.candlestick_chart_outlined,
                title: 'Ações',
                subtitle: 'B3 — Principais papéis',
              ),
              const SizedBox(height: 12),
              _buildStocksList(isDark),
              const SizedBox(height: 16),

              // ── Disclaimer ──
              _buildDisclaimer(isDark),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────
  Widget _buildSectionHeader(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF4ADE80).withValues(alpha: 0.15)
                : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDark ? const Color(0xFF4ADE80) : Colors.green.shade700,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF86EFAC).withValues(alpha: 0.55)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────
  // LAST UPDATED CHIP
  // ─────────────────────────────────
  Widget _buildLastUpdatedChip(bool isDark) {
    final h = _lastUpdated.hour.toString().padLeft(2, '0');
    final m = _lastUpdated.minute.toString().padLeft(2, '0');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF4ADE80).withValues(alpha: 0.2)
                  : Colors.green.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: isDark
                    ? const Color(0xFF4ADE80)
                    : Colors.green.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                'Atualizado às $h:$m',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF86EFAC)
                      : Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────
  // CURRENCY CARDS
  // ─────────────────────────────────
  Widget _buildCurrencySection(bool isDark) {
    return Column(
      children: _currencies
          .map((c) => _CurrencyCard(currency: c, isDark: isDark))
          .toList(),
    );
  }

  // ─────────────────────────────────
  // INDICATORS ROW
  // ─────────────────────────────────
  Widget _buildIndicatorsGrid(bool isDark) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _IndicatorCard(item: _indicators[0], isDark: isDark)),
          const SizedBox(width: 12),
          Expanded(child: _IndicatorCard(item: _indicators[1], isDark: isDark)),
        ],
      ),
    );
  }

  // ─────────────────────────────────
  // STOCKS LIST
  // ─────────────────────────────────
  Widget _buildStocksList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade100,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: _stocks.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final isLast = i == _stocks.length - 1;
          return _StockRow(stock: s, isDark: isDark, isLast: isLast);
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────
  // DISCLAIMER
  // ─────────────────────────────────
  Widget _buildDisclaimer(bool isDark) {
    return Center(
      child: Text(
        '* Dados fornecidos pela BRAPI. Fins informativos apenas.',
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? const Color(0xFF86EFAC).withValues(alpha: 0.35)
              : Colors.grey.shade400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ══════════════════════════════════════════════
// CURRENCY CARD WIDGET
// ══════════════════════════════════════════════
class _CurrencyCard extends StatelessWidget {
  final _CurrencyItem currency;
  final bool isDark;

  const _CurrencyCard({required this.currency, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPositive = currency.change >= 0;
    final changeColor = isPositive ? const Color(0xFF4ADE80) : Colors.red.shade400;
    final changeIcon = isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.07),
                  Colors.white.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade100,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Flag + code
          Text(currency.flagEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currency.code,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                ),
              ),
              Text(
                currency.name,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF86EFAC).withValues(alpha: 0.55)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Price + change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${currency.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(changeIcon, size: 16, color: changeColor),
                    Text(
                      '${currency.change.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// INDICATOR CARD WIDGET
// ══════════════════════════════════════════════
class _IndicatorCard extends StatelessWidget {
  final _IndicatorItem item;
  final bool isDark;

  const _IndicatorCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.07),
                  Colors.white.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade100,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, color: item.accentColor, size: 19),
          ),
          const SizedBox(height: 16),
          // Value
          Text(
            item.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: item.accentColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Name
          Text(
            item.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          // Description
          Text(
            item.description,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? const Color(0xFF86EFAC).withValues(alpha: 0.5)
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// STOCK ROW WIDGET
// ══════════════════════════════════════════════
class _StockRow extends StatelessWidget {
  final _StockItem stock;
  final bool isDark;
  final bool isLast;

  const _StockRow({
    required this.stock,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.change >= 0;
    final changeColor = isPositive ? const Color(0xFF4ADE80) : Colors.red.shade400;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Ticker badge
              Container(
                width: 52,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF4ADE80).withValues(alpha: 0.12)
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    stock.ticker,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFF4ADE80)
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Company name
              Expanded(
                child: Text(
                  stock.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                  ),
                ),
              ),
              // Price + change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${stock.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: changeColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.grey.shade100,
          ),
      ],
    );
  }
}
