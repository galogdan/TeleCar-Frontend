class Vehicle {
  final String carId;
  final String? color;
  final String? brend;
  final String? model;
  final int? year;

  Vehicle({
    required this.carId,
    this.color,
    this.brend,
    this.model,
    this.year
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
        carId: json['carId'],
        color: json['color'],
        brend: json['brend'],
        model: json['model'],
        year : json['year']
    );
  }

  Map<String, dynamic> toJson() => {
    'carId': carId,
    'color': color,
    'brend': brend,
    'model': model,
    'year' : year
  };
}
