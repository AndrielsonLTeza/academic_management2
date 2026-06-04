class Student {
  final int? studentId;
  final String name;
  final String ra;
  final String email;

  Student({
    this.studentId,
    required this.name,
    required this.ra,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {'studentId': studentId, 'name': name, 'ra': ra, 'email': email};
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['studentId'],
      name: map['name'],
      ra: map['ra'],
      email: map['email'],
    );
  }
}
