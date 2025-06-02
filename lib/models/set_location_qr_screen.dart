import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:digital_attendance_system/utils/map_location_picker.dart';

void main() {
  runApp(MaterialApp(
    home: SetLocationQRScreen(classCode: 'Class123'),
  ));
}

class SetLocationQRScreen extends StatefulWidget {
  final String classCode;

  const SetLocationQRScreen({super.key, required this.classCode});

  @override
  State<SetLocationQRScreen> createState() => _SetLocationQRScreenState();
}

class _SetLocationQRScreenState extends State<SetLocationQRScreen> {
  String? _qrData;
  String? _locationText;

  Future<void> _openMapPicker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(
          onLocationSelected: (location, qr) {
            setState(() {
              _qrData = qr;
              _locationText = "${location.latitude}, ${location.longitude}";
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Location selected and QR generated!"),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationTile() {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(
        _locationText ?? 'No location selected',
        style: TextStyle(
          color: _locationText != null ? Colors.black : Colors.grey,
        ),
      ),
      trailing: ElevatedButton.icon(
        icon: const Icon(Icons.map),
        label: const Text('Pick Location'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF064469),
        ),
        onPressed: _openMapPicker,
      ),
    );
  }

  Widget _buildQRSection() {
    if (_qrData == null) {
      return const Text("No QR code generated yet.");
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Scan this QR in class",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        QrImageView(
          data: _qrData!,
          version: QrVersions.auto,
          size: 200.0,
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 10),
        Text(
          _qrData!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Location & Generate QR'),
        backgroundColor: const Color(0xFF064469),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationTile(),
            const SizedBox(height: 30),
            Center(child: _buildQRSection()),
          ],
        ),
      ),
    );
  }
}
