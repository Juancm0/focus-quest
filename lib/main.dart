import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/quest_provider.dart';
import 'screens/achievements_screen.dart';
import 'screens/habit_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final guardado = await storage.load();
  final inicial = guardado ?? seedData();
  if (guardado == null) {
    // Primera vez: se guardan los hábitos de ejemplo.
    await storage.save(inicial);
  }

  runApp(
    ProviderScope(
      overrides: [initialStateProvider.overrideWithValue(inicial)],
      child: const FocusQuestApp(),
    ),
  );
}

class FocusQuestApp extends StatelessWidget {
  const FocusQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainScreen(),
    );
  }
}

/// Navegación principal con 3 pestañas y botón para crear hábitos.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indice = 0;

  void _crearHabito() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HabitFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      HomeScreen(onCrearHabito: _crearHabito),
      const StatsScreen(),
      const AchievementsScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.sports_esports, color: AppTheme.amber),
            SizedBox(width: 8),
            Text(
              'Focus Quest',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _indice, children: pantallas),
      floatingActionButton: _indice == 0
          ? FloatingActionButton(
              onPressed: _crearHabito,
              tooltip: 'Crear hábito',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: (i) => setState(() => _indice = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Logros',
          ),
        ],
      ),
    );
  }
}
