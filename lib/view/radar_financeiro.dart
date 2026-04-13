import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';
import '../service/brapi_service.dart';
import '../model/brapi_models.dart';


class RadarFinanceiroView extends StatefulWidget {
  const RadarFinanceiroView({super.key});

  @override
  State<RadarFinanceiroView> createState() => _RadarFinanceiroViewState();
}

class _RadarFinanceiroViewState extends State<RadarFinanceiroView>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  BrapiMarketData? _marketData;
  final BrapiService _brapiService = BrapiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _brapiService.fetchAllData();
      if (mounted) {
        setState(() {
          _marketData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Erro ao carregar dados. Verifique sua chave API no arquivo .env';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    _brapiService.clearCache();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'Radar Financeiro'),
      appBar: AppBar(
        title: const Text('Radar Financeiro'),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _refresh,
                color: const Color(0xFF4ADE80),
                backgroundColor: isDark
                    ? const Color(0xFF133E28)
                    : Colors.white,
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
  Widget _buildLastUpdatedChip(bool isDark) {
    if (_marketData == null) return const SizedBox.shrink();
    final h = _marketData!.timestamp.hour.toString().padLeft(2, '0');
    final m = _marketData!.timestamp.minute.toString().padLeft(2, '0');
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
                color: isDark ? const Color(0xFF4ADE80) : Colors.green.shade600,
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
  Widget _buildCurrencySection(bool isDark) {
    if (_marketData == null) return const SizedBox.shrink();
    return Column(
      children: _marketData!.currencies
          .map((c) => _CurrencyCard(currency: c, isDark: isDark))
          .toList(),
    );
  }
  Widget _buildIndicatorsGrid(bool isDark) {
    if (_marketData == null) return const SizedBox.shrink();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_marketData!.selic != null)
            Expanded(
              child: _IndicatorCard(
                name: 'Selic',
                description: 'Taxa básica de juros',
                value: '${_marketData!.selic!.value}% a.a.',
                icon: Icons.account_balance_outlined,
                accentColor: const Color(0xFF2196F3),
                isDark: isDark,
              ),
            ),
          if (_marketData!.selic != null && _marketData!.ipca != null)
            const SizedBox(width: 12),
          if (_marketData!.ipca != null)
            Expanded(
              child: _IndicatorCard(
                name: 'IPCA',
                description: 'Inflação acumulada',
                value: '${_marketData!.ipca!.value}%',
                icon: Icons.show_chart,
                accentColor: const Color(0xFFFBBF24),
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildStocksList(bool isDark) {
    if (_marketData == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
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
        children: _marketData!.stocks.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final isLast = i == _marketData!.stocks.length - 1;
          return _StockRow(stock: s, isDark: isDark, isLast: isLast);
        }).toList(),
      ),
    );
  }
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
class _CurrencyCard extends StatelessWidget {
  final BrapiCurrency currency;
  final bool isDark;

  const _CurrencyCard({required this.currency, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPositive = currency.pctChange >= 0;
    final changeColor = isPositive
        ? const Color(0xFF4ADE80)
        : Colors.red.shade400;
    final changeIcon = isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    final flagEmoji = currency.fromCurrency == 'USD' ? '🇺🇸' : '🇪🇺';
    final name = currency.fromCurrency == 'USD' ? 'Dólar Americano' : 'Euro';

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
          Text(flagEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currency.fromCurrency,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
                ),
              ),
              Text(
                name,
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
                'R\$ ${currency.bid.toStringAsFixed(2)}',
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
                      '${currency.pctChange.abs().toStringAsFixed(2)}%',
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
class _IndicatorCard extends StatelessWidget {
  final String name;
  final String description;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool isDark;

  const _IndicatorCard({
    required this.name,
    required this.description,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.isDark,
  });

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
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accentColor, size: 19),
          ),
          const SizedBox(height: 16),
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF86EFAC) : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          // Description
          Text(
            description,
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
class _StockRow extends StatelessWidget {
  final BrapiQuote stock;
  final bool isDark;
  final bool isLast;

  const _StockRow({
    required this.stock,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.regularMarketChangePercent >= 0;
    final changeColor = isPositive
        ? const Color(0xFF4ADE80)
        : Colors.red.shade400;

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
                    stock.symbol,
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
                  stock.shortName,
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
                    'R\$ ${stock.regularMarketPrice.toStringAsFixed(2)}',
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
                        '${isPositive ? '+' : ''}${stock.regularMarketChangePercent.toStringAsFixed(2)}%',
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
