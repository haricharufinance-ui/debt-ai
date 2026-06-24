class IncomeProfile {
  double salary;
  double other;
  int salaryDate;

  IncomeProfile({
    this.salary = 0,
    this.other = 0,
    this.salaryDate = 1,
  });

  double get total => salary + other;

  Map<String, dynamic> toJson() => {
        'salary': salary,
        'other': other,
        'salaryDate': salaryDate,
      };

  factory IncomeProfile.fromJson(Map<String, dynamic> json) => IncomeProfile(
        salary: (json['salary'] ?? 0).toDouble(),
        other: (json['other'] ?? 0).toDouble(),
        salaryDate: (json['salaryDate'] ?? 1) as int,
      );
}
