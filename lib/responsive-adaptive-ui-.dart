import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Responsive & Adaptive Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResponsiveDashboard(constraints);
          },
        ),
      ),
      bottomNavigationBar: _buildAdaptiveNavigationBar(),
    );
  }

  Widget _buildResponsiveDashboard(BoxConstraints constraints) {
    if (constraints.maxWidth < 600) {
      return const MobileDashboard();
    }

    if (constraints.maxWidth < 1024) {
      return const TabletDashboard();
    }

    return const DesktopDashboard();
  }

  Widget _buildAdaptiveNavigationBar() {
    // iOS uses a Cupertino-style navigation bar.
    if (!kIsWeb &&
        Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
        ],
      );
    }

    // Material is used for Android and Web.
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// MOBILE
// ------------------------------------------------------------

class MobileDashboard extends StatelessWidget {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardTitle(),
          SizedBox(height: 30),
          AdaptiveButtonSection(),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// TABLET
// ------------------------------------------------------------

class TabletDashboard extends StatelessWidget {
  const TabletDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: SizedBox(
          width: 700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardTitle(),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: AdaptiveButtonSection(),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: AdaptiveButtonSection(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// DESKTOP
// ------------------------------------------------------------

class DesktopDashboard extends StatelessWidget {
  const DesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(50),
        child: SizedBox(
          width: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardTitle(),
              const SizedBox(height: 35),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: AdaptiveButtonSection(),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: AdaptiveButtonSection(),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: AdaptiveButtonSection(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// TITLE
// ------------------------------------------------------------

class DashboardTitle extends StatelessWidget {
  const DashboardTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Dashboard',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// ------------------------------------------------------------
// ADAPTIVE BUTTON SECTION
// ------------------------------------------------------------

class AdaptiveButtonSection extends StatelessWidget {
  const AdaptiveButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFD0D0D0),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Buttons',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),

          Text(
            'Default Button',
            style: TextStyle(fontSize: 11),
          ),
          SizedBox(height: 5),
          AdaptiveButton(
            text: 'Click Me',
          ),

          SizedBox(height: 12),

          Text(
            'Button with Icon',
            style: TextStyle(fontSize: 11),
          ),
          SizedBox(height: 5),
          AdaptiveButton(
            text: 'Click Me',
            icon: Icons.favorite,
          ),

          SizedBox(height: 12),

          Text(
            'Disabled Button',
            style: TextStyle(fontSize: 11),
          ),
          SizedBox(height: 5),
          AdaptiveButton(
            text: 'Disabled',
            enabled: false,
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ADAPTIVE BUTTON
// ------------------------------------------------------------

class AdaptiveButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool enabled;

  const AdaptiveButton({
    super.key,
    required this.text,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb &&
        Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          disabledColor: CupertinoColors.systemGrey4,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          onPressed: enabled
              ? () {}
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                ),
                const SizedBox(width: 6),
              ],
              Text(text),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled
            ? () {}
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}