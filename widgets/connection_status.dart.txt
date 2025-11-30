import 'package:flutter/material.dart';

class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFF0A1624),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          const Text(
            "Kotak Neo Trade API v2",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              // Login handled in parent
            },
            icon: const Icon(Icons.login),
            label: const Text("LOGIN & CONNECT"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.circle, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          const Text("DISCONNECTED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }
}