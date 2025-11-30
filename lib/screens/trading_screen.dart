import 'package:flutter/material.dart';
import '../services/neo_api_service.dart';
import '../widgets/order_panel.dart';
import '../widgets/positions_table.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  final api = NeoApiService(
    consumerKey: "YOUR_CONSUMER_KEY",
    mobile: "+91XXXXXXXXXX",
    ucc: "YOUR_UCC",
    mpin: "YOUR_MPIN",
    totpSecret: "YOUR_TOTP_SECRET",
  );

  bool isConnected = false;
  double niftyPrice = 22450.20;

  @override
  void initState() {
    super.initState();
    api.priceStream.listen((data) {
      if (data["ts"]?.contains("NIFTY") == true) {
        setState(() => niftyPrice = double.tryParse(data["lp"]) ?? niftyPrice);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Status Bar
          Container(
            height: 70,
            color: const Color(0xFF0A1624),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                const Text("Kotak Neo Pro Terminal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final success = await api.login();
                    setState(() => isConnected = success);
                  },
                  child: Text(isConnected ? "CONNECTED" : "LOGIN"),
                ),
                const SizedBox(width: 20),
                Icon(Icons.circle, color: isConnected ? Colors.green : Colors.red, size: 16),
              ],
            ),
          ),

          // Header
          Container(
            height: 80,
            color: const Color(0xFF0F1E2E),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                const Text("NeoScalp Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 20),
                const Text("NIFTY 50", style: TextStyle(fontSize: 18)),
                const Spacer(),
                Text(niftyPrice.toStringAsFixed(2), style: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(width: 200),
              ],
            ),
          ),

          Expanded(child: OrderPanel(api: api)),
          Expanded(child: PositionsTable(api: api)),
        ],
      ),
    );
  }
}