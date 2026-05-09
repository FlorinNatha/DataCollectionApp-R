import 'package:flutter/material.dart';
import 'add_sample_screen.dart';
import 'records_screen.dart';
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
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddSampleScreen()),
                );
                _loadStats();
              },
              icon: Icon(Icons.add_a_photo),
              label: Text('ADD NEW SAMPLE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordsScreen()),
                ).then((_) => _loadStats());
              },
              icon: Icon(Icons.list_alt),
              label: Text('VIEW ALL RECORDS'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[800],
                side: BorderSide(color: Colors.green[800]!),
                padding: EdgeInsets.symmetric(vertical: 15),
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
