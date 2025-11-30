import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/position.dart';
import '../services/neo_api_service.dart';

class PositionsTable extends StatefulWidget {
  final NeoApiService api;
  const PositionsTable({super.key, required this.api});

  @override
  State<PositionsTable> createState() => _PositionsTableState();
}

class _PositionsTableState extends State<PositionsTable> {
  List<Position> positions = [];
  double dayPnL = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchPositions());
    _fetchPositions(); // Initial load
  }

  Future<void> _fetchPositions() async {
    if (widget.api._accessToken == null) return;

    try {
      final response = await http.get(
        Uri.parse("https://api.kotaksecurities.com/apim/1.0/positions"),
        headers: {"Authorization": "Bearer ${widget.api._accessToken}"},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final rawList = jsonData['data'] as List? ?? [];

        final List<Position> parsed = rawList.map((item) => Position.fromJson(item)).toList();
        final totalPnL = parsed.fold<double>(0.0, (sum, p) => sum + p.totalPnL);

        setState(() {
          positions = parsed.where((p) => p.netQty != 0).toList();
          dayPnL = totalPnL;
        });
      }
    } catch (e) {
      // Silent fail - API might be rate-limited
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121F2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // P&L Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F1E2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text(
                  "DAY P&L: ₹${dayPnL.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: dayPnL >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _exitAll(),
                  icon: const Icon(Icons.close),
                  label: const Text("EXIT ALL", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ),

          // Positions Table
          Expanded(
            child: positions.isEmpty
                ? const Center(child: Text("No open positions", style: TextStyle(fontSize: 18, color: Colors.grey)))
                : SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 56,
                      dataRowHeight: 64,
                      headingRowColor: MaterialStateProperty.all(const Color(0xFF1A2330)),
                      columns: const [
                        DataColumn(label: Text("Symbol", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        DataColumn(label: Text("Qty")),
                        DataColumn(label: Text("Avg")),
                        DataColumn(label: Text("LTP")),
                        DataColumn(label: Text("P&L")),
                        DataColumn(label: Text("Type")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows: positions.map((pos) {
                        return DataRow(
                          color: MaterialStateProperty.all(pos.isLong ? const Color(0xFF10291E) : const Color(0xFF2A1010)),
                          cells: [
                            DataCell(Text(pos.tradingSymbol, style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(Text(pos.netQty.toString(), style: TextStyle(color: pos.isLong ? Colors.green : Colors.red))),
                            DataCell(Text(pos.avgPrice.toStringAsFixed(2))),
                            DataCell(Text(pos.ltp.toStringAsFixed(2))),
                            DataCell(Text(
                              "₹${pos.totalPnL.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: pos.totalPnL >= 0 ? Colors.green : Colors.red,
                              ),
                            )),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: pos.product == "BO" ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(pos.product, style: const TextStyle(fontSize: 12)),
                            )),
                            DataCell(ElevatedButton(
                              onPressed: () => _exitPosition(pos),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 16)),
                              child: const Text("EXIT", style: TextStyle(fontSize: 12)),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _exitPosition(Position pos) async {
    try {
      await widget.api.placeOrder(
        symbol: pos.tradingSymbol,
        qty: pos.absQty,
        transactionType: pos.isLong ? "S" : "B",
        product: pos.product,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exit order placed: ${pos.tradingSymbol}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exit failed")));
    }
  }

  void _exitAll() {
    for (var pos in positions) {
      _exitPosition(pos);
    }
  }
}