import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/constants/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    Center(child: Text(AppStrings.navAstrologer)), // Placeholder
    Center(child: Text(AppStrings.navLive)),       // Placeholder
    Center(child: Text(AppStrings.navServices)),   // Placeholder
    Center(child: Text(AppStrings.navHistory)), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: AppStrings.navAstrologer,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv_rounded),
              label: AppStrings.navLive,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: AppStrings.navServices,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: AppStrings.navHistory,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFFF8F00),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
