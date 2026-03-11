import 'dart:io';
import 'dart:math';

void main() {
  List<Student> students = [
    Student('Савенко', 'Никита', ['ОАИП', 'Компьютерные сети', 'Высшая математика'], [4, 5, 3]),
    Student('Губогло', 'Александр', ['ОАИП', 'Компьютерные сети', 'Высшая математика'], [5, 4, 5]),
    Student('Белов', 'Артем', ['ОАИП', 'Компьютерные сети', 'Высшая математика'], [2, 3, 4]),
    Student('Журавлев', 'Егор', ['ОАИП', 'Компьютерные сети', 'Высшая математика'], [5, 5, 5]),
    Student('Егиазарян', 'Артур', ['ОАИП', 'Компьютерные сети', 'Высшая математика'], [3, 2, 4]),
  ];

  print('Отчет по группе\n');

  printSvodnayaTable(students);

  print('\n' + '='*80 + '\n');

  print('2. Поиск студента');
  stdout.write('Введите фамилию или имя: ');
  String searchName = stdin.readLineSync()!.toLowerCase();
  searchStudent(students, searchName);

  print('\n' + '='*80 + '\n');

  printUniqueGrades(students);

  print('\n' + '='*80 + '\n');

  printMaxMinBySubject(students);

  print('\n' + '='*80 + '\n');

  printStudentsWithOneDeuce(students);

  print('\n' + '='*80 + '\n');

  printSubjectsAboveAverage(students);

  print('\n' + '='*80 + '\n');

  printCategoryStats(students);
}

class Student {
  String lastName;
  String firstName;
  List<String> subjects;
  List<int> grades;

  Student(this.lastName, this.firstName, this.subjects, this.grades);

  String get fullName => '$lastName $firstName';
  double get averageGrade => _calculateAverage();
  String get category => _getCategory();

  double _calculateAverage() {
    if (grades.isEmpty) return 0.0;
    return grades.reduce((a, b) => a + b) / grades.length;
  }

  String _getCategory() {
    double avg = averageGrade;
    if (avg >= 4.75) return 'Отличник';
    if (avg >= 3.75) return 'Хорошист';
    return 'Остальные';
  }

  int countDeuces() {
    return grades.where((g) => g == 2).length;
  }

  Map<String, int> getSubjectGrades() {
    Map<String, int> result = {};
    for (int i = 0; i < subjects.length; i++) {
      result[subjects[i]] = grades[i];
    }
    return result;
  }
}

void printSvodnayaTable(List<Student> students) {
  print('1. Сводная Таблица Оценок');
  
  Set<String> allSubjects = {};
  for (var student in students) {
    allSubjects.addAll(student.subjects);
  }
  List<String> subjectsList = allSubjects.toList();
  
  print('Студент\t\t${subjectsList.join('\t\t')}\tСредний');
  
  Map<String, List<int>> subjectGrades = {};
  for (String subject in subjectsList) {
    subjectGrades[subject] = [];
  }
  
  for (var student in students) {
    String row = '${student.fullName.padRight(12)}';
    for (String subject in subjectsList) {
      int grade = student.grades[student.subjects.indexOf(subject)];
      row += '${grade.toString().padRight(4)}';
      subjectGrades[subject]!.add(grade);
    }
    row += '${student.averageGrade.toStringAsFixed(2).padRight(8)}';
    print(row);
  }
  
  String avgRow = 'Средний\t\t';
  double overallAvg = 0;
  for (String subject in subjectsList) {
    double avg = subjectGrades[subject]!.reduce((a, b) => a + b) / subjectGrades[subject]!.length;
    avgRow += '${avg.toStringAsFixed(2).padRight(4)}';
    overallAvg += avg;
  }
  avgRow += '${(overallAvg / subjectsList.length).toStringAsFixed(2)}';
  print(avgRow);
}

void searchStudent(List<Student> students, String searchName) {
  List<Student> found = students.where((s) => 
    s.lastName.toLowerCase().contains(searchName) || 
    s.firstName.toLowerCase().contains(searchName)
  ).toList();
  
  if (found.isEmpty) {
    print('Студент не найден!');
    return;
  }
  
  for (var student in found) {
    print('\n${student.fullName}:');
    String gradesText = '';
    for (int i = 0; i < student.subjects.length; i++) {
      gradesText += '${student.subjects[i]}: ${student.grades[i]}';
       if (i < student.subjects.length - 1) gradesText += ', ';
    }
    print('Оценки: $gradesText');
    print('Средний балл: ${student.averageGrade.toStringAsFixed(2)}');
    print('Категория: ${student.category}');
  }
}

void printUniqueGrades(List<Student> students) {
  print('3. Уникальные оценки');
  Set<int> uniqueGrades = {};
  for (var student in students) {
    uniqueGrades.addAll(student.grades);
  }
  print(uniqueGrades.toList()..sort());
}

void printMaxMinBySubject(List<Student> students) {
  print('4. Максимум и минимум по предметам');
  
  Set<String> allSubjects = {};
  for (var student in students) {
    allSubjects.addAll(student.subjects);
  }
  
  for (String subject in allSubjects) {
    List<int> grades = [];
    List<Student> studentsWithSubject = [];
    for (var student in students) {
      int index = student.subjects.indexOf(subject);
      if (index != -1) {
        grades.add(student.grades[index]);
        studentsWithSubject.add(student);
      }
    }
    
    if (grades.isNotEmpty) {
      int maxGrade = grades.reduce(max);
      int minGrade = grades.reduce(min);
      
      List<String> maxStudents = studentsWithSubject
          .where((s) => s.grades[s.subjects.indexOf(subject)] == maxGrade)
          .map((s) => s.fullName)
          .toList();
      List<String> minStudents = studentsWithSubject
          .where((s) => s.grades[s.subjects.indexOf(subject)] == minGrade)
          .map((s) => s.fullName)
          .toList();
      
      print('$subject: Макс=$maxGrade (${maxStudents.join(', ')}), Мин=$minGrade (${minStudents.join(', ')})');
    }
  }
}

void printStudentsWithOneDeuce(List<Student> students) {
  print('5. Студенты с одной двойкой');
  List<Student> oneDeuceStudents = students.where((s) => s.countDeuces() == 1).toList();
  
  for (var student in oneDeuceStudents) {
    int deuceIndex = student.grades.indexWhere((g) => g == 2);
    print('${student.fullName} - двойка по ${student.subjects[deuceIndex]}');
  }
  
  if (oneDeuceStudents.isEmpty) print('Таких студентов нет');
}

void printSubjectsAboveAverage(List<Student> students) {
  print('6. Предметы выше общего среднего');
  
  double groupAvg = students.map((s) => s.averageGrade).reduce((a, b) => a + b) / students.length;
  print('Общий средний балл группы: ${groupAvg.toStringAsFixed(2)}');
  
  Set<String> allSubjects = {};
  for (var student in students) allSubjects.addAll(student.subjects);
  
  Map<String, double> subjectAvgs = {};
  for (String subject in allSubjects) {
    List<int> grades = [];
    for (var student in students) {
      int index = student.subjects.indexOf(subject);
      if (index != -1) grades.add(student.grades[index]);
    }
    if (grades.isNotEmpty) {
      subjectAvgs[subject] = grades.reduce((a, b) => a + b) / grades.length;
    }
  }
  
  List<String> aboveAvg = subjectAvgs.entries
      .where((e) => e.value > groupAvg)
      .map((e) => '${e.key} (${e.value.toStringAsFixed(2)})')
      .toList();
  
  print(aboveAvg.isEmpty ? 'Нет таких предметов' : aboveAvg.join(', '));
}

void printCategoryStats(List<Student> students) {
  print('7. Статистика по категориям успеваемости');
  
  int excellent = 0, good = 0, others = 0;
  for (var student in students) {
    switch (student.category) {
      case 'Отличник': excellent++; break;
      case 'Хорошист': good++; break;
      default: others++;
    }
  }
  
  print('Отличники: $excellent');
  print('Хорошисты: $good');
  print('Остальные: $others');
}
