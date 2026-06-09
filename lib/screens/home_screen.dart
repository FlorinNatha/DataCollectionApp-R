import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sample.dart';
import '../services/export_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalRecords = 0;
  bool _isExporting = false;
  Map<String, int> _diseaseCounts = {};
  double _avgN = 0;
  double _avgP = 0;
  double _avgK = 0;
  double _avgMoisture = 0;
  double _avgTemp = 0;
  double _avgPH = 0;
  double _avgEC = 0;
  String _lastSampleDate = 'No samples yet';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final samples = await DatabaseService().getSamples();
    final counts = <String, int>{};
    double totalN = 0;
    double totalP = 0;
    double totalK = 0;
    double totalMoisture = 0;
    double totalTemp = 0;
    double totalPH = 0;
    double totalEC = 0;

    for (final sample in samples) {
      counts[sample.diseaseLabel] = (counts[sample.diseaseLabel] ?? 0) + 1;
      totalN += sample.n;
      totalP += sample.p;
      totalK += sample.k;
      totalMoisture += sample.moisture;
      totalTemp += sample.temp;
      totalPH += sample.ph;
      totalEC += sample.ec;
    }

    setState(() {
      _totalRecords = samples.length;
      _diseaseCounts = counts;
      _avgN = samples.isNotEmpty ? totalN / samples.length : 0;
      _avgP = samples.isNotEmpty ? totalP / samples.length : 0;
      _avgK = samples.isNotEmpty ? totalK / samples.length : 0;
      _avgMoisture = samples.isNotEmpty ? totalMoisture / samples.length : 0;
      _avgTemp = samples.isNotEmpty ? totalTemp / samples.length : 0;
      _avgPH = samples.isNotEmpty ? totalPH / samples.length : 0;
      _avgEC = samples.isNotEmpty ? totalEC / samples.length : 0;
      _lastSampleDate = samples.isNotEmpty
          ? DateFormat('MMM d, yyyy • h:mm a').format(DateTime.parse(samples.first.date))
          : 'No samples yet';
    });
  }

  Future<void> _exportDataset() async {
    setState(() {
      _isExporting = true;
    });

    try {
      await ExportService().exportDataset();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dataset export complete.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
      });
    }
  }

  String _formatSensor(double value) {
    return value > 0 ? value.toStringAsFixed(1) : '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bell Pepper Data Collector'),
        backgroundColor: Colors.green[700],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Center(
              child: Icon(Icons.eco, size: 100, color: Colors.green[800]),
            ),
            SizedBox(height: 20),
            Text(
              'FYP Research Tool',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey[900]),
            ),
            SizedBox(height: 10),
            Text(
              'A clean and reliable dataset tracker for bell pepper field research.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            _buildSummaryCard(),
            SizedBox(height: 20),
            _buildStatCard('Last sample collected', _lastSampleDate, Icons.schedule),
            SizedBox(height: 20),
            _buildSensorCard(),
            SizedBox(height: 20),
            _buildDiseaseBreakdownCard(),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportDataset,
              icon: _isExporting ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white)) : Icon(Icons.share),
              label: Text(_isExporting ? 'EXPORTING...' : 'EXPORT DATASET'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Pull down to refresh sample stats.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryValue('Samples', _totalRecords.toString()),
                _buildSummaryValue('Avg N', _formatSensor(_avgN)),
                _buildSummaryValue('Avg P', _formatSensor(_avgP)),
                _buildSummaryValue('Avg K', _formatSensor(_avgK)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900])),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green[50],
              child: Icon(icon, color: Colors.green[700], size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[900])),
                  SizedBox(height: 6),
                  Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Environmental & Soil Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[900])),
            SizedBox(height: 12),
            Row(
              children: [
                _buildEnvStat('Moisture', _formatSensor(_avgMoisture), '%'),
                _buildEnvStat('Temp', _formatSensor(_avgTemp), '°C'),
                _buildEnvStat('pH', _formatSensor(_avgPH), ''),
                _buildEnvStat('EC', _formatSensor(_avgEC), 'ms/cm'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvStat(String label, String value, String unit) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
              if (unit.isNotEmpty)
                Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseBreakdownCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disease counts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[900])),
            SizedBox(height: 12),
            if (_diseaseCounts.isEmpty)
              Text('No disease labels available yet.', style: TextStyle(color: Colors.grey[600]))
            else
              Column(
                children: _diseaseCounts.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(entry.key, style: TextStyle(fontSize: 14, color: Colors.grey[800]))),
                        Text(entry.value.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
