
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import LatLng

@immutable
class Course {
  final String id;
  final String name;
  final String code;
  final int students;
  final LatLng? pinnedLocation; // Use LatLng from google_maps_flutter

  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.students,
    this.pinnedLocation,
  });


  Course copyWith({
    String? id,
    String? name,
    String? code,
    int? students,
    LatLng? pinnedLocation, // Nullable LatLng for optional update
    bool forceNullLocation = false, // Flag to explicitly remove location
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      students: students ?? this.students,
      pinnedLocation: forceNullLocation ? null : (pinnedLocation ?? this.pinnedLocation),
    );
  }
}
