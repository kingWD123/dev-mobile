import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'messages_screen.dart';
import 'my_trips_screen.dart';
import 'profile_screen.dart';
import 'publish_ride_screen.dart';
import 'search_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  static const screens = [
    SearchScreen(),
    PublishRideScreen(),
    MyTripsScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: AppColors.primary.withValues(alpha: 0.14),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Rechercher'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Publier'),
          NavigationDestination(icon: Icon(Icons.confirmation_num_outlined), selectedIcon: Icon(Icons.confirmation_num), label: 'Trajets'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
