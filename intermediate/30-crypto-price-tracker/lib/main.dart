import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:intl/intl.dart'; // For currency formatting

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Binance WebSocket API endpoint for real-time trade data.
  // Documentation: https://binance-docs.github.io/apidocs/spot/en/#websocket-market-streams
  final String _binanceWebSocketUrl = 'wss://stream.binance.com:9443/ws';
  WebSocketChannel? _channel;
  final Map<String, CryptoPrice> _cryptoPrices = {}; // Stores latest prices for subscribed symbols.
  // Default list of cryptocurrency symbols to subscribe to.
  final List<String> _subscribedSymbols = ['btcusdt', 'ethusdt', 'bnbusdt', 'solusdt', 'xrpusdt'];
  bool _isConnected = false; // Track WebSocket connection status.

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  // Establishes WebSocket connection and subscribes to symbols.
  void _connectWebSocket() {
    _isConnected = false; // Reset connection status.
    _cryptoPrices.clear(); // Clear old prices on new connection attempt.
    _channel?.sink.close(); // Close any existing channel before connecting.

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_binanceWebSocketUrl));
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true,
      );
      _subscribeToSymbols();
      setState(() {
        _isConnected = true;
      });
      _showSnackBar('Connected to WebSocket.', isError: false);
    } catch (e) {
      // Handle initial connection error.
      _showSnackBar('Failed to connect to WebSocket: $e', isError: true);
      print('WebSocket connection error: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  // Subscribes to the list of predefined crypto symbols.
  void _subscribeToSymbols() {
    if (_channel == null || !_isConnected) return;

    // Binance requires symbols in lowercase and with '@trade' stream suffix.
    final List<String> streams = _subscribedSymbols
        .map((symbol) => '${symbol.toLowerCase()}@trade')
        .toList();

    // Construct the subscription message as per Binance API.
    final Map<String, dynamic> subscribeMessage = {
      "method": "SUBSCRIBE",
      "params": streams,
      "id": 1, // Unique ID for the subscription request.
    };
    _channel!.sink.add(jsonEncode(subscribeMessage));
  }

  // Callback for incoming WebSocket messages.
  void _onData(dynamic data) {
    try {
      final Map<String, dynamic> message = jsonDecode(data);

      // Check if the message is a trade event (Binance specific 'e' field).
      if (message['e'] == 'trade') {
        final String symbol = (message['s'] as String).toUpperCase(); // e.g., "BTCUSDT"
        final double price = double.parse(message['p']); // Latest trade price.

        // Update the state with the new price.
        if (mounted) {
          setState(() {
            _cryptoPrices[symbol] = CryptoPrice(
              symbol: symbol,
              price: price,
              timestamp: DateTime.now(),
            );
          });
        }
      }
    } catch (e) {
      // Handle JSON parsing or data processing errors.
      print('Error parsing WebSocket data: $e, Data: $data');
    }
  }

  // Callback for WebSocket errors.
  void _onError(Object error) {
    _showSnackBar('WebSocket Error: ${error.toString()}', isError: true);
    print('WebSocket Error: $error');
    setState(() {
      _isConnected = false;
    });
    // Attempt to reconnect after an error.
    _reconnectWebSocket();
  }

  // Callback when WebSocket connection is closed.
  void _onDone() {
    _showSnackBar('WebSocket disconnected.', isError: true);
    print('WebSocket disconnected.');
    setState(() {
      _isConnected = false;
    });
    // Attempt to reconnect if disconnected unexpectedly.
    _reconnectWebSocket();
  }

  // Reconnects the WebSocket after a delay.
  void _reconnectWebSocket() {
    if (_channel != null) {
      _channel!.sink.close(); // Close existing connection if any.
    }
    // Wait a bit before trying to reconnect to avoid spamming the server.
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isConnected) { // Ensure widget is still in the tree and not already connected.
        _connectWebSocket();
      }
    });
  }

  // Shows a brief message at the bottom of the screen.
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _channel?.sink.close(); // Close the WebSocket connection when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sort symbols alphabetically for consistent display.
    final List<String> sortedSymbols = _cryptoPrices.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Price Tracker'),
      ),
      body: _isConnected && _cryptoPrices.isEmpty // Show loading if connected but no data yet.
          ? const Center(child: CircularProgressIndicator())
          : !_isConnected && _cryptoPrices.isEmpty // Show error if not connected at all and no data.
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 60, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 24),
                        Text(
                          'Failed to connect to real-time data.',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check your internet connection or try again later.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _connectWebSocket,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Connection'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    // Re-connect and re-subscribe to refresh data.
                    _connectWebSocket();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: sortedSymbols.length,
                    itemBuilder: (context, index) {
                      final String symbol = sortedSymbols[index];
                      final CryptoPrice priceData = _cryptoPrices[symbol]!;
                      return CryptoPriceCard(price: priceData);
                    },
                  ),
                ),
    );
  }
}

// Data model for a cryptocurrency price.
class CryptoPrice {
  final String symbol; // e.g., "BTCUSDT"
  final double price;
  final DateTime timestamp;

  CryptoPrice({
    required this.symbol,
    required this.price,
    required this.timestamp,
  });
}

// Widget to display a single cryptocurrency's price.
class CryptoPriceCard extends StatelessWidget {
  final CryptoPrice price;

  const CryptoPriceCard({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                price.symbol,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(price.price),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated: ${DateFormat.jms().format(price.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
