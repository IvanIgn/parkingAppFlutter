import 'package:flutter/material.dart';
import 'package:cli/utils/validator.dart'; // Import the Validator class
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController personNumController = TextEditingController();
  final TextEditingController confirmPersonNumController =
      TextEditingController();

  String? nameError;
  String? personNumError;

  final PersonRepository _personRepository = PersonRepository.instance;

  /// Displays a loading spinner for 2 seconds before calling the registration logic.
  Future<void> _showLoadingAndRegister() async {
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
    _register(); // Proceed with registration logic
  }

  void _register() async {
    final name = nameController.text.trim();
    final personNum = personNumController.text.trim();
    final confirmPersonNum = confirmPersonNumController.text.trim();

    setState(() {
      nameError =
          name.isEmpty || !Validator.isString(name) ? "Ogiltigt namn" : null;
      personNumError = personNum != confirmPersonNum
          ? "Personnummer matchar inte"
          : personNum.length < 12
              ? "Personnumret måste innehålla 12 tecken"
              : null;
    });

    if (nameError == null && personNumError == null) {
      try {
        final personList = await _personRepository.getAllPersons();
        final personMap = {
          for (var person in personList) person.personNumber: person
        };

        if (personMap.containsKey(personNum)) {
          setState(() {
            personNumError =
                'Personen med personnummer "$personNum" finns redan.';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Personen med personnummer "$personNum" finns redan.')),
          );
          return;
        } else {
          // Create and add the person
          final newPerson = Person(
            id: 0, // ID will be assigned by the server
            name: name,
            personNumber: personNum,
          );

          await _personRepository.createPerson(newPerson);

          // Notify user of success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registrering framgångsrik")),
          );

          // Clear inputs after successful registration
          nameController.clear();
          personNumController.clear();
          confirmPersonNumController.clear();

          // Navigate back to the login view
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Handle errors during registration
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
      appBar: AppBar(title: const Text("Registrera Dig")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 400), // Limits the width
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
                          errorText: nameError,
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
                        obscureText: false,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPersonNumController,
                        decoration: InputDecoration(
                          labelText: "Bekräfta personnummer",
                          errorText: personNumError,
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: false,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showLoadingAndRegister,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text("Registrera"),
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
