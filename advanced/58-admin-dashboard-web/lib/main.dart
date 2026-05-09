import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Required for web scroll behavior

void main() {
  runApp(const MyApp());
}

// --- Global Constants and Theme ---

const double kDesktopBreakpoint = 1000.0;
const double kTabletBreakpoint = 600.0;
const double kSidebarWidth = 250.0;
const double kCardPadding = 16.0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
          secondary: Colors.teal, // Example secondary color for accent
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Custom scroll behavior for web to allow drag scrolling with mouse
        // ignore: deprecated_member_use
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// --- Data Models ---

class SalesData {
  final String month;
  final double sales;
  SalesData(this.month, this.sales);
}

class TrafficData {
  final String source;
  final double value;
  final Color color;
  TrafficData(this.source, this.value, this.color);
}

class Order {
  final String id;
  final String customer;
  final double amount;
  final String status;
  Order(this.id, this.customer, this.amount, this.status);
}

class User {
  final String name;
  final String email;
  final String role;
  final bool active;
  User(this.name, this.email, this.role, this.active);
}

// --- Sample Data ---

final List<SalesData> sampleSalesData = [
  SalesData('Jan', 20000),
  SalesData('Feb', 22000),
  SalesData('Mar', 25000),
  SalesData('Apr', 23000),
  SalesData('May', 28000),
  SalesData('Jun', 30000),
  SalesData('Jul', 27000),
  SalesData('Aug', 32000),
  SalesData('Sep', 35000),
  SalesData('Oct', 33000),
  SalesData('Nov', 38000),
  SalesData('Dec', 40000),
];

final List<TrafficData> sampleTrafficData = [
  TrafficData('Direct', 30, Colors.blue.shade400),
  TrafficData('Search', 45, Colors.green.shade400),
  TrafficData('Social', 15, Colors.orange.shade400),
  TrafficData('Referral', 10, Colors.red.shade400),
];

final List<Order> sampleOrders = [
  Order('ORD001', 'Alice Johnson', 120.50, 'Completed'),
  Order('ORD002', 'Bob Smith', 75.00, 'Pending'),
  Order('ORD003', 'Charlie Brown', 300.25, 'Completed'),
  Order('ORD004', 'Diana Prince', 50.00, 'Cancelled'),
  Order('ORD005', 'Eve Adams', 180.75, 'Processing'),
  Order('ORD006', 'Frank White', 99.99, 'Completed'),
  Order('ORD007', 'Grace Kelly', 210.00, 'Pending'),
];

final List<User> sampleUsers = [
  User('Admin User', 'admin@example.com', 'Admin', true),
  User('Jane Doe', 'jane@example.com', 'Editor', true),
  User('John Smith', 'john@example.com', 'Viewer', false),
  User('Sarah Lee', 'sarah@example.com', 'Editor', true),
  User('Mike Ross', 'mike@example.com', 'Viewer', true),
];

// --- Dashboard Screen (Main Layout) ---

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Current selected navigation item

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    return Scaffold(
      appBar: isDesktop
          ? null // No AppBar on desktop, sidebar takes its place
          : AppBar(
              title: const Text('Admin Dashboard'),
              centerTitle: false,
            ),
      drawer: isDesktop
          ? null // No Drawer on desktop
          : _DashboardSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                Navigator.pop(context); // Close drawer on item tap
              },
            ),
      body: Row(
        children: [
          if (isDesktop)
            _DashboardSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          Expanded(
            child: _MainContentArea(
              selectedIndex: _selectedIndex,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Dashboard Sidebar (Navigation) ---

class _DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _DashboardSidebar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceVariant,
      child: SizedBox(
        width: kSidebarWidth,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Text(
                'Admin Panel',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildSidebarItem(
                    context,
                    0,
                    Icons.dashboard_rounded,
                    'Overview',
                  ),
                  _buildSidebarItem(
                    context,
                    1,
                    Icons.analytics_rounded,
                    'Analytics',
                  ),
                  _buildSidebarItem(
                    context,
                    2,
                    Icons.people_alt_rounded,
                    'Users',
                  ),
                  _buildSidebarItem(
                    context,
                    3,
                    Icons.shopping_cart_rounded,
                    'Orders',
                  ),
                  _buildSidebarItem(
                    context,
                    4,
                    Icons.settings_rounded,
                    'Settings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, int index, IconData icon, String title) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.5),
      onTap: () => onItemSelected(index),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}

// --- Main Content Area (Dashboard Widgets) ---

class _MainContentArea extends StatelessWidget {
  final int selectedIndex; // For future content switching, currently unused for simplicity

  const _MainContentArea({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    // For a single-file, simple dashboard, we'll just show all content regardless of selectedIndex.
    // In a real app, you'd use an IndexedStack or similar to switch content based on selectedIndex.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 24),
          _ResponsiveGrid(
            children: [
              _InfoCard(
                title: 'Total Sales',
                value: '\$1.2M',
                icon: Icons.monetization_on_rounded,
                color: Colors.green.shade400,
              ),
              _InfoCard(
                title: 'New Users',
                value: '2,500',
                icon: Icons.person_add_alt_rounded,
                color: Colors.blue.shade400,
              ),
              _InfoCard(
                title: 'Pending Orders',
                value: '12',
                icon: Icons.pending_actions_rounded,
                color: Colors.orange.shade400,
              ),
              _InfoCard(
                title: 'Website Visits',
                value: '150K',
                icon: Icons.visibility_rounded,
                color: Colors.purple.shade400,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ResponsiveGrid(
            children: [
              _DashboardCard(
                title: 'Sales Performance',
                child: _SalesLineChart(
                  data: sampleSalesData,
                  lineColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              _DashboardCard(
                title: 'Traffic Sources',
                child: _TrafficBarChart(
                  data: sampleTrafficData,
                ),
              ),
              _DashboardCard(
                title: 'Recent Orders',
                child: _RecentOrdersTable(orders: sampleOrders),
              ),
              _DashboardCard(
                title: 'Top Users',
                child: _TopUsersTable(users: sampleUsers),
              ),
            ],
          ),
          const SizedBox(height: 24), // Ensure bottom spacing
        ],
      ),
    );
  }
}

// --- Responsive Grid Layout ---

class _ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on screen width
        int crossAxisCount;
        if (constraints.maxWidth >= kDesktopBreakpoint) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= kTabletBreakpoint) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true, // Important for nested scroll views
          physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: kCardPadding,
            mainAxisSpacing: kCardPadding,
            childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.5, // Adjust aspect ratio for mobile
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

// --- Reusable Dashboard Card ---

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;

  const _DashboardCard({
    required this.title,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded( // Use Expanded to ensure child takes available space
              child: SizedBox(
                height: height, // Height can be constrained if explicitly passed
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Info Card (Small Stat Cards) ---

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(kCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Custom Charts (using CustomPainter) ---
// These charts are implemented using CustomPainter to avoid external dependencies
// and adhere to the single-file requirement, demonstrating chart capabilities.

// Line Chart
class _SalesLineChart extends StatelessWidget {
  final List<SalesData> data;
  final Color lineColor;

  const _SalesLineChart({
    required this.data,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _LineChartPainter(
            data: data,
            lineColor: lineColor,
            gridColor: Theme.of(context).colorScheme.outlineVariant,
            labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<SalesData> data;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;

  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double padding = 30.0; // Padding for labels and axes
    final double chartWidth = size.width - 2 * padding;
    final double chartHeight = size.height - 2 * padding;

    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    final double maxSales = data.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
    final double minSales = data.map((e) => e.sales).reduce((a, b) => a < b ? a : b);
    final double salesRange = maxSales - minSales;
    
    // Handle case where all sales are the same to prevent division by zero
    final double effectiveSalesRange = salesRange == 0 ? 1 : salesRange; 
    final double effectiveMinSales = salesRange == 0 ? minSales - (minSales * 0.1).clamp(100.0, double.infinity) : minSales;

    // Draw X-axis labels (months)
    final double xStep = chartWidth / (data.length - 1).clamp(1.0, data.length.toDouble()); // Ensure at least 1 for division
    for (int i = 0; i < data.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].month,
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
          canvas, Offset(padding + i * xStep - textPainter.width / 2, size.height - padding + 5));
    }

    // Draw Y-axis labels (sales values) and horizontal grid lines
    final int numYLabels = 5;
    for (int i = 0; i <= numYLabels; i++) {
      final double yValue = effectiveMinSales + (effectiveSalesRange / numYLabels) * i;
      final String label = '\$${(yValue / 1000).toStringAsFixed(0)}K';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final double y = padding + chartHeight - (yValue - effectiveMinSales) / effectiveSalesRange * chartHeight;
      textPainter.paint(canvas, Offset(padding - textPainter.width - 5, y - textPainter.height / 2));

      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), gridPaint);
    }

    // Draw data line
    final Path path = Path();
    for (int i = 0; i < data.length; i++) {
      final double x = padding + i * xStep;
      final double y = padding + chartHeight - (data[i].sales - effectiveMinSales) / effectiveSalesRange * chartHeight;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}

// Bar Chart
class _TrafficBarChart extends StatelessWidget {
  final List<TrafficData> data;

  const _TrafficBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _BarChartPainter(
            data: data,
            gridColor: Theme.of(context).colorScheme.outlineVariant,
            labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<TrafficData> data;
  final Color gridColor;
  final Color labelColor;

  _BarChartPainter({
    required this.data,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double padding = 30.0;
    final double chartWidth = size.width - 2 * padding;
    final double chartHeight = size.height - 2 * padding;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    final double maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final double effectiveMaxValue = maxValue == 0 ? 1 : maxValue; // Prevent division by zero

    // Draw Y-axis labels and grid lines
    final int numYLabels = 5;
    for (int i = 0; i <= numYLabels; i++) {
      final double yValue = (effectiveMaxValue / numYLabels) * i;
      final String label = '${yValue.toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final double y = padding + chartHeight - (yValue / effectiveMaxValue) * chartHeight;
      textPainter.paint(canvas, Offset(padding - textPainter.width - 5, y - textPainter.height / 2));

      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), gridPaint);
    }

    // Draw bars and X-axis labels
    final double barCount = data.length.toDouble();
    final double totalBarWidthFraction = 0.7; // Fraction of available space for bars
    final double totalGapWidthFraction = 1.0 - totalBarWidthFraction;

    final double spacePerBar = chartWidth / barCount;
    final double barWidth = spacePerBar * totalBarWidthFraction;
    final double gapBetweenBars = spacePerBar * totalGapWidthFraction / (barCount > 1 ? (barCount - 1) : 1);
    
    double currentX = padding + (spacePerBar - barWidth) / 2; // Start X for the first bar

    for (int i = 0; i < data.length; i++) {
      final double barHeight = (data[i].value / effectiveMaxValue) * chartHeight;
      final Rect barRect = Rect.fromLTWH(
        currentX,
        padding + chartHeight - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRect(barRect, Paint()..color = data[i].color);

      // Draw X-axis label
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].source,
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
          canvas, Offset(currentX + barWidth / 2 - textPainter.width / 2, size.height - padding + 5));

      currentX += spacePerBar; // Move to the next bar's starting position
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}

// --- Tables ---

class _RecentOrdersTable extends StatelessWidget {
  final List<Order> orders;

  const _RecentOrdersTable({required this.orders});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Allow horizontal scrolling for table
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Order ID')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
        ],
        rows: orders
            .map(
              (order) => DataRow(cells: [
                DataCell(Text(order.id)),
                DataCell(Text(order.customer)),
                DataCell(Text('\$${order.amount.toStringAsFixed(2)}')),
                DataCell(
                  _StatusChip(status: order.status),
                ),
              ]),
            )
            .toList(),
      ),
    );
  }
}

class _TopUsersTable extends StatelessWidget {
  final List<User> users;

  const _TopUsersTable({required this.users});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Active')),
        ],
        rows: users
            .map(
              (user) => DataRow(cells: [
                DataCell(Text(user.name)),
                DataCell(Text(user.email)),
                DataCell(Text(user.role)),
                DataCell(
                  Icon(
                    user.active ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: user.active ? Colors.green : Colors.red,
                  ),
                ),
              ]),
            )
            .toList(),
      ),
    );
  }
}

// --- Helper Widgets ---

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    switch (status) {
      case 'Completed':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Pending':
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'Processing':
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'Cancelled':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        chipColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
