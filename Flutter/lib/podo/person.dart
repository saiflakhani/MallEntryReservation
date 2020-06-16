class Person {
  final int id;
  final String person_name, contact, location;
  final int recurring, flagged;
  final String password;
  //bool passwordMatched = false;

  Person({this.person_name, this.contact, this.location, this.password, this.recurring, this.flagged, this.id});

  factory Person.fromJson(Map<String, dynamic> json){
    return Person(
      person_name: json['person_name'],
      contact: json['contact'],
      location: json['location'],
      id: json['id'],
      recurring: json['recurring'],
      flagged: json['flagged']
      //passwordMatched: json['location'],
    );
  }

  Map<String, dynamic> toJson() =>
  {
    'person_name' : person_name,
    'contact' : contact,
    'location' : location,
    'password': password,
    'id': id
  };
}