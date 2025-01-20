import 'dart:convert'; // For JSON encoding/decoding
import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/cli_server_stuff.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParkingSpaceSelectionScreen extends StatefulWidget {
  const ParkingSpaceSelectionScreen({super.key});

  @override
  _ParkingSpaceSelectionScreenState createState() =>
      _ParkingSpaceSelectionScreenState();
}

class _ParkingSpaceSelectionScreenState
    extends State<ParkingSpaceSelectionScreen> {
  late Future<List<ParkingSpace>> _parkingSpacesFuture;
  ParkingSpace? _selectedParkingSpace;
  Person? loggedInPerson; // Tracks the selected parking space
  bool _isParkingActive = false; // Tracks if parking has started

  @override
  void initState() {
    super.initState();
    _loadSelectedParkingSpace(); // Load saved parking space on initialization
    _refreshParkingSpaces();
    //_showSavedInfo();
  }

  Future<void> _loadSelectedParkingSpace() async {
    final prefs = await SharedPreferences.getInstance();

// Load selected parking space
    final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');
    if (selectedParkingSpaceJson != null) {
      final Map<String, dynamic> parkingSpaceData =
          json.decode(selectedParkingSpaceJson);
      setState(() {
        _selectedParkingSpace = ParkingSpace.fromJson(parkingSpaceData);
      });
    }

// Load logged in person
    final loggedInPersonName = prefs.getString('loggedInName');
    final loggedInPersonNum = prefs.getString('loggedInPersonNum');
    final loggedInPersonID = prefs.getInt('loggedInPersonID');

    // Check if loggedInPersonName and loggedInPersonNum are not null

    if (loggedInPersonName != null && loggedInPersonNum != null) {
      // Create a Person object
      var loggedInPerson = Person(
        id: loggedInPersonID ??
            0, // Assuming id is 0 or you can set it to any default value
        name: loggedInPersonName,
        personNumber: loggedInPersonNum,
      );

      // Convert the Person object to JSON
      final loggedInPersonJson = json.encode(loggedInPerson.toJson());

      // Save the JSON string to SharedPreferences
      await prefs.setString('loggedInPerson', loggedInPersonJson);

      // Load the JSON string from SharedPreferences
      final loadedLoggedInPersonJson = prefs.getString('loggedInPerson');

      if (loadedLoggedInPersonJson != null) {
        final Map<String, dynamic> personData =
            json.decode(loadedLoggedInPersonJson);
        setState(() {
          loggedInPerson = Person.fromJson(personData);
        });
      }
    }

    // Load active parking state
    final activeParkingJson = prefs.getString('activeParkingSpace');
    final isParkingActive = prefs.getBool('isParkingActive') ?? false;

    if (activeParkingJson != null && isParkingActive) {
      final Map<String, dynamic> activeParkingData =
          json.decode(activeParkingJson);
      setState(() {
        _selectedParkingSpace = ParkingSpace.fromJson(activeParkingData);
        _isParkingActive = true;
      });
    }
  }

  Future<void> _saveSelectedParkingSpace(ParkingSpace parkingSpace) async {
    final prefs = await SharedPreferences.getInstance();
    final parkingSpaceJson = json.encode(parkingSpace.toJson());

    await prefs.setString('selectedParkingSpace', parkingSpaceJson);
    setState(() {
      _selectedParkingSpace = parkingSpace;
    });
  }

  void _refreshParkingSpaces() {
    setState(() {
      _parkingSpacesFuture =
          ParkingSpaceRepository.instance.getAllParkingSpaces();
    });
  }

  void _checkSelectedVehicle(Function action) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedVehicleJson = prefs.getString('selectedVehicle');

    if (selectedVehicleJson == null) {
      // Show a message if no vehicle is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Välj först en fordon"),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Perform the action if a vehicle is selected
      action();
    }
  }

  void _clearSelectedParkingSpace() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedParkingSpace');
    setState(() {
      _selectedParkingSpace = null;
      _isParkingActive = false;
    });
  }

  // Future<int> _getNextParkingId() async {
  //   final parkingRepository = ParkingRepository.instance;
  //   final parkingList = await parkingRepository.getAllParkings();
  //   return parkingList.length + 1;
  // }

  // Future<int> _getNextParkingId() async {
  //   final parkingRepository = ParkingRepository.instance;
  //   final parkingList = await parkingRepository.getAllParkings();
  //   return parkingList.length < 2147483647
  //       ? parkingList.length + 1
  //       : throw FormatException('Parking ID exceeds maximum integer size');
  // }

  Future<int> _getNextParkingId() async {
    final parkingList = await ParkingRepository.instance.getAllParkings();
    final parkingsMap = {for (var parking in parkingList) parking.id: parking};
    final lastParkingId = parkingsMap.keys.last;
    return lastParkingId + 1;
  }

  Future<void> _startParking() async {
    final prefs = await SharedPreferences.getInstance();
    // Person Info
    final loggedInPersonJson = prefs.getString('loggedInPerson');
    final loggedInPersonID = prefs.getInt('loggedInPersonID');
    final loggedInPersonName = prefs.getString('loggedInName');
    final loggedInPersonNum = prefs.getString('loggedInPersonNum');

    // Vehicle Info
    final selectedVehicleJson = prefs.getString('selectedVehicle');

    // Parking Space Info
    final selectedParkingSpaceJson = prefs.getString('selectedParkingSpace');

    if (selectedVehicleJson == null || loggedInPersonJson == null) {
      // Show a message if no vehicle or user is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Välj först ett fordon och en användare"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_selectedParkingSpace == null) return;

    final selectedVehicle = Vehicle.fromJson(json.decode(selectedVehicleJson));
    // final loggedInPerson = Person.fromJson(json.decode(loggedInPersonJson));
    final selectedParkingSpace =
        ParkingSpace.fromJson(json.decode(selectedParkingSpaceJson!));

    // Get the next parking ID
    // final nextParkingId = await _getNextParkingId();

    final nextParkingId = await _getNextParkingId();
    final parkingInstance = Parking(
      id: nextParkingId, //
      // nextParkingId, // Use the next parking ID
      vehicle: Vehicle(
        id: selectedVehicle.id, // Default to -1 if id is missing
        regNumber: selectedVehicle.regNumber, // Default to empty string
        vehicleType: selectedVehicle.vehicleType, // Default to empty string
        owner: Person(
          id: loggedInPersonID!,
          name: loggedInPersonName ??
              '', // Default to empty string if name is missing
          personNumber: loggedInPersonNum ?? '', // Default if missing
        ),
      ),
      parkingSpace: ParkingSpace(
        id: selectedParkingSpace.id,
        address: selectedParkingSpace.address,
        pricePerHour: selectedParkingSpace.pricePerHour,
      ),
      //selectedParkingSpace,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
    );
    _showSavedInfo();
    // Save the parking instance to SharedPreferences
    await ParkingRepository.instance.createParking(parkingInstance);

    await prefs.setString('parking', json.encode(parkingInstance.toJson()));

    // Add the parking instance to the ParkingRepository

    // Save the selected parking space to preferences when parking starts
    final parkingSpaceJson = json.encode(_selectedParkingSpace!.toJson());
    await prefs.setString('activeParkingSpace', parkingSpaceJson);
    await prefs.setBool('isParkingActive', true);

    // Update the UI to reflect that parking has started
    setState(() {
      _isParkingActive = true;
      _showSavedInfo();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Parkering startad framgångsrikt")),
    );
  }

  Future<void> _stopParking() async {
    final prefs = await SharedPreferences.getInstance();
    final parkingJson = prefs.getString('parking');

    if (parkingJson == null) return;

    final parkingInstance = Parking.fromJson(json.decode(parkingJson));

    // Remove the parking instance from the ParkingRepository
    final parkingRepository = ParkingRepository.instance;
    await parkingRepository.deleteParking(parkingInstance.id);

    // Clear parking data from SharedPreferences
    await prefs.remove('parking');
    await prefs.remove('activeParkingSpace');
    await prefs.setBool('isParkingActive', false);

    // Update the UI to reflect that parking has stopped
    setState(() {
      _isParkingActive = false;
      _selectedParkingSpace = null;
      // _showSavedInfo();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Parkering stoppad framgångsrikt")),
    );
  }

  void _toggleParkingState() async {
    if (_isParkingActive) {
      await _stopParking();
    } else {
      await _startParking();
    }
  }

  void _showSavedInfo() async {
    final prefs = await SharedPreferences.getInstance();

    // Person info
    var loggedInName = prefs.getString('loggedInName');
    var loggedInPersonNum = prefs.getString('loggedInPersonNum');
    var loggedInPersonID = prefs.getInt('loggedInPersonID') ?? '';

// Vehicle info
    var selectedVehicleJson = prefs.getString('selectedVehicle');
    final selectedVehicle = Vehicle.fromJson(json.decode(selectedVehicleJson!));
// ParkingSpace info
    var parkingSpaceJson = prefs.getString('selectedParkingSpace');
    final selectedParkingSpace =
        ParkingSpace.fromJson(json.decode(parkingSpaceJson!));

    // Parking info
    var parkingJson = prefs.getString('parking');
    final selectedParking = Parking.fromJson(json.decode(parkingJson!));

    debugPrintSynchronously('Person Name: $loggedInName');
    debugPrintSynchronously('Person Number: $loggedInPersonNum');
    debugPrintSynchronously('Person ID: $loggedInPersonID');

    debugPrintSynchronously('Vehicle ID: ${selectedVehicle.id}');
    debugPrintSynchronously('Vehicle RegNumber: ${selectedVehicle.regNumber}');
    debugPrintSynchronously('Vehicle Type: ${selectedVehicle.vehicleType}');

    debugPrintSynchronously('ParkingSpace ID: ${selectedParkingSpace.id}');
    debugPrintSynchronously(
        'ParkingSpace address: ${selectedParkingSpace.address}');
    debugPrintSynchronously(
        'ParkingSpace pricePerHour: ${selectedParkingSpace.pricePerHour}');

    debugPrintSynchronously('Parking ID: ${selectedParking.id}');
    debugPrintSynchronously('Parking startTime: ${selectedParking.startTime}');
    debugPrintSynchronously('Parking endTime: ${selectedParking.endTime}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Välj en Parkeringsplats"),
      ),
      body: FutureBuilder<List<ParkingSpace>>(
        future: _parkingSpacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Fel: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Inga parkeringsplatser tillgängliga.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final parkingSpaces = snapshot.data!;
          return Column(
            children: [
              if (_selectedParkingSpace != null)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: _isParkingActive
                      ? Colors.red.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  child: Text(
                    _isParkingActive
                        ? 'Du startade parkeringen på:\n'
                            'Parkeringsplats ID: ${_selectedParkingSpace!.id}\n'
                            'Address: ${_selectedParkingSpace!.address}\n'
                            'Pris per timme: ${_selectedParkingSpace!.pricePerHour} SEK'
                        : 'Vald parkeringsplats:\n'
                            'ID: ${_selectedParkingSpace!.id}\n'
                            'Address: ${_selectedParkingSpace!.address}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: parkingSpaces.length,
                  itemBuilder: (context, index) {
                    final parkingSpace = parkingSpaces[index];
                    final isSelected =
                        _selectedParkingSpace?.id == parkingSpace.id;
                    return ListTile(
                      title: Text(
                        'Parkeringsplats ID: ${parkingSpace.id}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address: ${parkingSpace.address}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Pris per timme: ${parkingSpace.pricePerHour} SEK',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: _isParkingActive && !isSelected
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Stoppa parkeringen först"),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                : () {
                                    _checkSelectedVehicle(() {
                                      if (isSelected) {
                                        _clearSelectedParkingSpace();
                                      } else {
                                        _saveSelectedParkingSpace(parkingSpace);
                                      }
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected ? Colors.green : Colors.blue,
                            ),
                            child: Text(isSelected ? "Valt" : "Välj"),
                          ),
                          const SizedBox(width: 10),
                          if (isSelected)
                            ElevatedButton(
                              onPressed: () {
                                _checkSelectedVehicle(_toggleParkingState);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isParkingActive
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                              child: Text(_isParkingActive
                                  ? "Stoppa Parkering"
                                  : "Starta Parkering"),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
