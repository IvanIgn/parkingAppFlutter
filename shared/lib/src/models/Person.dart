import 'package:objectbox/objectbox.dart';

@Entity()
class Person {
  @Id()
  int id;
  String name;
  String personNumber;

  Person({
    required this.name,
    required this.personNumber,
    this.id = 0, // Default to -1 for unassigned ID
  });

  // Factory constructor to create a Person from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? 0, // Default to -1 if id is missing
      name: json['name'] ?? '', // Default to empty string if name is missing
      personNumber: json['personNumber'] ?? '', // Default if missing
    );
  }

  // Convert a Person object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "personNumber": personNumber,
    };
  }
}
