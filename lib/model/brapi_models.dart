class BrapiQuote {
  final String symbol;
  final String shortName;
  final double regularMarketPrice;
  final double regularMarketChangePercent;
  final String? logourl;

  BrapiQuote({
    required this.symbol,
    required this.shortName,
    required this.regularMarketPrice,
    required this.regularMarketChangePercent,
    this.logourl,
  });

  factory BrapiQuote.fromJson(Map<String, dynamic> json) {
    return BrapiQuote(
      symbol: json['symbol'] ?? '',
      shortName: json['shortName'] ?? '',
      regularMarketPrice: (json['regularMarketPrice'] ?? 0.0).toDouble(),
      regularMarketChangePercent: (json['regularMarketChangePercent'] ?? 0.0).toDouble(),
      logourl: json['logourl'],
    );
  }
}

class BrapiCurrency {
  final String fromCurrency;
  final String toCurrency;
  final double bid;
  final double pctChange;

  BrapiCurrency({
    required this.fromCurrency,
    required this.toCurrency,
    required this.bid,
    required this.pctChange,
  });

  factory BrapiCurrency.fromJson(Map<String, dynamic> json) {
    return BrapiCurrency(
      fromCurrency: json['fromCurrency'] ?? '',
      toCurrency: json['toCurrency'] ?? '',
      bid: double.tryParse(json['bid']?.toString() ?? '0.0') ?? 0.0,
      pctChange: double.tryParse(json['pctChange']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class BrapiIndicator {
  final double value;
  final String date;

  BrapiIndicator({
    required this.value,
    required this.date,
  });

  factory BrapiIndicator.fromJson(Map<String, dynamic> json) {
    return BrapiIndicator(
      value: (json['value'] ?? 0.0).toDouble(),
      date: json['date'] ?? '',
    );
  }
}

class BrapiMarketData {
  final List<BrapiQuote> stocks;
  final List<BrapiCurrency> currencies;
  final BrapiIndicator? selic;
  final BrapiIndicator? ipca;
  final DateTime timestamp;

  BrapiMarketData({
    required this.stocks,
    required this.currencies,
    this.selic,
    this.ipca,
    required this.timestamp,
  });
}
