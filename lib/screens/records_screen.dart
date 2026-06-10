import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sample.dart';
import '../services/database_service.dart';
import '../widgets/tree_loader.dart';

class RecordsScreen extends StatefulWidget {
  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  late Future<List<Sample>> _samplesFuture;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final dir = await getApplicationDocumentsDirectory();
    setState(() {
      _imagePath = '${dir.path}/images/';
      // Added a 2-second delay so you can see the animated tree loader!
      _samplesFuture = Future.delayed(Duration(seconds: 2)).then((_) => DatabaseService().getSamples());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collected Records'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<Sample>>(
        future: _samplesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: TreeLoader());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.green[200]),
                    SizedBox(height: 20),
                    Text(
                      'No records yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tap Add Sample to start collecting bell pepper data with image and sensor values.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            );
          }

          final samples = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: samples.length,
            itemBuilder: (context, index) {
              final sample = samples[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: Image.file(
                        File('$_imagePath${sample.filename}'),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  title: Text(sample.diseaseLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  subtitle: Text('${sample.location} • ${sample.date}', style: TextStyle(color: Colors.grey[700])),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[400]),
                    onPressed: () => _confirmDelete(sample),
                  ),
                  onTap: () => _showDetails(sample),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(Sample sample) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record?'),
        content: Text('Are you sure you want to delete this sample?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await DatabaseService().deleteSample(sample.id!);
              // Also delete image file
              final file = File('$_imagePath${sample.filename}');
              if (await file.exists()) await file.delete();
              
              Navigator.pop(context);
              setState(() {
                _samplesFuture = DatabaseService().getSamples();
              });
            },
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetails(Sample sample) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(File('$_imagePath${sample.filename}'), height: 200, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            Text(sample.diseaseLabel, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800])),
            Text('Stage: ${sample.stage}', style: TextStyle(fontSize: 16)),
            Divider(),
            Text('NPK Sensor Data:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('N: ${sample.n} | P: ${sample.p} | K: ${sample.k}'),
            Text('pH: ${sample.ph} | EC: ${sample.ec}'),
            Text('Moisture: ${sample.moisture}% | Temp: ${sample.temp}°C'),
            Divider(),
            Text('Field Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Location: ${sample.location}'),
            Text('Date: ${sample.date}'),
            if (sample.notes.isNotEmpty) Text('Notes: ${sample.notes}'),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('CLOSE')),
            )
          ],
        ),
      ),
    );
  }
}
