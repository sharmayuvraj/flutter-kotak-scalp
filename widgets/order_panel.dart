import 'package:flutter/material.dart';

class OrderPanel extends StatefulWidget {
  final NeoApiService api;
  const OrderPanel({super.key, required this.api});

  @override
  State<OrderPanel> createState() => _OrderPanelState();
}

class _OrderPanelState extends State<OrderPanel> {
  String selectedSymbol = "NIFTY 28NOV25 22450 CE";
  int quantity = 25;
  String orderMode = "NORMAL";
  double slPoints = 20.0;
  double targetPoints = 40.0;

  final List<String> symbols = List.generate(20, (i) => "NIFTY 28NOV25 ${22400 + i * 50} CE");

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF121F2E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // CALL Button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, fixedSize: const Size(150, 100)),
            child: const Text('CALL\n(BULL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 30),

          // Instrument
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("INSTRUMENT", style: TextStyle(color: Colors.grey)),
                DropdownButton<String>(
                  value: selectedSymbol,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1C2B3D),
                  items: symbols.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => selectedSymbol = v!),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("QUANTITY", style: TextStyle(color: Colors.grey)),
              Row(
                children: [
                  IconButton(onPressed: () => setState(() => quantity -= 25), icon: const Icon(Icons.remove)),
                  SizedBox(width: 80, child: Text(quantity.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 20))),
                  IconButton(onPressed: () => setState(() => quantity += 25), icon: const Icon(Icons.add)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 40),

          // Order Mode
          Column(
            children: [
              const Text("ORDER TYPE", style: TextStyle(color: Colors.grey)),
              Row(
                children: ["NORMAL", "CO", "BO"].map((mode) {
                  return Row(
                    children: [
                      Radio<String>(value: mode, groupValue: orderMode, onChanged: (v) => setState(() => orderMode = v!)),
                      Text(mode, style: TextStyle(color: mode == orderMode ? Colors.orange : Colors.white)),
                    ],
                  );
                }).toList(),
              ),
              if (orderMode != "NORMAL")
                Row(
                  children: [
                    const Text("SL:"),
                    SizedBox(width: 60, child: TextField(decoration: const InputDecoration(hintText: "20"))),
                    const Text("TGT:"),
                    SizedBox(width: 60, child: TextField(decoration: const InputDecoration(hintText: "40"))),
                  ],
                ),
            ],
          ),
          const Spacer(),

          // BUY & SELL
          Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await widget.api.placeOrder(
                    symbol: selectedSymbol,
                    qty: quantity,
                    transactionType: "B",
                    product: orderMode == "NORMAL" ? "MIS" : orderMode,
                    slPoints: orderMode != "NORMAL" ? slPoints : 0,
                    targetPoints: orderMode == "BO" ? targetPoints : 0,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("BUY $quantity × $selectedSymbol")));
  },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, fixedSize: const Size(180, 90)),
                child: const Text('BUY', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, fixedSize: const Size(180, 90)),
                child: const Text('SELL', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}