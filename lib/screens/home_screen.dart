import 'package:flutter/material.dart';
import '../services/export_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalRecords = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final samples = await DatabaseService().getSamples();
    setState(() {
      _totalRecords = samples.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bell Pepper Data Collector'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.eco, size: 100, color: Colors.green[800]),
            SizedBox(height: 20),
            Text(
              'FYP Research Tool',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Total Samples Collected: $_totalRecords',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),
            Text(
              'Use the bottom navigation to:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_a_photo, color: Colors.green[700], size: 24),
                        SizedBox(width: 10),
                        Expanded(child: Text('Add Sample - Capture leaf photos & sensor data')),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: Colors.green[700], size: 24),
                        SizedBox(width: 10),
                        Expanded(child: Text('Records - View all collected samples')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            TextButton.icon(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );
                await ExportService().exportDataset();
                Navigator.pop(context);
              },
              icon: Icon(Icons.share),
              label: Text('EXPORT DATASET (CSV + ZIP)'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue[800]),
            ),
          ],
        ),
      ),
    );
  }
}
