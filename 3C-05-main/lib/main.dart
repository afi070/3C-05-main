// Design reference PDF: /mnt/data/mood coffe.pdf
// Single-file Flutter demo implementing the MoodCoffee UI described in the design PDF.

import 'package:flutter/material.dart';

void main() {
  runApp(const MoodCoffeeApp());
}

class MoodCoffeeApp extends StatelessWidget {
  const MoodCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoodCoffee',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF7F5F2),
        fontFamily: 'Poppins',
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final CartModel cart = CartModel();
  bool loggedIn = false;

  void _signIn() {
    setState(() => loggedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    return InheritedCart(
      cart: cart,
      child: loggedIn ? HomePage(onSignOut: () => setState(() => loggedIn = false)) : LoginPage(onSignIn: _signIn),
    );
  }
}

// =====================
// Login Page
// =====================
class LoginPage extends StatefulWidget {
  final VoidCallback onSignIn;
  const LoginPage({super.key, required this.onSignIn});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('MOODCOFFEE', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              const Text('Get In Now', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Phone number / email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // NOTE: For demo we simply call onSignIn. Replace with real auth.
                    widget.onSignIn();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 16)),
                ),
              ),

              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("don't have an account? Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// Home Page (with tabs)
// =====================
class HomePage extends StatefulWidget {
  final VoidCallback onSignOut;
  const HomePage({super.key, required this.onSignOut});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; // 0: home, 1: explore, 2: cart, 3: profile

  @override
  Widget build(BuildContext context) {
    final cart = InheritedCart.of(context)!.cart;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text('MoodCoffee', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                      child: Text('${cart.totalItems}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  )
              ],
            ),
            onPressed: () => setState(() => selectedIndex = 2),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          HomeTab(onOpenDetail: (product) => _openDetail(context, product)),
          const ExploreTab(),
          CartPage(onCheckout: () => _checkout(context)),
          ProfilePage(onSignOut: widget.onSignOut),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Product product) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
  }

  void _checkout(BuildContext context) async {
    final cart = InheritedCart.of(context)!.cart;
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final confirmed = await showDialog<bool>(context: context, builder: (_) => const CheckoutDialog());
    if (confirmed == true) {
      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed — Payment Successful')));
    }
  }
}

// =====================
// Home Tab
// =====================
class HomeTab extends StatelessWidget {
  final void Function(Product) onOpenDetail;
  const HomeTab({super.key, required this.onOpenDetail});

  static final List<Product> sampleProducts = [
    Product(name: 'Cappuccino', price: 25000, rating: 4.9),
    Product(name: 'Caramel Latte', price: 27000, rating: 4.8),
    Product(name: 'Matcha Espresso', price: 24000, rating: 4.7),
    Product(name: 'Hazelnut Coffee', price: 25000, rating: 4.6),
    Product(name: 'Vanilla Latte', price: 27000, rating: 4.8),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text('Pilih seduhan favoritmu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),

        Row(
          children: const [
            Expanded(child: CategoryButton(label: 'Hot coffee')),
            SizedBox(width: 8),
            Expanded(child: CategoryButton(label: 'Cold coffee')),
            SizedBox(width: 8),
            Expanded(child: CategoryButton(label: 'Others')),
          ],
        ),

        const SizedBox(height: 20),
        const Text('Daily Specials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sampleProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SpecialCard(product: sampleProducts[i], onTap: () => onOpenDetail(sampleProducts[i])),
          ),
        ),

        const SizedBox(height: 20),
        const Text('Recommend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        ...sampleProducts.map((p) => ProductListTile(product: p, onTap: () => onOpenDetail(p))).toList(),
        const SizedBox(height: 80),
      ],
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  const CategoryButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class SpecialCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const SpecialCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.brown.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.coffee, size: 48),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Rp ${product.price}', style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const ProductListTile({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.brown.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.local_cafe)),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Rp ${product.price}  •  ${product.rating} ⭐'),
        trailing: IconButton(onPressed: () => InheritedCart.of(context)!.cart.add(product), icon: const Icon(Icons.add_circle_outline)),
      ),
    );
  }
}

// =====================
// Product Detail Page
// =====================
class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  String milk = 'Classic';

  @override
  Widget build(BuildContext context) {
    final cart = InheritedCart.of(context)!.cart;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.black87, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.brown.shade100, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Icon(Icons.coffee, size: 72)),
            ),
            const SizedBox(height: 16),
            Text(widget.product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Perpaduan espresso, susu, dan sirup — manis, creamy, dan populer banget.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),

            const Text('Choose milk', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              _milkOption('Classic'),
              const SizedBox(width: 8),
              _milkOption('Almond'),
              const SizedBox(width: 8),
              _milkOption('Coconut'),
            ]),

            const SizedBox(height: 16),
            const Text('Coffee size', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              _sizeOption('270ml'),
              const SizedBox(width: 8),
              _sizeOption('280ml'),
              const SizedBox(width: 8),
              _sizeOption('450ml'),
            ]),

            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rp ${widget.product.price * quantity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {
                    cart.add(widget.product, qty: quantity);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Order now'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _milkOption(String label) {
    final selected = milk == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => milk = label),
    );
  }

  Widget _sizeOption(String label) {
    return ElevatedButton(onPressed: () {}, child: Text(label));
  }
}

// =====================
// Cart Page
// =====================
class CartPage extends StatefulWidget {
  final VoidCallback onCheckout;
  const CartPage({super.key, required this.onCheckout});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cart = InheritedCart.of(context)!.cart;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text('Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (cart.items.isEmpty)
              Expanded(child: Center(child: Text('Your cart is empty', style: TextStyle(color: Colors.black54))))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (_, i) {
                    final it = cart.items[i];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.brown.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.local_cafe)),
                        title: Text(it.product.name),
                        subtitle: Text('Rp ${it.product.price} x ${it.qty}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(onPressed: () => setState(() => cart.decrement(it.product)), icon: const Icon(Icons.remove_circle_outline)),
                          IconButton(onPressed: () => setState(() => cart.increment(it.product)), icon: const Icon(Icons.add_circle_outline)),
                        ]),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Subtotal Rp ${cart.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(onPressed: widget.onCheckout, child: const Text('Place order')),
            ])
          ],
        ),
      ),
    );
  }
}

class CheckoutDialog extends StatelessWidget {
  const CheckoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment'),
      content: const Text('Choose payment method (demo) — click Confirm to simulate successful payment.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
      ],
    );
  }
}

// =====================
// Explore & Profile
// =====================
class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Explore (coming soon)', style: TextStyle(color: Colors.black54)));
  }
}

class ProfilePage extends StatelessWidget {
  final VoidCallback onSignOut;
  const ProfilePage({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Row(children: [
            Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.brown.shade100, shape: BoxShape.circle), child: const Icon(Icons.person)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Afiiwwww', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('afiw03@gmail.com')]),
          ]),
          const SizedBox(height: 20),
          ListTile(leading: const Icon(Icons.history), title: const Text('Order History')),
          ListTile(leading: const Icon(Icons.location_on), title: const Text('My Address')),
          ListTile(leading: const Icon(Icons.payment), title: const Text('Payment method')),
          const Spacer(),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onSignOut, child: const Text('Sign Out'))),
        ]),
      ),
    );
  }
}

// =====================
// Models + Inherited
// =====================
class Product {
  final String name;
  final int price;
  final double rating;

  Product({required this.name, required this.price, this.rating = 0});
}

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, this.qty = 1});
}

class CartModel {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold<int>(0, (s, e) => s + e.qty);
  int get totalPrice => _items.fold<int>(0, (s, e) => s + e.qty * e.product.price);

  void add(Product product, {int qty = 1}) {
    final idx = _items.indexWhere((it) => it.product.name == product.name);
    if (idx >= 0) {
      _items[idx].qty += qty;
    } else {
      _items.add(CartItem(product: product, qty: qty));
    }
  }

  void increment(Product product) {
    final idx = _items.indexWhere((it) => it.product.name == product.name);
    if (idx >= 0) _items[idx].qty++;
  }

  void decrement(Product product) {
    final idx = _items.indexWhere((it) => it.product.name == product.name);
    if (idx >= 0) {
      _items[idx].qty--;
      if (_items[idx].qty <= 0) _items.removeAt(idx);
    }
  }

  void clear() => _items.clear();
}

class InheritedCart extends InheritedWidget {
  final CartModel cart;
  const InheritedCart({super.key, required this.cart, required super.child});

  static InheritedCart? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<InheritedCart>();

  @override
  bool updateShouldNotify(covariant InheritedCart oldWidget) => oldWidget.cart != cart;
}
