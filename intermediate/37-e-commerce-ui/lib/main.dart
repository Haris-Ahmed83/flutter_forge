import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The main entry point of the application.
void main() {
  runApp(
    /// ChangeNotifierProvider provides the CartProvider instance
    /// to all widgets below it in the widget tree,
    /// allowing them to access and modify the cart state.
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

/// Represents a single product in the e-commerce store.
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

/// Represents an item in the shopping cart, including the product and its quantity.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// Calculates the total price for this cart item (product price * quantity).
  double get totalPrice => product.price * quantity;
}

/// Manages the state of the shopping cart using the ChangeNotifier pattern.
/// Widgets can listen to this provider for updates to the cart.
class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  /// Returns the total number of distinct items in the cart.
  int get itemCount => _cartItems.length;

  /// Returns the total quantity of all products in the cart.
  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Calculates the total price of all items in the cart.
  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Adds a product to the cart. If the product already exists, increments its quantity.
  void addItem(Product product) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0), // Use a dummy item if not found
    );

    if (existingItem.quantity > 0) { // If it was found (quantity > 0 means it's a real existing item)
      existingItem.quantity++;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners(); // Notifies listeners that the cart has changed.
  }

  /// Removes a product from the cart. If the quantity is greater than 1, decrements it.
  /// If the quantity is 1, removes the item entirely.
  void removeItem(Product product) {
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      if (_cartItems[existingItemIndex].quantity > 1) {
        _cartItems[existingItemIndex].quantity--;
      } else {
        _cartItems.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  /// Increases the quantity of a specific cart item.
  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  /// Decreases the quantity of a specific cart item. If quantity becomes 0, removes the item.
  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cartItems.removeWhere((cartItem) => cartItem.product.id == item.product.id);
    }
    notifyListeners();
  }

  /// Clears all items from the cart.
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

/// The root widget of the application, setting up Material Design and theming.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true, // Enable Material 3 design.
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      home: const ProductGridScreen(),
    );
  }
}

/// Displays a grid of products and provides navigation to the cart screen.
class ProductGridScreen extends StatelessWidget {
  const ProductGridScreen({super.key});

  /// Sample product data for demonstration.
  static const List<Product> _sampleProducts = [
    Product(
      id: 'p1',
      name: 'Wireless Earbuds',
      description: 'High-quality sound with active noise cancellation.',
      price: 99.99,
      imageUrl: 'https://picsum.photos/id/180/400/300',
    ),
    Product(
      id: 'p2',
      name: 'Smartwatch X',
      description: 'Track your fitness, heart rate, and notifications.',
      price: 199.50,
      imageUrl: 'https://picsum.photos/id/20/400/300',
    ),
    Product(
      id: 'p3',
      name: 'Portable Bluetooth Speaker',
      description: 'Powerful sound in a compact, waterproof design.',
      price: 75.00,
      imageUrl: 'https://picsum.photos/id/25/400/300',
    ),
    Product(
      id: 'p4',
      name: 'Gaming Mouse Pro',
      description: 'Ergonomic design with programmable buttons.',
      price: 49.99,
      imageUrl: 'https://picsum.photos/id/35/400/300',
    ),
    Product(
      id: 'p5',
      name: '4K Ultra HD Monitor',
      description: 'Stunning visuals for work and entertainment.',
      price: 349.00,
      imageUrl: 'https://picsum.photos/id/30/400/300',
    ),
    Product(
      id: 'p6',
      name: 'External SSD 1TB',
      description: 'Fast and reliable storage for all your files.',
      price: 120.00,
      imageUrl: 'https://picsum.photos/id/40/400/300',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          /// Consumer listens to CartProvider changes and rebuilds only the relevant part (the badge).
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (cart.totalQuantity > 0)
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
                          '${cart.totalQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two products per row.
          childAspectRatio: 0.7, // Adjust to fit content better.
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: _sampleProducts.length,
        itemBuilder: (context, index) {
          final product = _sampleProducts[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}

/// Displays a single product with its image, name, price, and an "Add to Cart" button.
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures image respects card border.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 40)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: textTheme.titleSmall?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  /// Access the CartProvider and add the product.
                  Provider.of<CartProvider>(context, listen: false).addItem(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the contents of the shopping cart, allowing users to modify quantities or remove items.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    /// Consumer rebuilds when CartProvider notifies listeners.
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Cart'),
            actions: [
              if (cart.itemCount > 0)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Clear Cart',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Cart?'),
                        content: const Text('Do you want to clear all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('No'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cart cleared!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: cart.cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Your cart is empty!',
                        style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start adding some products.',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(); // Go back to product grid.
                        },
                        icon: const Icon(Icons.store),
                        label: const Text('Shop Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: cart.cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cart.cartItems[index];
                          return CartItemTile(cartItem: cartItem);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total:',
                                    style: textTheme.headlineSmall,
                                  ),
                                  Text(
                                    '\$${cart.totalPrice.toStringAsFixed(2)}',
                                    style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Checkout functionality not implemented yet!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.payment),
                                  label: const Text('Proceed to Checkout'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    textStyle: textTheme.labelLarge,
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// Displays a single item within the cart, showing product details and quantity controls.
class CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const CartItemTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                cartItem.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${cartItem.product.price.toStringAsFixed(2)}',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.secondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          cartProvider.decreaseQuantity(cartItem);
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        '${cartItem.quantity}',
                        style: textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          cartProvider.increaseQuantity(cartItem);
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      const Spacer(),
                      Text(
                        'Total: \$${cartItem.totalPrice.toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
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
