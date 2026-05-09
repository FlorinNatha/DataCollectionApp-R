class Sample {
  final int? id;
  final String filename;
  final String diseaseLabel;
  final String stage;
  final double n;
  final double p;
  final double k;
  final double ph;
  final double ec;
  final double moisture;
  final double temp;
  final String location;
  final String date;
  final String notes;

  Sample({
    this.id,
    required this.filename,
    required this.diseaseLabel,
    required this.stage,
    required this.n,
    required this.p,
    required this.k,
    required this.ph,
    required this.ec,
    required this.moisture,
    required this.temp,
    required this.location,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'disease_label': diseaseLabel,
      'stage': stage,
      'n': n,
      'p': p,
      'k': k,
      'ph': ph,
      'ec': ec,
      'moisture': moisture,
      'temp': temp,
      'location': location,
      'date': date,
      'notes': notes,
    };
  }

  factory Sample.fromMap(Map<String, dynamic> map) {
    return Sample(
      id: map['id'],
      filename: map['filename'],
      diseaseLabel: map['disease_label'],
      stage: map['stage'],
      n: map['n'],
      p: map['p'],
      k: map['k'],
      ph: map['ph'],
      ec: map['ec'],
      moisture: map['moisture'],
      temp: map['temp'],
      location: map['location'],
      date: map['date'],
      notes: map['notes'],
    );
  }
}
