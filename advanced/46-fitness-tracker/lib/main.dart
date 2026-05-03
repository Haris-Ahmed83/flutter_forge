// Add these dependencies to your pubspec.yaml file:
// dependencies:
//   flutter:
//     sdk: flutter
//   health: ^6.2.0 # Or the latest version
//   fl_chart: ^0.68.0 # Or the latest version
//   permission_handler: ^11.3.1 # Or the latest version

// IMPORTANT: Platform-specific setup for Health API
// iOS:
// 1. In your `ios/Runner/Info.plist`, add these keys:
//    <key>NSHealthShareUsageDescription</key>
//    <string>We need access to your health data to display your fitness information.</string>
//    <key>NSHealthUpdateUsageDescription</key>
//    <string>We need access to your health data to display your fitness information.</string>
// 2. Enable HealthKit in Xcode: Project Navigator -> Runner -> Signing & Capabilities -> + Capability -> HealthKit.

// Android:
// 1. In your `android/app/src/main/AndroidManifest.xml`, add these permissions inside the `<manifest>` tag:
//    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
//    <uses-permission android:name="android.permission.health.READ_STEPS" />
//    <uses-permission android:name="android.permission.health.READ_HEART_RATE" />
//    <uses-permission android:name="android.permission.health.READ_ACTIVE_ENERGY_BURNED" />
//    <uses-permission android:name="android.permission.health.READ_DISTANCE" />
//    <uses-permission android:name="android.permission.health.READ_SLEEP" />
//    <uses-permission android:name="android.permission.health.READ_WEIGHT" />
// 2. Ensure Google Fit (or equivalent health app) is installed on the device/emulator and has data.
//    On Android 14+, the health connect permissions are more granular. The `health` package handles requesting these.

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart'; // For openAppSettings()

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple, // A vibrant Material 3 color
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const FitnessTrackerHomePage(),
    );
  }
}

class FitnessTrackerHomePage extends StatefulWidget {
  const FitnessTrackerHomePage({super.key});

  @override
  State<FitnessTrackerHomePage> createState() => _FitnessTrackerHomePageState();
}

class _FitnessTrackerHomePageState extends State<FitnessTrackerHomePage> {
  // HealthFactory instance to interact with the Health API
  HealthFactory health = HealthFactory();

  // Lists to store fetched health data points and aggregated statistics
  List<HealthDataPoint> _healthDataList = [];
  Map<HealthDataType, double> _aggregatedData = {};

  // UI state variables
  bool _isLoading = true;
  bool _isAuthorized = false;
  String _statusText = 'Initializing...';
  int _selectedIndex = 0; // For BottomNavigationBar

  // Define the types of health data we want to fetch
  static final List<HealthDataType> _healthDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.SLEEP_ASLEEP, // Example: sleep duration
    HealthDataType.WEIGHT,
  ];

  @override
  void initState() {
    super.initState();
    _initHealthData(); // Start fetching data on app launch
  }

  /// Initializes health data by requesting permissions and then fetching data.
  Future<void> _initHealthData() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Requesting permissions...';
    });

    // Request permissions from the user
    final bool authorized = await _requestPermissions();

    if (authorized) {
      _isAuthorized = true;
      setState(() {
        _statusText = 'Fetching data...';
      });
      await _fetchHealthData(); // Fetch data if authorized
    } else {
      _isAuthorized = false;
      setState(() {
        _isLoading = false;
        _statusText = 'Permissions denied. Cannot fetch health data.';
      });
    }
  }

  /// Requests authorization for the defined health data types.
  Future<bool> _requestPermissions() async {
    // The `health` package handles platform-specific permission requests.
    // It will prompt the user for necessary permissions.
    bool granted = await health.requestAuthorization(_healthDataTypes);
    return granted;
  }

  /// Fetches health data for the last 7 days.
  Future<void> _fetchHealthData() async {
    if (!_isAuthorized) {
      setState(() {
        _isLoading = false;
        _statusText = 'Not authorized to fetch data.';
      });
      return;
    }

    // Define the date range for data retrieval (last 7 days)
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));
    final endDate = now;

    try {
      // Clear previous data before fetching new
      _healthDataList.clear();
      _aggregatedData.clear();

      // Get health data points from the specified types and date range
      final List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        startDate: startDate,
        endDate: endDate,
        types: _healthDataTypes,
      );

      // Filter out duplicate data points and sort by date for consistency
      _healthDataList = HealthFactory.removeDuplicates(healthData);
      _healthDataList.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

      // Aggregate the fetched data for summary display
      _aggregateHealthData(_healthDataList);

      setState(() {
        _isLoading = false;
        _statusText = 'Data fetched successfully.';
      });
    } catch (e) {
      // Handle any errors during data fetching
      setState(() {
        _isLoading = false;
        _statusText = 'Error fetching data: ${e.toString()}';
      });
      debugPrint('Error fetching health data: $e');
    }
  }

  /// Aggregates health data points into a summary map.
  void _aggregateHealthData(List<HealthDataPoint> data) {
    final Map<HealthDataType, double> tempAggregated = {};
    final Map<HealthDataType, int> count = {};

    for (final point in data) {
      final type = point.type;
      final value = point.value;

      // Only process numeric health values for aggregation
      if (value is NumericHealthValue) {
        final double numericValue = value.numericValue;
        tempAggregated[type] = (tempAggregated[type] ?? 0) + numericValue;
        count[type] = (count[type] ?? 0) + 1;
      }
    }

    // Calculate averages for relevant types (e.g., heart rate, weight)
    // Sum for others (e.g., steps, calories)
    for (final type in tempAggregated.keys) {
      if ((type == HealthDataType.HEART_RATE || type == HealthDataType.WEIGHT) &&
          count[type] != null &&
          count[type]! > 0) {
        _aggregatedData[type] = tempAggregated[type]! / count[type]!; // Average
      } else {
        _aggregatedData[type] = tempAggregated[type]!; // Sum
      }
    }
  }

  /// Handles tap events on the bottom navigation bar.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Builds the dashboard tab UI, displaying aggregated stats, a steps chart, and recent data.
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Activity Dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(_statusText),
                    ],
                  ),
                )
              : _isAuthorized
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_healthDataList.isEmpty && _aggregatedData.isEmpty)
                          Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No health data found for the last 7 days. Make sure you have granted permissions and have data in your health app.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                        _buildAggregatedStats(), // Display summary statistics
                        const SizedBox(height: 24),
                        Text(
                          'Daily Steps',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildStepsBarChart(), // Display the steps bar chart
                        const SizedBox(height: 24),
                        Text(
                          'Recent Health Data',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildRecentDataList(), // Display a list of recent data points
                      ],
                    )
                  : Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Health data access denied.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please grant permissions to fetch your fitness data.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final bool granted = await _requestPermissions();
                                if (granted) {
                                  await _initHealthData(); // Re-initialize if permissions are granted
                                } else {
                                  // Optionally, guide user to app settings if permissions are persistently denied
                                  openAppSettings();
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry Permissions'),
                            ),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  /// Builds a grid of aggregated statistics cards.
  Widget _buildAggregatedStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the grid
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Steps (7D)',
          _aggregatedData[HealthDataType.STEPS]?.round().toString() ?? '0',
          Icons.directions_walk,
          Colors.green,
        ),
        _buildStatCard(
          'Avg. Heart Rate',
          _aggregatedData[HealthDataType.HEART_RATE]?.toStringAsFixed(0) ?? '0',
          Icons.favorite,
          Colors.red,
        ),
        _buildStatCard(
          'Calories Burned',
          _aggregatedData[HealthDataType.ACTIVE_ENERGY_BURNED]?.round().toString() ?? '0',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatCard(
          'Distance (km)',
          (_aggregatedData[HealthDataType.DISTANCE_WALKING_RUNNING] != null
                  ? _aggregatedData[HealthDataType.DISTANCE_WALKING_RUNNING]! / 1000
                  : 0)
              .toStringAsFixed(1), // Convert meters to kilometers
          Icons.map,
          Colors.blue,
        ),
      ],
    );
  }

  /// Helper widget to create a single statistical card.
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a bar chart displaying daily step counts.
  Widget _buildStepsBarChart() {
    // Group step data by day
    final Map<DateTime, double> dailySteps = {};
    for (final point in _healthDataList) {
      if (point.type == HealthDataType.STEPS && point.value is NumericHealthValue) {
        // Normalize date to start of day for grouping
        final date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
        dailySteps[date] = (dailySteps[date] ?? 0) + (point.value as NumericHealthValue).numericValue;
      }
    }

    // Prepare data for the `fl_chart` BarChart
    final List<BarChartGroupData> barGroups = [];
    final List<DateTime> sortedDates = dailySteps.keys.toList()..sort();
    double maxY = 0; // To determine the Y-axis scale

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final steps = dailySteps[date] ?? 0;
      maxY = steps > maxY ? steps : maxY; // Update max Y value

      barGroups.add(
        BarChartGroupData(
          x: i, // Use index as X-value for positioning
          barRods: [
            BarChartRodData(
              toY: steps,
              color: Theme.of(context).colorScheme.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    if (barGroups.isEmpty) {
      return Card(
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          alignment: Alignment.center,
          child: Text(
            'No step data available for the last 7 days.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Add some padding to the max Y value for better chart visualization
    maxY = maxY * 1.2;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: SizedBox(
          height: 250, // Fixed height for the chart
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: false, // No border around the chart
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final dateIndex = value.toInt();
                      if (dateIndex >= 0 && dateIndex < sortedDates.length) {
                        final date = sortedDates[dateIndex];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}', // Display day and month
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const Text(''); // Avoid showing max Y-axis label
                      return Text(
                        value.toInt().toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.left,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Theme.of(context).colorScheme.inverseSurface,
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = sortedDates[group.x.toInt()];
                    return BarTooltipItem(
                      '${date.day}/${date.month}\n',
                      TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${rod.toY.round()} steps',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a list of the most recent health data points.
  Widget _buildRecentDataList() {
    if (_healthDataList.isEmpty) {
      return Card(
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Text(
            'No recent detailed health data to display.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the list
        itemCount: _healthDataList.length > 10 ? 10 : _healthDataList.length, // Show up to 10 recent items
        itemBuilder: (context, index) {
          // Display most recent data first
          final data = _healthDataList[_healthDataList.length - 1 - index];
          return Column(
            children: [
              ListTile(
                leading: Icon(_getIconForDataType(data.type), color: Theme.of(context).colorScheme.primary),
                title: Text(
                  '${_getDisplayNameForDataType(data.type)}: ${data.value.toStringAsFixed(data.type == HealthDataType.WEIGHT ? 1 : 0)} ${_getUnitForDataType(data.type)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  '${data.dateFrom.toLocal().toString().split(' ')[0]} - ${data.dateFrom.toLocal().toString().split(' ')[1].substring(0, 5)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              // Add a divider between list items, but not after the last one
              if (index < (_healthDataList.length > 10 ? 9 : _healthDataList.length - 1))
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        },
      ),
    );
  }

  /// Returns an appropriate icon for a given HealthDataType.
  IconData _getIconForDataType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return Icons.directions_walk;
      case HealthDataType.HEART_RATE:
        return Icons.favorite;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return Icons.local_fire_department;
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return Icons.map;
      case HealthDataType.SLEEP_ASLEEP:
        return Icons.bedtime;
      case HealthDataType.WEIGHT:
        return Icons.scale;
      default:
        return Icons.fitness_center;
    }
  }

  /// Returns a user-friendly display name for a given HealthDataType.
  String _getDisplayNameForDataType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'Steps';
      case HealthDataType.HEART_RATE:
        return 'Heart Rate';
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return 'Calories';
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return 'Distance';
      case HealthDataType.SLEEP_ASLEEP:
        return 'Sleep';
      case HealthDataType.WEIGHT:
        return 'Weight';
      default:
        // Fallback for other types, converting enum name to capitalized string
        return type.name.replaceAll('_', ' ').toCapitalized();
    }
  }

  /// Returns the unit of measurement for a given HealthDataType.
  String _getUnitForDataType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'steps';
      case HealthDataType.HEART_RATE:
        return 'bpm';
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return 'kcal';
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return 'm';
      case HealthDataType.SLEEP_ASLEEP:
        return 'min'; // Sleep duration is often in minutes
      case HealthDataType.WEIGHT:
        return 'kg';
      default:
        return '';
    }
  }

  /// Extension method to capitalize the first letter of a string.
  extension StringExtension on String {
    String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  }

  /// Builds the permissions tab UI.
  Widget _buildPermissionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Data Permissions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status: ${_isAuthorized ? 'Authorized' : 'Not Authorized'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _isAuthorized ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app needs access to your health data to track your fitness activities. Please ensure permissions are granted in your device\'s health settings.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Attempt to re-request permissions and re-initialize data
                      await _initHealthData();
                    },
                    icon: const Icon(Icons.privacy_tip),
                    label: const Text('Re-request Permissions'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Open the app's settings page for manual permission adjustment
                      openAppSettings();
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Open App Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Data Types Requested',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _healthDataTypes.length,
              itemBuilder: (context, index) {
                final type = _healthDataTypes[index];
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(_getIconForDataType(type)),
                      title: Text(_getDisplayNameForDataType(type)),
                      subtitle: Text('Unit: ${_getUnitForDataType(type).isEmpty ? 'N/A' : _getUnitForDataType(type)}'),
                    ),
                    if (index < _healthDataTypes.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tracker'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardTab(), // Content for the Dashboard tab
          _buildPermissionsTab(), // Content for the Permissions tab
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Permissions',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible
      ),
    );
  }
}
