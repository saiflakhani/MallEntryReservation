class Slot {
  final DateTime date;
  final int midday, afternoon, evening, late_evening;

  Slot({this.date, this.midday, this.afternoon, this.evening, this.late_evening});

  factory Slot.fromJson(Map<String, dynamic> json){
    var duration = new Duration(hours: 5, minutes: 30); //IST
    return Slot(
      date: DateTime.parse(json['date'].toString()).add(duration),
      midday: json['midday'],
      afternoon: json['afternoon'],
      evening: json['evening'],
      late_evening: json['late_evening']
    );
  }
}