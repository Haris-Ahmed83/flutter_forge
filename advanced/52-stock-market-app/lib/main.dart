import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Make sure to add fl_chart to your pubspec.yaml

/// --- Data Models ---

/// Represents a single historical price point for a stock.
class HistoricalPrice {
  final DateTime timestamp;
  final double price;

  HistoricalPrice({required this.timestamp, required this.price});
}

/// Represents a stock with its current status and historical data.
class Stock {
  final String symbol;
  final String name;
  final double currentPrice;
  final double dailyChange; // Absolute change
  final double dailyChangePercentage; // Percentage change
  final List<HistoricalPrice> historicalData;

  Stock({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.dailyChange,
    required this.dailyChangePercentage,
    required this.historicalData,
  });

  /// Creates a copy of the stock with updated values. Used for "live" updates.
  Stock copyWith({
    double? currentPrice,
    double? dailyChange,
    double? dailyChangePercentage,
    List<HistoricalPrice>? historicalData,
  }) {
    return Stock(
      symbol: symbol,
      name: name,
      currentPrice: currentPrice ?? this.currentPrice,
      dailyChange: dailyChange ?? this.dailyChange,
      dailyChangePercentage: dailyChangePercentage ?? this.dailyChangePercentage,
      historicalData: historicalData ?? this.historicalData,
    );
  }
}

/// --- Live Data Service (Simulation) ---

/// A service to simulate live stock data updates.
/// In a real app, this would fetch data from an API.
class StockService {
  // Using a singleton pattern for easy access throughout the app
  static final StockService _instance = StockService._internal();
  factory StockService() => _instance;
  StockService._internal() {
    _initStocks();
    _startLiveUpdates();
  }

  final Random _random = Random();
  late Timer _timer;

  // StreamController for all stocks, used by the home page to update the list
  final _allStocksStreamController = StreamController<List<Stock>>.broadcast();
  Stream<List<Stock>> get allStocksStream => _allStocksStreamController.stream;

  // Map of StreamControllers for individual stock prices, used by detail pages
  final Map<String, StreamController<double>> _livePriceStreamControllers = {};

  // Internal list of stocks
  List<Stock> _stocks = [];

  /// Initializes a list of sample stocks with some historical data.
  void _initStocks() {
    final now = DateTime.now();
    _stocks = [
      _createSampleStock('AAPL', 'Apple Inc.', 170.00, now),
      _createSampleStock('GOOGL', 'Alphabet Inc.', 130.00, now),
      _createSampleStock('MSFT', 'Microsoft Corp.', 350.00, now),
      _createSampleStock('AMZN', 'Amazon.com Inc.', 140.00, now),
      _createSampleStock('TSLA', 'Tesla Inc.', 250.00, now),
    ];

    // Initialize individual price stream controllers for each stock
    for (var stock in _stocks) {
      _livePriceStreamControllers[stock.symbol] = StreamController<double>.broadcast();
    }

    _allStocksStreamController.add(List.from(_stocks)); // Add initial data to the stream
  }

  /// Creates a sample stock with initial price and some generated historical data.
  Stock _createSampleStock(String symbol, String name, double initialPrice, DateTime now) {
    List<HistoricalPrice> history = [];
    double currentPrice = initialPrice;

    // Generate 30 data points for the last hour
    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(minutes: i * 2)); // Every 2 minutes
      currentPrice += (_random.nextDouble() - 0.5) * 2; // Random fluctuation
      history.add(HistoricalPrice(timestamp: timestamp, price: currentPrice.clamp(initialPrice * 0.9, initialPrice * 1.1)));
    }

    final initialDailyChange = (_random.nextDouble() - 0.5) * 5; // Initial random change
    final initialDailyChangePercentage = (initialDailyChange / initialPrice) * 100;

    return Stock(
      symbol: symbol,
      name: name,
      currentPrice: history.last.price,
      dailyChange: initialDailyChange,
      dailyChangePercentage: initialDailyChangePercentage,
      historicalData: history,
    );
  }

  /// Starts a periodic timer to simulate live stock price updates.
  void _startLiveUpdates() {
    // Updates every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateStockPrices();
    });
  }

  /// Updates prices for all stocks randomly and adds new historical data points.
  void _updateStockPrices() {
    final now = DateTime.now();
    _stocks = _stocks.map((stock) {
      final oldPrice = stock.currentPrice;
      // Simulate a small price change
      final priceChange = (_random.nextDouble() - 0.5) * 2; // +/- 1.0
      final newPrice = (oldPrice + priceChange).clamp(stock.historicalData.first.price * 0.8, stock.historicalData.first.price * 1.2);

      final dailyChange = newPrice - stock.historicalData.first.price; // Change from start of "day" (first historical point)
      final dailyChangePercentage = (dailyChange / stock.historicalData.first.price) * 100;

      // Add new historical price point, keeping chart data manageable
      List<HistoricalPrice> newHistory = List.from(stock.historicalData);
      newHistory.add(HistoricalPrice(timestamp: now, price: newPrice));
      if (newHistory.length > 30) {
        newHistory.removeAt(0); // Keep only the last 30 data points for the chart
      }

      final updatedStock = stock.copyWith(
        currentPrice: newPrice,
        dailyChange: dailyChange,
        dailyChangePercentage: dailyChangePercentage,
        historicalData: newHistory,
      );

      // Notify individual stock stream for detail page
      _livePriceStreamControllers[updatedStock.symbol]?.add(updatedStock.currentPrice);

      return updatedStock;
    }).toList();

    // Notify all stocks stream for home page
    _allStocksStreamController.add(List.from(_stocks));
  }

  /// Provides a stream for a specific stock's live price updates.
  Stream<double> getLivePriceStream(String symbol) {
    return _livePriceStreamControllers[symbol]?.stream ?? const Stream.empty();
  }

  /// Cleans up resources when the service is no longer needed.
  void dispose() {
    _timer.cancel();
    _allStocksStreamController.close();
    _livePriceStreamControllers.forEach((_, controller) => controller.close());
  }
}

/// --- Main Application Widgets ---

void main() {
  // Ensure the StockService is initialized when the app starts.
  // We don't need to hold a reference as it's a singleton.
  StockService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Market App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          surfaceTintColor: Colors.transparent, // Prevents white tint on scroll
        ),
      ),
      home: const StockMarketHomePage(),
    );
  }
}

/// --- Stock List Page ---

class StockMarketHomePage extends StatefulWidget {
  const StockMarketHomePage({super.key});

  @override
  State<StockMarketHomePage> createState() => _StockMarketHomePageState();
}

class _StockMarketHomePageState extends State<StockMarketHomePage> {
  final StockService _stockService = StockService();

  @override
  void dispose() {
    // In a real app, if StockService wasn't a singleton, we'd dispose it here.
    // Since it's a singleton and meant to live for the app's lifetime, we don't dispose it here.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Market'),
      ),
      body: StreamBuilder<List<Stock>>(
        stream: _stockService.allStocksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stocks available.'));
          }

          final stocks = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: stocks.length,
            separatorBuilder: (context, index) => const Divider(height: 24.0),
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return StockTile(stock: stock);
            },
          );
        },
      ),
    );
  }
}

/// Displays a summary of a single stock.
class StockTile extends StatelessWidget {
  final Stock stock;

  const StockTile({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = stock.dailyChange >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailPage(stock: stock),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    stock.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${stock.currentPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Icon(changeIcon, color: changeColor, size: 16),
                    const SizedBox(width: 4.0),
                    Text(
                      '${stock.dailyChange.toStringAsFixed(2)} '
                      '(${stock.dailyChangePercentage.toStringAsFixed(2)}%)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// --- Stock Detail Page ---

/// Displays detailed information for a single stock, including a live chart.
class StockDetailPage extends StatefulWidget {
  final Stock stock;

  const StockDetailPage({super.key, required this.stock});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  final StockService _stockService = StockService();
  late Stock _currentStock; // Holds the latest data for the stock, including historical.

  @override
  void initState() {
    super.initState();
    _currentStock = widget.stock;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = _currentStock.dailyChange >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stock.symbol),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.stock.name,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // Live price stream for the current stock
            StreamBuilder<double>(
              stream: _stockService.getLivePriceStream(widget.stock.symbol),
              builder: (context, snapshot) {
                // Update _currentStock's price for display and chart rebuilding
                if (snapshot.hasData && snapshot.data != _currentStock.currentPrice) {
                  // Find the stock from the service's current list to get all its updated data.
                  // This is important because the historical data also updates.
                  final latestStockData = _stockService._stocks.firstWhere(
                    (s) => s.symbol == widget.stock.symbol,
                    orElse: () => _currentStock, // Fallback if not found (shouldn't happen)
                  );
                  _currentStock = latestStockData;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${_currentStock.currentPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(changeIcon, color: changeColor, size: 24),
                        const SizedBox(width: 8.0),
                        Text(
                          '${_currentStock.dailyChange.toStringAsFixed(2)} '
                          '(${_currentStock.dailyChangePercentage.toStringAsFixed(2)}%)',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Today', // In a real app, this would be based on actual market hours
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24.0),
            Text(
              'Price History (Last Hour)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 250, // Fixed height for the chart
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: _buildLineChart(_currentStock.historicalData),
            ),
            const SizedBox(height: 24.0),
            // Additional details could go here
            Text(
              'About ${widget.stock.name}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Market Cap: \$2.8 Trillion', // Sample data
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'P/E Ratio: 29.5x', // Sample data
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the LineChart widget using fl_chart.
  Widget _buildLineChart(List<HistoricalPrice> historicalData) {
    if (historicalData.isEmpty) {
      return const Center(child: Text('No historical data available.'));
    }

    // Convert HistoricalPrice data to FlSpot for the chart
    final List<FlSpot> spots = historicalData.map((hp) {
      // Use millisecondsSinceEpoch as the x-axis value for DateTime
      return FlSpot(hp.timestamp.millisecondsSinceEpoch.toDouble(), hp.price);
    }).toList();

    // Determine min/max Y values for chart scaling
    final double minY = spots.map((spot) => spot.y).reduce(min) * 0.95;
    final double maxY = spots.map((spot) => spot.y).reduce(max) * 1.05;

    // Determine min/max X values for chart scaling
    final double minX = spots.map((spot) => spot.x).reduce(min);
    final double maxX = spots.map((spot) => spot.x).reduce(max);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // Convert x-axis value (millisecondsSinceEpoch) back to DateTime
                final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                // Display time in HH:mm format
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10),
                  ),
                );
              },
              interval: (maxX - minX) / 4, // Show about 4 labels
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                // Display price labels on the Y-axis
                return Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10),
                  textAlign: TextAlign.left,
                );
              },
              interval: (maxY - minY) / 3, // Show about 3 labels
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), width: 1),
        ),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.6),
                Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false), // Hide individual data points
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final dateTime = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                return LineTooltipItem(
                  '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}\n'
                  '\$${touchedSpot.y.toStringAsFixed(2)}',
                  TextStyle(color: Theme.of(context).colorScheme.surface),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}
