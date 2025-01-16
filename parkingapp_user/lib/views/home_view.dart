import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// To access the global isDarkModeNotifier
import 'login_view.dart';
import 'vehicle_management_view.dart';
import 'parkingspace_selection_view.dart';
import 'overview_view.dart';
import 'settings_view.dart'; // Import the SettingsView

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default selected index
  bool isLoggedIn = false; // Track login state
  String? loggedInName; // Logged-in user's name
  String? loggedInPersonNum; // Logged-in user's personal number

  // Define all views
  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      const VehicleManagementView(),
      const ParkingSpaceSelectionScreen(),
      const OverviewView(),
      const SettingsView(), // Add SettingsView as the last tab
    ];
    _loadLoggedInUser();
  }

  // Fetch logged-in user data from SharedPreferences
  Future<void> _loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInName = prefs.getString('loggedInName');
      loggedInPersonNum = prefs.getString('loggedInPersonNum');
      isLoggedIn = loggedInName != null && loggedInPersonNum != null;
    });
  }

  // Handle successful login
  void _onLoginSuccess() {
    _loadLoggedInUser(); // Refresh logged-in user data
    setState(() {
      isLoggedIn = true;
      _selectedIndex = 0; // Navigate to the first main view
    });
  }

  // Handle logout
  Future<void> _logout() async {
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Bekräfta utloggning"),
          content: const Text("Vill du logga ut?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Avbryt"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logga ut"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      // Clear user data
      await prefs.clear();
      setState(() {
        isLoggedIn = false; // Return to the login view
        loggedInName = null;
        loggedInPersonNum = null;
      });
    }
  }

  // Handle navigation between tabs
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoggedIn
          ? AppBar(
              title: Text("Välkommen, $loggedInName!"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsView(),
                      ),
                    );
                  },
                ),
              ],
            )
          : null, // No AppBar for login view
      body: isLoggedIn
          ? _views[_selectedIndex] // Show main views
          : LoginView(onLoginSuccess: _onLoginSuccess), // Show login view
      bottomNavigationBar: isLoggedIn
          ? BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car),
                  label: 'Fordon',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_parking),
                  label: 'Parkeringsplats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Översikt',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Inställningar',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: const Color.fromARGB(255, 64, 63, 63),
              onTap: _onItemTapped,
            )
          : null, // No navigation bar for login view
    );
  }
}
