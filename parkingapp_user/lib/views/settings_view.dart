import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'dart:convert';
import '../main.dart';
import 'login_view.dart';

bool isLoggedIn = false; // Track login state
String? loggedInName; // Logged-in user's name
String? loggedInPersonNum; // Logged-in user's personal number
//ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = prefs.getBool('isDarkMode') ?? false;
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bekräfta'),
          content: const Text(
              'Är du säker på att du vill ta bort den här profilen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Avbryt'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final loggedInPersonJson = prefs.getString('loggedInPerson');

                  if (loggedInPersonJson != null) {
                    final loggedInPerson =
                        json.decode(loggedInPersonJson) as Map<String, dynamic>;
                    final loggedInPersonId = loggedInPerson['id']?.toString();

                    if (loggedInPersonId != null) {
                      // Delete the user from the repository
                      await PersonRepository.instance
                          .deletePerson(int.parse(loggedInPersonId));
                      //   final prefs = await SharedPreferences.getInstance();
                    }
                  }

                  await prefs.clear();
                  setState(() {
                    isLoggedIn = false;
                    loggedInName = null;
                    loggedInPersonNum = null;
                  });
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => LoginView(
                              onLoginSuccess: () {},
                            )),
                    (route) => false, // Remove all routes in the stack
                  );

                  // Clear preferences and navigate to HomeView
                } catch (e) {
                  debugPrint('Error deleting person: $e');
                }
              },
              child: const Text(
                'Ta bort',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inställningar'),
      ),
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: isDarkModeNotifier,
          builder: (context, isDarkMode, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Välj tema',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SwitchListTile(
                  title: const Text('Mörkt läge'),
                  value: isDarkMode,
                  onChanged: (value) async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      isDarkModeNotifier.value = value;
                      await prefs.setBool('isDarkMode', value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tema ändrades till ${value ? 'Mörkt' : 'Ljust'} läge',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error updating dark mode preference: $e');
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Ta bort profil'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
