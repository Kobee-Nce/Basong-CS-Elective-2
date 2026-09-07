import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/cart_controller.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cart = CartController.instance;

  @override
  void initState() {
    super.initState();
    cart.addListener(refresh);
  }

  void refresh() => setState(() {});

  @override
  void dispose() {
    cart.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradient
              : AppTheme.lightGradient,
        ),

        child: SafeArea(
          child: cart.items.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),

                        itemCount: cart.items.length,

                        itemBuilder: (context, index) {
                          final item = cart.items[index];

                          return Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(12),

                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                    child: Image.asset(
                                      item.credit.image,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [
                                        Text(
                                          item.credit.title,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),

                                        Text(
                                          '₱${item.credit.price.toStringAsFixed(0)}',
                                        ),

                                        const SizedBox(
                                            height: 8),

                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                cart.decrease(
                                                    item);
                                              },
                                              icon: const Icon(
                                                  Icons
                                                      .remove_circle),
                                            ),

                                            Text(
                                              '${item.quantity}',
                                              style:
                                                  const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),

                                            IconButton(
                                              onPressed: () {
                                                cart.increase(
                                                    item);
                                              },
                                              icon: const Icon(
                                                  Icons
                                                      .add_circle),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    '₱${item.subtotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),

                              Text(
                                '₱${cart.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/checkout');
                              },

                              child: const Text(
                                'Proceed to Checkout',
                                style:
                                    TextStyle(fontSize: 18),
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
  }
}