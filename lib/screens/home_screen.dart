import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reqgpt_controller.dart';
import 'artifacts_screen.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _switchToChat() => setState(() => _index = 0);

  @override
  Widget build(BuildContext context) {
    final loaded = context.select<ReqGptController, bool>((c) => c.isSessionLoaded);

    if (!loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      ChatScreen(onNewSession: _switchToChat),
      const ArtifactsScreen(),
      HistoryScreen(onSessionSelected: _switchToChat),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Artifacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Geçmiş',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
