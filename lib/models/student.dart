class Student {
  final int? studentId;
  final String name;
  final String ra;
  final String email;
  final int? courseId; // Identificador do curso vinculado

  Student({
    this.studentId,
    required this.name,
    required this.ra,
    required this.email,
    this.courseId,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'ra': ra,
      'email': email,
      'courseId': courseId, // Salva o vínculo no banco
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['studentId'],
      name: map['name'],
      ra: map['ra'],
      email: map['email'],
      courseId: map['courseId'], // Recupera o vínculo do banco
    );
  }
}
