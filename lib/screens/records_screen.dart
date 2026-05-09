import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sample.dart';
import '../services/database_service.dart';

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
      _samplesFuture = DatabaseService().getSamples();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Collected Records')),
      body: FutureBuilder<List<Sample>>(
        future: _samplesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No records found. Start collecting!'));
          }

          final samples = snapshot.data!;
          return ListView.builder(
            itemCount: samples.length,
            itemBuilder: (context, index) {
              final sample = samples[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: FileImage(File('$_imagePath${sample.filename}')),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(sample.diseaseLabel, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${sample.location} | ${sample.date}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[300]),
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
