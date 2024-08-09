import 'dart:convert';
import 'dart:io';

class Subject {
  String name;
  List<int> scores;

  Subject({required this.name, required this.scores});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      scores: List<int>.from(json['scores']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'scores': scores,
  };
}

class Student {
  int id;
  String name;
  List<Subject> subjects;

  Student({required this.id, required this.name, required this.subjects});

  factory Student.fromJson(Map<String, dynamic> json) {
    var list = json['subjects'] as List;
    List<Subject> subjectList = list.map((i) => Subject.fromJson(i)).toList();

    return Student(
      id: json['id'],
      name: json['name'],
      subjects: subjectList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subjects': subjects.map((subject) => subject.toJson()).toList(),
  };
}

class StudentManager {
  List<Student> students = [];

  // Load dữ liệu từ file JSON
  void loadData() {
    final file = File('Student.json');
    if (file.existsSync()) {
      final data = jsonDecode(file.readAsStringSync());
      var studentList = data['students'] as List;
      students = studentList.map((student) => Student.fromJson(student)).toList();
    }
  }

  // Lưu dữ liệu vào file JSON
  void saveData() {
    final file = File('Student.json');
    final data = {
      'students': students.map((student) => student.toJson()).toList(),
    };
    file.writeAsStringSync(jsonEncode(data));
  }

  // Hiển thị toàn bộ sinh viên
  void displayAllStudents() {
    for (var student in students) {
      print('ID: ${student.id}, Name: ${student.name}');
      for (var subject in student.subjects) {
        print('Subject: ${subject.name}, Scores: ${subject.scores.join(", ")}');
      }
      print(''); // Thêm dòng trống giữa các sinh viên
    }
  }

  // Thêm sinh viên mới
  void addStudent() {
    print('Enter student ID:');
    int id = int.parse(stdin.readLineSync()!);
    print('Enter student name:');
    String name = stdin.readLineSync()!;
    List<Subject> subjects = [];

    while (true) {
      print('Enter subject name (or "done" to finish):');
      String subjectName = stdin.readLineSync()!;
      if (subjectName.toLowerCase() == 'done') break;

      print('Enter scores for $subjectName (comma separated):');
      List<int> scores = stdin.readLineSync()!.split(',').map((s) => int.parse(s.trim())).toList();

      subjects.add(Subject(name: subjectName, scores: scores));
    }

    students.add(Student(id: id, name: name, subjects: subjects));
    saveData();
    print('Student added successfully.');
  }

  // Tìm kiếm sinh viên theo ID hoặc tên
  void searchStudent() {
    print('Enter student ID or Name to search:');
    String query = stdin.readLineSync()!;

    List<Student> results = students.where((student) =>
    student.id.toString() == query || student.name.toLowerCase() == query.toLowerCase()).toList();

    if (results.isNotEmpty) {
      for (var student in results) {
        print('ID: ${student.id}, Name: ${student.name}');
        for (var subject in student.subjects) {
          print('Subject: ${subject.name}, Scores: ${subject.scores.join(", ")}');
        }
      }
    } else {
      print('No student found with that ID or Name.');
    }
  }

  // Sửa thông tin sinh viên
  void editStudent() {
    print('Enter student ID or Name to edit:');
    String query = stdin.readLineSync()!;

    // Tìm sinh viên theo ID hoặc tên
    Student? student = students.firstWhere(
          (student) => student.id.toString() == query || student.name.toLowerCase() == query.toLowerCase(),
      orElse: () => null,
    );

    if (student != null) {
      print('Editing student: ID: ${student.id}, Name: ${student.name}');

      // Cho phép người dùng chỉnh sửa tên sinh viên
      print('Enter new name (leave blank to keep current):');
      String newName = stdin.readLineSync()!;
      if (newName.isNotEmpty) {
        student.name = newName;
      }

      // Chỉnh sửa các môn học
      for (var subject in student.subjects) {
        print('Subject: ${subject.name}, Current Scores: ${subject.scores.join(", ")}');
        print('Enter new scores for ${subject.name} (comma separated, leave blank to keep current):');
        String newScores = stdin.readLineSync()!;
        if (newScores.isNotEmpty) {
          subject.scores = newScores.split(',').map((s) => int.parse(s.trim())).toList();
        }
      }

      saveData();
      print('Student information updated successfully.');
    } else {
      print('No student found with that ID or Name.');
    }
  }

  // Hiển thị sinh viên có điểm thi môn cao nhất
  void displayTopScorers() {
    for (var subject in students.expand((student) => student.subjects).map((s) => s.name).toSet()) {
      Student? topStudent;
      int topScore = -1;

      for (var student in students) {
        var subj = student.subjects.firstWhere(
              (sub) => sub.name == subject,
          orElse: () => Subject(name: '', scores: []),
        );

        if (subj.name.isNotEmpty && subj.scores.isNotEmpty) {
          var maxScore = subj.scores.reduce((a, b) => a > b ? a : b);
          if (maxScore > topScore) {
            topScore = maxScore;
            topStudent = student;
          }
        }
      }

      if (topStudent != null) {
        print('Top scorer in $subject: ${topStudent.name} with score $topScore');
      }
    }
  }
}

void main() {
  var manager = StudentManager();
  manager.loadData();

  while (true) {
    print('''
Menu:
1. Display all students
2. Add a student
3. Search for a student by ID or Name
4. Edit a student
5. Display top scorers
6. Exit
Choose an option:
    ''');

    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        manager.displayAllStudents();
        break;
      case 2:
        manager.addStudent();
        break;
      case 3:
        manager.searchStudent();
        break;
      case 4:
        manager.editStudent();
        break;
      case 5:
        manager.displayTopScorers();
        break;
      case 6:
        exit(0);
      default:
        print('Invalid choice. Please try again.');
    }
  }
}
