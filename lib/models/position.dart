/// Represents a single position from Kotak Neo API
class Position {
  final String tradingSymbol;
  final int netQty;
  final double avgPrice;
  final double ltp;
  final double unrealisedPnL;
  final double realisedPnL;
  final String product;
  final String exchange;

  Position({
    required this.tradingSymbol,
    required this.netQty,
    required this.avgPrice,
    required this.ltp,
    required this.unrealisedPnL,
    required this.realisedPnL,
    required this.product,
    required this.exchange,
  });

  /// Factory constructor to parse from API JSON
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      tradingSymbol: json['tradingSymbol'] ?? json['trading_symbol'] ?? 'N/A',
      netQty: int.tryParse(json['netQty']?.toString() ?? json['net_qty']?.toString() ?? '0') ?? 0,
      avgPrice: double.tryParse(json['avgPrice']?.toString() ?? json['average_price']?.toString() ?? '0') ?? 0.0,
      ltp: double.tryParse(json['ltp']?.toString() ?? json['last_traded_price']?.toString() ?? '0') ?? 0.0,
      unrealisedPnL: double.tryParse(json['unrealisedPnL']?.toString() ?? json['unrealized_pnl']?.toString() ?? '0') ?? 0.0,
      realisedPnL: double.tryParse(json['realisedPnL']?.toString() ?? json['realized_pnl']?.toString() ?? '0') ?? 0.0,
      product: json['product'] ?? 'MIS',
      exchange: json['exchange'] ?? 'NSE',
    );
  }

  /// Total P&L for this position
  double get totalPnL => unrealisedPnL + realisedPnL;

  /// Is this a long position?
  bool get isLong => netQty > 0;

  /// Is this a short position?
  bool get isShort => netQty < 0;

  /// Absolute quantity
  int get absQty => netQty.abs();

  @override
  String toString() {
    return 'Position($tradingSymbol, Qty: $netQty, P&L: ₹${totalPnL.toStringAsFixed(0)})';
  }
}