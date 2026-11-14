import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'history/history_screen.dart';
import 'home/home_screen.dart';
import 'scan/scan_screen.dart';
import 'statistics/statistics_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onTabChange: _onTabTapped),
      const ScanScreen(),
      HistoryScreen(onNavigateToScan: _onTabTapped),
      StatisticsScreen(onNavigateToScan: _onTabTapped),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          indicatorColor: AppColors.primaryLight,
          backgroundColor: Colors.white,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryDark),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.center_focus_weak_rounded),
              selectedIcon: Icon(Icons.camera_alt_rounded, color: AppColors.primaryDark),
              label: 'Pindai',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_toggle_off_rounded, color: AppColors.primaryDark),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              selectedIcon: Icon(Icons.analytics_rounded, color: AppColors.primaryDark),
              label: 'Statistik',
            ),
          ],
        ),
      ),
    );
  }
}
