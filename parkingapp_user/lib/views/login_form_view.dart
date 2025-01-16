import 'package:flutter/material.dart';
import 'package:cli/utils/validator.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginFormView extends StatefulWidget {
  const LoginFormView({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  _LoginFormViewState createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController personNumController = TextEditingController();

  String? personNameError;
  String? personNumError;

  final PersonRepository _personRepository = PersonRepository.instance;

  /// Displays a loading spinner for 2 seconds before calling the login logic.
  Future<void> _showLoadingAndLogin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2)); // Simulate a delay

    Navigator.of(context).pop(); // Close the spinner
    _login(); // Proceed with login logic
  }

  /// Perform login and update the shared preferences.
  void _login() async {
    final personName = nameController.text.trim();
    final personNum = personNumController.text.trim();
    final personID;

    setState(() {
      personNameError = personName.isEmpty || !Validator.isString(personName)
          ? "Ogiltigt namn"
          : null;
      personNumError = personNum.isEmpty ? "Personnummer krävs" : null;
    });

    if (personNameError == null && personNumError == null) {
      try {
        // Fetch user data from the repository
        final personList = await _personRepository.getAllPersons();
        final personMap = {
          for (var person in personList) person.personNumber: person,
        };

        if (!personMap.containsKey(personNum) ||
            personMap[personNum]?.name != personName) {
          setState(() {
            personNumError =
                'Personen "$personName" med personnummer "$personNum" finns inte.';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Personen "$personName"  med personnummer "$personNum" finns inte.')),
          );
          return;
        }

        // Save login state and invoke success callback
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('loggedInName', personName);
        await prefs.setString('loggedInPersonNum', personNum);
        await prefs.setString(
            'loggedInPersonID', personMap[personNum]!.id.toString());
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inloggad framgångsrikt")),
        );

        widget.onLoginSuccess(); // Notify parent widget of login success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ett fel uppstod: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Kontrollera uppgifterna och försök igen")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logga In")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Namn",
                          errorText: personNameError,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: personNumController,
                        decoration: InputDecoration(
                          labelText: "Personnummer",
                          errorText: personNumError,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showLoadingAndLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text("Logga In"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
