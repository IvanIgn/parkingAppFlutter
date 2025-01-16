// import 'package:flutter/material.dart';
// import 'package:client_repositories/async_http_repos.dart';
// import 'package:shared/shared.dart';

// class ManageVehiclesView extends StatefulWidget {
//   const ManageVehiclesView({super.key});

//   @override
//   _ManageVehiclesViewState createState() => _ManageVehiclesViewState();
// }

// class _ManageVehiclesViewState extends State<ManageVehiclesView> {
//   late Future<List<Vehicle>> _vehiclesFuture;

//   @override
//   void initState() {
//     super.initState();
//     _refreshVehicles();
//   }

//   void _refreshVehicles() {
//     setState(() {
//       _vehiclesFuture = VehicleRepository.instance.getAllVehicles();
//     });
//   }

//   Future<bool> _regNumberExists(String regNumber) async {
//     final vehicles = await VehicleRepository.instance.getAllVehicles();
//     return vehicles.any((vehicle) => vehicle.regNumber == regNumber);
//   }

//   void _showAddVehicleDialog(BuildContext context) {
//     final TextEditingController regNumberController = TextEditingController();
//     String selectedVehicleType = 'Bil';

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Skapa nytt fordon"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: regNumberController,
//                   decoration: const InputDecoration(
//                     labelText: 'Registreringsnummer',
//                   ),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: selectedVehicleType,
//                   items: <String>[
//                     'Bil',
//                     'Lastbil',
//                     'Motorcykel',
//                     'Moped',
//                     'Annat'
//                   ].map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (newValue) {
//                     setState(() {
//                       selectedVehicleType = newValue!;
//                     });
//                   },
//                   decoration: const InputDecoration(
//                     labelText: 'Fordonstyp',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Avbryt"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final regNumber = regNumberController.text;

//                 if (await _regNumberExists(regNumber)) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                           "Fordonet med detta registreringsnummer $regNumber finns redan"),
//                       duration: const Duration(seconds: 2),
//                     ),
//                   );
//                   return;
//                 }

//                 final newVehicle = Vehicle(
//                   regNumber: regNumber,
//                   vehicleType: selectedVehicleType,
//                 );

//                 await VehicleRepository.instance.createVehicle(newVehicle);
//                 Navigator.of(context).pop();
//                 _refreshVehicles();
//               },
//               child: const Text("Spara"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showEditVehicleDialog(BuildContext context, Vehicle vehicle) {
//     final TextEditingController regNumberController =
//         TextEditingController(text: vehicle.regNumber);
//     String selectedVehicleType = vehicle.vehicleType;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Uppdatera fordon"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: regNumberController,
//                   decoration: const InputDecoration(
//                     labelText: 'Registreringsnummer',
//                   ),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: selectedVehicleType,
//                   items: <String>[
//                     'Bil',
//                     'Motorcykel',
//                     'Lastbil',
//                     'Moped',
//                     'Annat'
//                   ].map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (newValue) {
//                     setState(() {
//                       selectedVehicleType = newValue!;
//                     });
//                   },
//                   decoration: const InputDecoration(
//                     labelText: 'Fordonstyp',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Avbryt"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final regNumber = regNumberController.text;

//                 if (regNumber != vehicle.regNumber &&
//                     await _regNumberExists(regNumber)) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                           "Fordonet med detta registreringsnummer $regNumber finns redan"),
//                       duration: const Duration(seconds: 2),
//                     ),
//                   );
//                   return;
//                 }

//                 final updatedVehicle = Vehicle(
//                   id: vehicle.id,
//                   regNumber: regNumber,
//                   vehicleType: selectedVehicleType,
//                 );

//                 await VehicleRepository.instance
//                     .updateVehicle(vehicle.id, updatedVehicle);
//                 Navigator.of(context).pop();
//                 _refreshVehicles();
//               },
//               child: const Text("Spara"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showDeleteConfirmationDialog(BuildContext context, Vehicle vehicle) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Bekräfta borttagning"),
//           content: Text(
//             "Är du säker på att du vill ta bort fordonet med ID ${vehicle.id}?",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Avbryt"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await VehicleRepository.instance.deleteVehicle(vehicle.id);
//                 Navigator.of(context).pop();
//                 _refreshVehicles();
//               },
//               child: const Text("Ta bort"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Hantera fordon"),
//       ),
//       body: FutureBuilder<List<Vehicle>>(
//         future: _vehiclesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Fel vid hämtning av data: ${snapshot.error}',
//                 style: const TextStyle(color: Colors.red, fontSize: 16),
//               ),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 'Inga fordon tillgängliga.',
//                 style: TextStyle(fontSize: 16),
//               ),
//             );
//           }

//           final vehiclesList = snapshot.data!;
//           return ListView.separated(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: vehiclesList.length,
//             itemBuilder: (context, index) {
//               final vehicle = vehiclesList[index];
//               return ListTile(
//                 title: Text(
//                   'Fordon ID: ${vehicle.id}',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Registreringsnummer: ${vehicle.regNumber}',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                     Text(
//                       'Fordonstyp: ${vehicle.vehicleType}',
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () {
//                         _showEditVehicleDialog(context, vehicle);
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         _showDeleteConfirmationDialog(context, vehicle);
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//             separatorBuilder: (context, index) {
//               return const Divider(
//                 thickness: 1,
//                 color: Colors.black87,
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddVehicleDialog(context);
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:shared/shared.dart';

class ManageVehiclesView extends StatefulWidget {
  const ManageVehiclesView({super.key});

  @override
  _ManageVehiclesViewState createState() => _ManageVehiclesViewState();
}

class _ManageVehiclesViewState extends State<ManageVehiclesView> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _refreshVehicles();
  }

  void _refreshVehicles() {
    setState(() {
      _vehiclesFuture = VehicleRepository.instance.getAllVehicles();
    });
  }

  Future<bool> _regNumberExists(String regNumber) async {
    final vehicles = await VehicleRepository.instance.getAllVehicles();
    return vehicles.any((vehicle) => vehicle.regNumber == regNumber);
  }

  bool _isValidRegNumber(String regNumber) {
    final regExp = RegExp(r'^[A-Z]{3}[0-9]{3}$');
    return regExp.hasMatch(regNumber);
  }

  void _showAddVehicleDialog(BuildContext context) {
    final TextEditingController regNumberController = TextEditingController();
    String selectedVehicleType = 'Bil';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Skapa nytt fordon"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: regNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Registreringsnummer',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedVehicleType,
                      items: <String>[
                        'Bil',
                        'Lastbil',
                        'Motorcykel',
                        'Moped',
                        'Annat'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedVehicleType = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Fordonstyp',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Avbryt"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final regNumber = regNumberController.text;

                    if (!_isValidRegNumber(regNumber)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Fordons registreringsnumret ska följa detta format: ABC123"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    if (await _regNumberExists(regNumber)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Fordonet med detta registreringsnummer $regNumber finns redan"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    final newVehicle = Vehicle(
                      regNumber: regNumber,
                      vehicleType: selectedVehicleType,
                    );

                    await VehicleRepository.instance.createVehicle(newVehicle);
                    Navigator.of(context).pop();
                    _refreshVehicles();
                  },
                  child: const Text("Spara"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditVehicleDialog(BuildContext context, Vehicle vehicle) {
    final TextEditingController regNumberController =
        TextEditingController(text: vehicle.regNumber);
    String selectedVehicleType = vehicle.vehicleType;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Uppdatera fordon"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: regNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Registreringsnummer',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedVehicleType,
                      items: <String>[
                        'Bil',
                        'Motorcykel',
                        'Lastbil',
                        'Moped',
                        'Annat'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedVehicleType = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Fordonstyp',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Avbryt"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final regNumber = regNumberController.text;

                    if (!_isValidRegNumber(regNumber)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Fordons registreringsnumret ska följa detta format: ABC123"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    if (regNumber != vehicle.regNumber &&
                        await _regNumberExists(regNumber)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Fordonet med detta registreringsnummer $regNumber finns redan"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    final updatedVehicle = Vehicle(
                      id: vehicle.id,
                      regNumber: regNumber,
                      vehicleType: selectedVehicleType,
                    );

                    await VehicleRepository.instance
                        .updateVehicle(vehicle.id, updatedVehicle);
                    Navigator.of(context).pop();
                    _refreshVehicles();
                  },
                  child: const Text("Spara"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Bekräfta borttagning"),
          content: Text(
            "Är du säker på att du vill ta bort fordonet med ID ${vehicle.id}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Avbryt"),
            ),
            ElevatedButton(
              onPressed: () async {
                await VehicleRepository.instance.deleteVehicle(vehicle.id);
                Navigator.of(context).pop();
                _refreshVehicles();
              },
              child: const Text("Ta bort"),
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
        title: const Text("Hantera fordon"),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Fel vid hämtning av data: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Inga fordon tillgängliga.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final vehiclesList = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: vehiclesList.length,
            itemBuilder: (context, index) {
              final vehicle = vehiclesList[index];
              return ListTile(
                title: Text(
                  'Fordon ID: ${vehicle.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registreringsnummer: ${vehicle.regNumber}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Fordonstyp: ${vehicle.vehicleType}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Ägare: ${vehicle.owner?.name != null && vehicle.owner!.name.isNotEmpty ? vehicle.owner!.name : 'Okänt'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditVehicleDialog(context, vehicle);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, vehicle);
                      },
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                thickness: 1,
                color: Colors.black87,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddVehicleDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
