import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'bmi_screen.dart';
import 'workout_screen.dart';
import 'timer_screen.dart';
import 'calorie_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BmiScreen(),
    WorkoutScreen(),
    TimerScreen(),
    CalorieScreen(),
  ];

  final List<String> _titles = const [
    'Chỉ Số BMI & Sức Khỏe',
    'Nhật Ký Tập Luyện',
    'Đồng Hồ Nghỉ Hiệp Tập',
    'Tra Cứu Calo Món Ăn',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Đổi chế độ Sáng / Tối',
            icon: Icon(
              themeProv.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProv.toggleTheme(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0F766E),
        onTap: (idx) => setState(() => _selectedIndex = idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight_outlined),
            label: 'Đo BMI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Nhật ký tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Nghỉ hiệp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            label: 'Calo món',
          ),
        ],
      ),
    );
  }
}
