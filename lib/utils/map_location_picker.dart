import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MapLocationPicker extends StatefulWidget {
  final Function(LatLng location, String qrData) onLocationSelected;

  const MapLocationPicker({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  _MapLocationPickerState createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng? selectedLocation;

  void _generateQrAndSubmit() {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on the map to select location')),
      );
      return;
    }

    final qrData =
        'class_location:${selectedLocation!.latitude},${selectedLocation!.longitude}-${DateTime.now().toIso8601String()}';

    widget.onLocationSelected(selectedLocation!, qrData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Class Location'),
        backgroundColor: const Color(0xFF064469),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(-15.3875, 28.3228), // Lusaka default
                zoom: 15.0,
                onTap: (_, latlng) {
                  setState(() {
                    selectedLocation = latlng;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),

                    ],
                  ),
              ],
            ),
          ),
          if (selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: QrImageView(
                data:
                'class_location:${selectedLocation!.latitude},${selectedLocation!.longitude}-${DateTime.now().toIso8601String()}',
                version: QrVersions.auto,
                size: 150.0,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064469),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _generateQrAndSubmit,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR & Save Location'),
            ),
          ),
        ],
      ),
    );
  }
}
