import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import 'database_service.dart';
import '../models/sample.dart';

class ExportService {
  Future<void> exportDataset() async {
    final List<Sample> samples = await DatabaseService().getSamples();
    
    // 1. Create CSV
    List<List<dynamic>> rows = [];
    rows.add([
      'id', 'filename', 'disease_label', 'stage', 
      'n', 'p', 'k', 'ph', 'ec', 'moisture', 'temp', 
      'location', 'date', 'notes'
    ]);

    for (var sample in samples) {
      rows.add([
        sample.id, sample.filename, sample.diseaseLabel, sample.stage,
        sample.n, sample.p, sample.k, sample.ph, sample.ec, sample.moisture, sample.temp,
        sample.location, sample.date, sample.notes
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    // 2. Prepare Directories
    final directory = await getApplicationDocumentsDirectory();
    final tempDir = await Directory('${directory.path}/export_temp').create();
    final imagesDir = Directory('${directory.path}/images');

    // 3. Save CSV to temp
    final csvFile = File('${tempDir.path}/dataset.csv');
    await csvFile.writeAsString(csvData);

    // 4. Create images subfolder in temp
    final tempImagesDir = await Directory('${tempDir.path}/images').create();

    // 5. Copy images to temp
    if (await imagesDir.exists()) {
      await for (var file in imagesDir.list()) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          await file.copy('${tempImagesDir.path}/$fileName');
        }
      }
    }

    // 6. Zip the temp directory
    final encoder = ZipFileEncoder();
    final zipPath = '${directory.path}/BellPepper_Dataset.zip';
    encoder.create(zipPath);
    encoder.addDirectory(tempDir);
    encoder.close();

    // 7. Share the Zip
    await Share.shareXFiles([XFile(zipPath)], text: 'Bell Pepper Research Dataset');

    // 8. Cleanup temp
    await tempDir.delete(recursive: true);
  }
}
