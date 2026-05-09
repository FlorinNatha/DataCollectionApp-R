import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/sample.dart';
import '../services/database_service.dart';

class AddSampleScreen extends StatefulWidget {
  @override
  _AddSampleScreenState createState() => _AddSampleScreenState();
}

class _AddSampleScreenState extends State<AddSampleScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final picker = ImagePicker();

  // Form controllers
  String _diseaseLabel = 'Bacterial Spot';
  String _stage = 'Early';
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  final _phController = TextEditingController();
  final _ecController = TextEditingController();
  final _moistureController = TextEditingController();
  final _tempController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _diseases = [
    'Bacterial Spot',
    'Anthracnose',
    'Powdery Mildew',
    'Leaf Curl',
    'Cercospora Leaf Spot',
    'Healthy'
  ];

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveSample() async {
    if (_formKey.currentState!.validate() && _image != null) {
      // 1. Save image to local app folder
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = await Directory('${directory.path}/images').create();
      final String fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File localImage = await _image!.copy('${imagesDir.path}/$fileName');

      // 2. Create sample object
      final sample = Sample(
        filename: fileName,
        diseaseLabel: _diseaseLabel,
        stage: _stage,
        n: double.parse(_nController.text),
        p: double.parse(_pController.text),
        k: double.parse(_kController.text),
        ph: double.parse(_phController.text),
        ec: double.parse(_ecController.text),
        moisture: double.parse(_moistureController.text),
        temp: double.parse(_tempController.text),
        location: _locationController.text,
        date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        notes: _notesController.text,
      );

      // 3. Save to database
      await DatabaseService().insertSample(sample);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sample saved successfully!')),
      );
      Navigator.pop(context);
    } else if (_image == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please take a photo first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Sample')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            Text('Tap to add leaf photo'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
              SizedBox(height: 20),

              // Disease Label
              DropdownButtonFormField(
                value: _diseaseLabel,
                decoration: InputDecoration(labelText: 'Disease Label'),
                items: _diseases.map((String disease) {
                  return DropdownMenuItem(value: disease, child: Text(disease));
                }).toList(),
                onChanged: (val) => setState(() => _diseaseLabel = val as String),
              ),
              SizedBox(height: 10),

              // Stage
              Row(
                children: [
                  Text('Stage: '),
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Early', label: Text('Early')),
                        ButtonSegment(value: 'Mid', label: Text('Mid')),
                        ButtonSegment(value: 'Late', label: Text('Late')),
                      ],
                      selected: {_stage},
                      onSelectionChanged: (val) => setState(() => _stage = val.first),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Text('Sensor Data (7-in-1 NPK Sensor)', 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
              Divider(),
              
              Row(
                children: [
                  Expanded(child: _buildNumberField(_nController, 'N (Nitrogen)')),
                  SizedBox(width: 10),
                  Expanded(child: _buildNumberField(_pController, 'P (Phosphorus)')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildNumberField(_kController, 'K (Potassium)')),
                  SizedBox(width: 10),
                  Expanded(child: _buildNumberField(_phController, 'pH Level')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildNumberField(_ecController, 'EC (ms/cm)')),
                  SizedBox(width: 10),
                  Expanded(child: _buildNumberField(_moistureController, 'Moisture %')),
                ],
              ),
              _buildNumberField(_tempController, 'Temperature (°C)'),
              
              SizedBox(height: 20),
              Text('Field Details', 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
              Divider(),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Farm Location'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveSample,
                child: Text('SAVE RECORD'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
