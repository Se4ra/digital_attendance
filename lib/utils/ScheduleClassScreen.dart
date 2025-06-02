import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class ScheduleClassScreen extends StatefulWidget {
  @override
  _ScheduleClassScreenState createState() => _ScheduleClassScreenState();
}

class _ScheduleClassScreenState extends State<ScheduleClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  LatLng selectedLocation = LatLng(-15.3875, 28.3228); // Default: Lusaka
  String? generatedQRData;

  void _generateQRCode() {
    if (_formKey.currentState!.validate()) {
      final qrData = {
        'courseName': _courseNameController.text,
        'courseCode': _courseCodeController.text,
        'time': _timeController.text,
        'lat': selectedLocation.latitude,
        'lng': selectedLocation.longitude,
      };

      setState(() {
        generatedQRData = jsonEncode(qrData); // JSON format
      });
    }
  }

  void _openInGoogleMaps() {
    final lat = selectedLocation.latitude;
    final lng = selectedLocation.longitude;
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    // Show a dialog with a link (or use url_launcher package if enabled)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Open in Maps"),
        content: Text("Open location in Google Maps:\n\n$googleMapsUrl"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Class"),
        backgroundColor: const Color(0xFF064469),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _courseNameController,
                    decoration: const InputDecoration(labelText: "Course Name"),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _courseCodeController,
                    decoration: const InputDecoration(labelText: "Course Code"),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(labelText: "Time (e.g. 09:00 AM)"),
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Class Location", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: FlutterMap(
                      options: MapOptions(
                        center: selectedLocation,
                        zoom: 15.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            selectedLocation = point;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLocation,
                              width: 50,
                              height: 50,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Selected Location:\nLat: ${selectedLocation.latitude.toStringAsFixed(5)}, "
                        "Lng: ${selectedLocation.longitude.toStringAsFixed(5)}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _openInGoogleMaps,
                    icon: const Icon(Icons.map),
                    label: const Text("Preview in Google Maps"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _generateQRCode,
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Generate QR Code"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064469)),
                  ),
                  const SizedBox(height: 20),
                  if (generatedQRData != null)
                    Column(
                      children: [
                        const Text("QR Code for Class"),
                        const SizedBox(height: 10),
                        QrImageView(
                          data: generatedQRData!,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
