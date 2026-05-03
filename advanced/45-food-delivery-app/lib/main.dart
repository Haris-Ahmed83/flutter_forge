import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs for orders

// --- 1. Models ---

/// Represents a single food item available for purchase.
class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}

/// Represents an item within the shopping cart.
class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({required this.foodItem, this.quantity = 1});

  // Calculates the total price for this cart item (price * quantity).
  double get totalPrice => foodItem.price * quantity;
}

/// Represents a customer's placed order.
class Order {
  final String id;
  final List<CartItem> items; // Snapshot of items at the time of order
  final double total;
  final DateTime timestamp;
  final OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.timestamp,
    this.status = OrderStatus.pending,
  });
}

/// Possible statuses for an order.
enum OrderStatus {
  pending,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

// --- 2. Providers (State Management) ---

/// Manages the state of the shopping cart.
class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  // Calculates the total price of all items in the cart.
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Returns the total number of *distinct* items in the cart.
  int get itemCount => _cartItems.length;

  /// Adds a [foodItem] to the cart. If the item already exists, its quantity is incremented.
  void addItem(FoodItem foodItem) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );

    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity++;
    } else {
      _cartItems.add(CartItem(foodItem: foodItem));
    }
    notifyListeners();
  }

  /// Removes a [foodItem] from the cart. If quantity is > 1, it's decremented; otherwise, the item is removed.
  void removeItem(FoodItem foodItem) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );

    if (existingItemIndex != -1) {
      if (_cartItems[existingItemIndex].quantity > 1) {
        _cartItems[existingItemIndex].quantity--;
      } else {
        _cartItems.removeAt(existingItemIndex);
      }
    }
    notifyListeners();
  }

  /// Clears all items from the cart.
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

/// Manages the state of placed orders.
class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];
  final Uuid _uuid = const Uuid(); // For generating unique order IDs

  List<Order> get orders => List.unmodifiable(_orders);

  /// Places a new order with the given [items] and [total].
  void placeOrder(List<CartItem> items, double total) {
    if (items.isEmpty) return;

    final newOrder = Order(
      id: _uuid.v4(), // Generate a unique ID for the order
      items: List.of(items.map((e) => CartItem(foodItem: e.foodItem, quantity: e.quantity))), // Deep copy cart items
      total: total,
      timestamp: DateTime.now(),
    );
    _orders.insert(0, newOrder); // Add to the beginning for most recent orders first
    notifyListeners();
  }
}

// --- 3. Sample Data ---

final List<FoodItem> sampleFoodItems = [
  const FoodItem(
    id: 'p1',
    name: 'Classic Burger',
    description: 'A juicy beef patty with lettuce, tomato, onion, and pickles on a toasted bun.',
    price: 12.99,
    imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?q=80&w=2072&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    category: 'Burgers',
  ),
  const FoodItem(
    id: 'p2',
    name: 'Margherita Pizza',
    description: 'Classic pizza with tomato sauce, fresh mozzarella, and basil.',
    price: 15.50,
    imageUrl: 'https://images.unsplash.com/photo-1593560704563-f17a62ba817e?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    category: 'Pizza',
  ),
  const FoodItem(
    id: 'p3',
    name: 'Caesar Salad',
    description: 'Fresh romaine lettuce, croutons, parmesan cheese, and Caesar dressing.',
    price: 9.75,
    imageUrl: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    category: 'Salads',
  ),
  const FoodItem(
    id: 'p4',
    name: 'Spicy Chicken Wings',
    description: 'Crispy chicken wings tossed in a fiery buffalo sauce, served with blue cheese dip.',
    price: 11.25,
    imageUrl: 'https://images.unsplash.com/photo-1626074219472-f1779930a08e?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    category: 'Appetizers',
  ),
  const FoodItem(
    id: 'p5',
    name: 'Vegan Power Bowl',
    description: 'Quinoa, roasted vegetables, avocado, and a lemon-tahini dressing.',
    price: 13.50,
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a5739a67e991?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    category: 'Healthy',
  ),
  const FoodItem(
    id: 'p6',
    name: 'Chocolate Lava Cake',
    description: 'Warm chocolate cake with a molten center, served with vanilla ice cream.',
    price: 7.99,
    imageUrl: 'https://images.unsplash.com/photo-1578985202863-71839556ce6d?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    category: 'Desserts',
  ),
];

// --- 4. Main App Setup ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider is used to provide multiple ChangeNotifier instances
    // to the widget tree, making them accessible to descendant widgets.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Food Delivery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange, // Primary color for the app
            brightness: Brightness.light,
          ),
          useMaterial3: true, // Enable Material 3 design
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        // Define named routes for navigation.
        routes: {
          '/': (context) => const HomeScreen(),
          '/food-detail': (context) => const FoodDetailScreen(),
          '/cart': (context) => const CartScreen(),
          '/orders': (context) => const OrdersScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}

// --- 5. Screens ---

/// The main screen displaying food items and bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Manages the selected tab in BottomNavigationBar

  // List of widgets (screens) to display based on the selected index.
  final List<Widget> _widgetOptions = <Widget>[
    _FoodListScreen(), // Home tab content
    const CartScreen(), // Cart tab content
    const OrdersScreen(), // Orders tab content
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer listens to CartProvider changes and rebuilds only the AppBar's cart icon.
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Foodie Express'),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      // Navigate to cart screen if not already on it
                      if (_selectedIndex != 1) {
                        _onItemTapped(1); // Switch to the cart tab
                      }
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: _widgetOptions.elementAt(_selectedIndex), // Display selected screen content
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Orders',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}

/// A sub-screen for displaying the list of food items.
class _FoodListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sampleFoodItems.length,
      itemBuilder: (context, index) {
        final item = sampleFoodItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              // Navigate to FoodDetailScreen, passing the FoodItem as an argument.
              Navigator.pushNamed(
                context,
                '/food-detail',
                arguments: item,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Screen to display details of a single food item and add it to cart.
class FoodDetailScreen extends StatelessWidget {
  const FoodDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the FoodItem passed as arguments from the previous screen.
    final FoodItem item = ModalRoute.of(context)!.settings.arguments as FoodItem;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero( // Hero animation for smooth transition of the image
              tag: 'food-image-${item.id}',
              child: Image.network(
                item.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: Colors.grey[600]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.category,
                    style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.description,
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: textTheme.displaySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          return ElevatedButton.icon(
                            onPressed: () {
                              cart.addItem(item); // Add item to cart using provider
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} added to cart!'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to Cart'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen to display and manage items in the shopping cart.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: cart.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty!',
                    style: textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start adding some delicious food.',
                    style: textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cartItem.foodItem.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image, color: Colors.grey[600]),
                                ),
                              ),
                            ),
                            title: Text(
                              cartItem.foodItem.name,
                              style: textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              '\$${cartItem.foodItem.price.toStringAsFixed(2)} per item',
                              style: textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => cart.removeItem(cartItem.foodItem),
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: textTheme.titleMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => cart.addItem(cartItem.foodItem),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Divider(thickness: 1, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${cart.totalPrice.toStringAsFixed(2)}',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (cart.itemCount > 0) {
                              orderProvider.placeOrder(cart.cartItems, cart.totalPrice); // Place the order
                              cart.clearCart(); // Clear the cart after placing order
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order placed successfully!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              // Optionally navigate to the orders screen
                              Navigator.pushReplacementNamed(context, '/orders');
                            }
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Proceed to Checkout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Screen to display a list of all placed orders.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  // Helper method to get color for order status
  Color _getStatusColor(BuildContext context, OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.outForDelivery:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer listens to OrderProvider changes and rebuilds the list of orders.
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final textTheme = Theme.of(context).textTheme;

        if (orderProvider.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No orders yet!',
                  style: textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Place an order and see it here.',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderProvider.orders.length,
          itemBuilder: (context, index) {
            final order = orderProvider.orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  'Order #${order.id.substring(0, 8)}', // Display a short ID
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${order.timestamp.toLocal().toString().split(' ')[0]} - Total: \$${order.total.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium,
                ),
                trailing: Chip(
                  label: Text(
                    order.status.name.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _getStatusColor(context, order.status),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items:',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.quantity}x ${item.foodItem.name}',
                                      style: textTheme.bodyLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order Total:',
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
