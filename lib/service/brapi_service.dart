import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/brapi_models.dart';

class BrapiService {
  static final BrapiService _instance = BrapiService._internal();
  factory BrapiService() => _instance;
  BrapiService._internal();

  final _baseUrl = 'https://brapi.dev/api';
  
  // Cache mechanism
  BrapiMarketData? _cachedData;
  DateTime? _lastFetch;
  final Duration _cacheDuration = const Duration(minutes: 10);

  String get _token => dotenv.get('BRAPI_TOKEN', fallback: '');

  Future<BrapiMarketData> fetchAllData() async {
    final now = DateTime.now();

    print('DEBUG: Inicia busca na BRAPI. Token carregado: ${_token.isNotEmpty}');
    if (_token.isEmpty) {
      print('DEBUG ERROR: BRAPI_TOKEN está vazio no .env');
    }

    // Return cached data if valid
    if (_cachedData != null && _lastFetch != null) {
      if (now.difference(_lastFetch!) < _cacheDuration) {
        print('DEBUG: Usando cache (última carga há ${now.difference(_lastFetch!).inSeconds}s)');
        return _cachedData!;
      }
    }

    try {
      print('DEBUG: Buscando dados do Radar...');
      final results = await Future.wait([
        _safeRequest<List<BrapiQuote>>(
          label: 'Stocks',
          request: () => _fetchStocks(['PETR4', 'VALE3', 'ITUB4', 'MGLU3']),
          fallback: _fallbackStocks(),
        ),
        _safeRequest<List<BrapiCurrency>>(
          label: 'Currencies',
          request: () => _fetchCurrencies(['USD-BRL', 'EUR-BRL']),
          fallback: _fallbackCurrencies(),
        ),
        _safeRequest<List<BrapiIndicator>>(
          label: 'Selic',
          request: () => _fetchIndicator('prime-rate', country: 'brazil'),
          fallback: _fallbackSelic(),
        ),
        _safeRequest<List<BrapiIndicator>>(
          label: 'IPCA',
          request: () => _fetchIndicator('inflation', country: 'brazil'),
          fallback: _fallbackIpca(),
        ),
      ]);

      print('DEBUG: Todas requisições concluídas com sucesso');

      final data = BrapiMarketData(
        stocks: (results[0] as List<dynamic>).cast<BrapiQuote>(),
        currencies: (results[1] as List<dynamic>).cast<BrapiCurrency>(),
        selic: (results[2] as List<dynamic>).cast<BrapiIndicator>().firstOrNull,
        ipca: (results[3] as List<dynamic>).cast<BrapiIndicator>().firstOrNull,
        timestamp: now,
      );

      // Update cache
      _cachedData = data;
      _lastFetch = now;

      return data;
    } catch (e) {
      print('DEBUG ERROR: Falha na BrapiService: $e');
      // If error occurs and we have a valid cache (even if old), return it
      if (_cachedData != null) {
        print('DEBUG: Retornando cache antigo devido a erro');
        return _cachedData!;
      }
      rethrow;
    }
  }

  Future<T> _safeRequest<T>({
    required String label,
    required Future<T> Function() request,
    required T fallback,
  }) async {
    try {
      return await request();
    } catch (e) {
      print('DEBUG WARN [$label]: $e');
      return fallback;
    }
  }

  Future<List<BrapiQuote>> _fetchStocks(List<String> tickers) async {
    final tickersStr = tickers.join(',');
    final url = Uri.parse('$_baseUrl/quote/$tickersStr?token=$_token');
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.map((j) => BrapiQuote.fromJson(j)).toList();
    } else {
      print('DEBUG ERROR [Stocks]: Status ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load quotes: ${response.statusCode}');
    }
  }

  Future<List<BrapiCurrency>> _fetchCurrencies(List<String> pairs) async {
    final pairsStr = pairs.join(',');
    final url = Uri.parse('https://economia.awesomeapi.com.br/json/last/$pairsStr');
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<BrapiCurrency> currencies = [];

      final usd = data['USDBRL'];
      if (usd != null) {
        currencies.add(
          BrapiCurrency(
            fromCurrency: usd['code']?.toString() ?? 'USD',
            toCurrency: usd['codein']?.toString() ?? 'BRL',
            bid: double.tryParse(usd['bid']?.toString() ?? '0') ?? 0,
            pctChange: double.tryParse(usd['pctChange']?.toString() ?? '0') ?? 0,
          ),
        );
      }

      final eur = data['EURBRL'];
      if (eur != null) {
        currencies.add(
          BrapiCurrency(
            fromCurrency: eur['code']?.toString() ?? 'EUR',
            toCurrency: eur['codein']?.toString() ?? 'BRL',
            bid: double.tryParse(eur['bid']?.toString() ?? '0') ?? 0,
            pctChange: double.tryParse(eur['pctChange']?.toString() ?? '0') ?? 0,
          ),
        );
      }

      return currencies;
    } else {
      print('DEBUG ERROR [Currencies]: Status ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load currencies: ${response.statusCode}');
    }
  }

  Future<List<BrapiIndicator>> _fetchIndicator(String type, {String? country}) async {
    final String seriesCode;
    if (type == 'prime-rate') {
      seriesCode = '432'; // Selic anual
    } else if (type == 'inflation') {
      seriesCode = '433'; // IPCA mensal
    } else {
      throw Exception('Indicador não suportado: $type');
    }

    final url = Uri.parse(
      'https://api.bcb.gov.br/dados/serie/bcdata.sgs.$seriesCode/dados/ultimos/1?formato=json',
    );
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      if (data.isEmpty) return [];

      final raw = data.first as Map<String, dynamic>;
      final value = double.tryParse(
            (raw['valor']?.toString() ?? '0').replaceAll(',', '.'),
          ) ??
          0;

      return [
        BrapiIndicator(
          value: value,
          date: raw['data']?.toString() ?? '',
        ),
      ];
    } else {
      print('DEBUG ERROR [$type]: Status ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load $type: ${response.statusCode}');
    }
  }

  List<BrapiQuote> _fallbackStocks() {
    return [];
  }

  List<BrapiCurrency> _fallbackCurrencies() {
    return [];
  }

  List<BrapiIndicator> _fallbackSelic() {
    return [];
  }

  List<BrapiIndicator> _fallbackIpca() {
    return [];
  }

  void clearCache() {
    _cachedData = null;
    _lastFetch = null;
  }
}

extension FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
