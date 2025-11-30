import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:crypto/crypto.dart';

class NeoApiService {
  static const String baseUrl = "https://api.kotaksecurities.com/apim/1.0";
  static const String wsUrl = "wss://ws.kotaksecurities.com/v2";

  final String consumerKey;
  final String mobile;
  final String ucc;
  final String mpin;
  final String totpSecret;

  String? _accessToken;
  WebSocketChannel? _ws;
  Timer? _refreshTimer;

  final _priceController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get priceStream => _priceController.stream;

  NeoApiService({
    required this.consumerKey,
    required this.mobile,
    required this.ucc,
    required this.mpin,
    required this.totpSecret,
  });

  Future<bool> login() async {
    try {
      final totp = _generateTOTP();
      final loginRes = await http.post(
        Uri.parse("$baseUrl/session/totp/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "consumerKey": consumerKey,
          "mobileNumber": mobile,
          "ucc": ucc,
          "totp": totp,
        }),
      );

      if (loginRes.statusCode == 200) {
        final validateRes = await http.post(
          Uri.parse("$baseUrl/session/totp/validate"),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"mpin": mpin}),
        );

        if (validateRes.statusCode == 200) {
          _accessToken = json.decode(validateRes.body)["data"]["accessToken"];
          _startWebSocket();
          _startAutoRefresh();
          return true;
        }
      }
    } catch (e) {
      print("Login failed: $e");
    }
    return false;
  }

  void _startWebSocket() {
    _ws = WebSocketChannel.connect(Uri.parse(wsUrl));
    _ws!.sink.add(json.encode({
      "method": "connect",
      "accessToken": _accessToken,
    }));

    _ws!.stream.listen((data) {
      final msg = json.decode(data);
      if (msg["type"] == "ltp") {
        _priceController.add(msg);
      }
    });
  }

  Future<void> placeOrder({
    required String symbol,
    required int qty,
    required String transactionType,
    required String product, // MIS, NRML, CO, BO
    double slPoints = 0,
    double targetPoints = 0,
  }) async {
    final body = {
      "exchangeSegment": "nse_fo",
      "tradingSymbol": symbol,
      "quantity": qty.toString(),
      "transactionType": transactionType,
      "product": product,
      "orderType": "MKT",
      "validity": "DAY",
      "price": "0",
      "disclosedQuantity": "0",
      "amo": "NO",
    };

    if (product == "CO") {
      body["triggerPrice"] = (slPoints * 1.0).toStringAsFixed(1);
    } else if (product == "BO") {
      body["triggerPrice"] = (slPoints * 1.0).toStringAsFixed(1);
      body["limitPriceTarget"] = (targetPoints * 1.0).toStringAsFixed(1);
    }

    await http.post(
      Uri.parse("$baseUrl/orders/regular"),
      headers: {
        "Authorization": "Bearer $_accessToken",
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );
  }

  String _generateTOTP() {
    final bytes = utf8.encode(totpSecret);
    final hmac = Hmac(sha1, bytes);
    final time = (DateTime.now().millisecondsSinceEpoch ~/ 30000).toRadixString(16).padLeft(16, '0');
    final digest = hmac.convert(hex.decode(time));
    final offset = digest.bytes.last & 0x0f;
    final code = (digest.bytes[offset] & 0x7f) << 24 |
                 (digest.bytes[offset + 1] & 0xff) << 16 |
                 (digest.bytes[offset + 2] & 0xff) << 8 |
                 (digest.bytes[offset + 3] & 0xff);
    return (code % 1000000).toString().padLeft(6, '0');
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(hours: 7), () {
      login(); // Auto re-login
    });
  }

  void dispose() {
    _ws?.sink.close();
    _refreshTimer?.cancel();
    _priceController.close();
  }
}