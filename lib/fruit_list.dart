import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter router = GoRouter(
  routes: [
    // Main route: /
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const FruitListPage();
      },

      // Nested route: /fruit/:name
      routes: [
        GoRoute(
          path: 'fruit/:name',
          builder: (context, state) {
            final fruitName = state.pathParameters['name']!;

            return FruitPage(
              fruitName: fruitName,
            );
          },
        ),
      ],
    ),
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fruit App',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}


class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruit List'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        children: [
          // APPLE
          ListTile(
            leading: const Text(
              '🍎',
              style: TextStyle(fontSize: 30),
            ),
            title: const Text(
              'Apple',
              style: TextStyle(fontSize: 20),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go('/fruit/apple');
            },
          ),

          const Divider(),

          // BANANA
          ListTile(
            leading: const Text(
              '🍌',
              style: TextStyle(fontSize: 30),
            ),
            title: const Text(
              'Banana',
              style: TextStyle(fontSize: 20),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go('/fruit/banana');
            },
          ),

          const Divider(),

          // ORANGE
          ListTile(
            leading: const Text(
              '🍊',
              style: TextStyle(fontSize: 30),
            ),
            title: const Text(
              'Orange',
              style: TextStyle(fontSize: 20),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go('/fruit/orange');
            },
          ),

          const Divider(),

          // MANGO
          ListTile(
            leading: const Text(
              '🥭',
              style: TextStyle(fontSize: 30),
            ),
            title: const Text(
              'Mango',
              style: TextStyle(fontSize: 20),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go('/fruit/mango');
            },
          ),

          const Divider(),

          // STRAWBERRY
          ListTile(
            leading: const Text(
              '🍓',
              style: TextStyle(fontSize: 30),
            ),
            title: const Text(
              'Strawberry',
              style: TextStyle(fontSize: 20),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go('/fruit/strawberry');
            },
          ),
        ],
      ),
    );
  }
}


class FruitPage extends StatelessWidget {
  final String fruitName;

  const FruitPage({
    super.key,
    required this.fruitName,
  });

  // Get the appropriate fruit emoji
  String getFruitEmoji(String fruit) {
    switch (fruit.toLowerCase()) {
      case 'apple':
        return '🍎';

      case 'banana':
        return '🍌';

      case 'orange':
        return '🍊';

      case 'mango':
        return '🥭';

      case 'strawberry':
        return '🍓';

      default:
        return '🍎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fruitName[0].toUpperCase() +
              fruitName.substring(1),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fruit illustration
            Text(
              getFruitEmoji(fruitName),
              style: const TextStyle(
                fontSize: 150,
              ),
            ),

            const SizedBox(height: 20),

            // Fruit name
            Text(
              fruitName.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Back button
            ElevatedButton.icon(
              onPressed: () {
                context.go('/');
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Fruits'),
            ),
          ],
        ),
      ),
    );
  }
}