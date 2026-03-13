class JobModel {
  String jobType;
  String expectedSalary;
  String salaryType;

  JobModel({
    required this.jobType,
    required this.expectedSalary,
    required this.salaryType,
  });

  Map<String, dynamic> toMap() {
    return {
      "jobType": jobType,
      "expectedSalary": expectedSalary,
      "salaryType": salaryType,
    };
  }
}
