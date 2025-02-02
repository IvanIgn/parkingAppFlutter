import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:intl/intl.dart';

class MonitorParkingsView extends StatefulWidget {
  const MonitorParkingsView({super.key});

  @override
  MonitorParkingSViewState createState() => MonitorParkingSViewState();
}

class MonitorParkingSViewState extends State<MonitorParkingsView> {
  late Future<List<Parking>> _parkingsFuture;
  late Future<List<Vehicle>> _vehiclesFuture;
  late Future<List<ParkingSpace>> _parkingSpacesFuture;

  @override
  void initState() {
    super.initState();
    _refreshParkings();
    _vehiclesFuture = VehicleRepository.instance.getAllVehicles();
    _parkingSpacesFuture =
        ParkingSpaceRepository.instance.getAllParkingSpaces();
  }

  void _refreshParkings() {
    setState(() {
      _parkingsFuture = ParkingRepository.instance.getAllParkings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aktiva Parkeringar"),
      ),
      body: FutureBuilder<List<Parking>>(
        future: _parkingsFuture,
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
                'Inga aktiva parkeringar tillgängliga.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final parkingsList = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: parkingsList.length,
            itemBuilder: (context, index) {
              final parking = parkingsList[index];
              return ListTile(
                title: Text(
                  'Parkerings-ID: ${parking.id}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starttid: ${DateFormat('HH:mm').format(parking.startTime)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Sluttid: ${DateFormat('HH:mm').format(parking.endTime)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (parking.vehicle != null)
                      Text(
                        'Registreringsnummer: ${parking.vehicle!.regNumber}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (parking.parkingSpace != null)
                      Text(
                        'Plats: ${parking.parkingSpace!.address ?? 'Okänd'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditParkingDialog(context, parking),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, parking);
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
        onPressed: () => _showAddParkingDialog(context),
        tooltip: 'Lägg till parkering',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddParkingDialog(BuildContext context) {
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();
    Vehicle? selectedVehicle;
    ParkingSpace? selectedParkingSpace;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lägg till parkering"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Starttid (HH:mm)',
                  ),
                ),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Sluttid (HH:mm)',
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Vehicle>>(
                  future: _vehiclesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                          'Fel vid hämtning av fordon: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Inga fordon tillgängliga.');
                    }

                    final vehicles = snapshot.data!;
                    return DropdownButtonFormField<Vehicle>(
                      decoration:
                          const InputDecoration(labelText: 'Välj fordon'),
                      items: vehicles.map((vehicle) {
                        return DropdownMenuItem<Vehicle>(
                          value: vehicle,
                          child: Text(vehicle.regNumber),
                        );
                      }).toList(),
                      onChanged: (vehicle) {
                        selectedVehicle = vehicle;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<ParkingSpace>>(
                  future: _parkingSpacesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                          'Fel vid hämtning av parkeringsplatser: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Inga parkeringsplatser tillgängliga.');
                    }

                    final parkingSpaces = snapshot.data!;
                    return DropdownButtonFormField<ParkingSpace>(
                      decoration: const InputDecoration(
                          labelText: 'Välj parkeringsplats'),
                      items: parkingSpaces.map((parkingSpace) {
                        return DropdownMenuItem<ParkingSpace>(
                          value: parkingSpace,
                          child: Text(parkingSpace.address),
                        );
                      }).toList(),
                      onChanged: (parkingSpace) {
                        selectedParkingSpace = parkingSpace;
                      },
                    );
                  },
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
                if (startTimeController.text.isEmpty ||
                    endTimeController.text.isEmpty ||
                    selectedVehicle == null ||
                    selectedParkingSpace == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Välj tider, fordon och parkeringsplats"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // Validate time format
                if (!_isValidTimeFormat(startTimeController.text) ||
                    !_isValidTimeFormat(endTimeController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tidsformat ska vara HH:mm"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                final now = DateTime.now();
                final startTimeParts =
                    startTimeController.text.split(':').map(int.parse).toList();
                final endTimeParts =
                    endTimeController.text.split(':').map(int.parse).toList();

                final newParking = Parking(
                  id: 0,
                  startTime: DateTime(now.year, now.month, now.day,
                      startTimeParts[0], startTimeParts[1]),
                  endTime: DateTime(now.year, now.month, now.day,
                      endTimeParts[0], endTimeParts[1]),
                  vehicle: selectedVehicle!,
                  parkingSpace: selectedParkingSpace!,
                );

                await ParkingRepository.instance.createParking(newParking);

                Navigator.of(context).pop();
                _refreshParkings();
              },
              child: const Text("Spara"),
            ),
          ],
        );
      },
    );
  }

  void _showEditParkingDialog(BuildContext context, Parking parking) {
    final TextEditingController startTimeController = TextEditingController(
        text: DateFormat('HH:mm').format(parking.startTime));
    final TextEditingController endTimeController = TextEditingController(
        text: DateFormat('HH:mm').format(parking.endTime));
    final TextEditingController vehicleRegController =
        TextEditingController(text: parking.vehicle?.regNumber ?? '');
    final TextEditingController parkingSpaceAddressController =
        TextEditingController(text: parking.parkingSpace?.address ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Redigera parkering"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Starttid (HH:mm)',
                  ),
                ),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Sluttid (HH:mm)',
                  ),
                ),
                TextField(
                  controller: vehicleRegController,
                  decoration: const InputDecoration(
                    labelText: 'Fordonets registreringsnummer',
                  ),
                ),
                TextField(
                  controller: parkingSpaceAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Parkeringsplats adress',
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
                // Validate time format
                if (!_isValidTimeFormat(startTimeController.text) ||
                    !_isValidTimeFormat(endTimeController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tidsformat ska vara HH:mm"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                try {
                  DateTime now = DateTime.now();
                  List<String> startTimeParts =
                      startTimeController.text.split(":");
                  List<String> endTimeParts = endTimeController.text.split(":");

                  DateTime startTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    int.parse(startTimeParts[0]),
                    int.parse(startTimeParts[1]),
                  );

                  DateTime endTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    int.parse(endTimeParts[0]),
                    int.parse(endTimeParts[1]),
                  );

                  final updatedParking = Parking(
                    id: parking.id,
                    startTime: startTime,
                    endTime: endTime,
                    vehicle: Vehicle(
                      regNumber: vehicleRegController.text,
                      vehicleType: 'defaultType', // Replace with actual type
                    ),
                    parkingSpace: ParkingSpace(
                      address: parkingSpaceAddressController.text,
                      pricePerHour: 0, // Replace with actual price
                    ),
                  );

                  await ParkingRepository.instance
                      .updateParking(parking.id, updatedParking);

                  Navigator.of(context).pop();
                  _refreshParkings();
                } catch (e) {
                  print("Error parsing time: $e");
                }
              },
              child: const Text("Spara"),
            ),
          ],
        );
      },
    );
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^(?:[01]\d|2[0-3]):([0-5]\d)$');
    return regex.hasMatch(time);
  }

  void _showDeleteConfirmationDialog(BuildContext context, Parking parking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Bekräfta borttagning"),
          content: Text(
            "Är du säker på att du vill ta bort parkeringen med ID ${parking.id}?",
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
                await ParkingRepository.instance.deleteParking(parking.id);

                Navigator.of(context).pop();
                _refreshParkings();
              },
              child: const Text("Ta bort"),
            ),
          ],
        );
      },
    );
  }
}
