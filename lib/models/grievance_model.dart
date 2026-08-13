class Grievance {
  final String grievanceId;
  final String branchId;
  final String issueType;
  final String description;
  final String resolution;
  final String date;
  final String? closureDate;

  const Grievance({
    required this.grievanceId,
    required this.branchId,
    required this.issueType,
    required this.description,
    required this.resolution,
    required this.date,
    this.closureDate,
  });

  bool get isClosed => closureDate != null;

  factory Grievance.fromJson(Map<String, dynamic> json) {
    return Grievance(
      grievanceId: (json['grievanceId'] ?? 'N/A').toString(),
      branchId: json['branchId'] ?? 'Unknown Branch',
      issueType: json['issueType'] ?? 'General Issue',
      description: json['description'] ?? 'No text summary provided.',
      resolution: json['resolution'] ?? 'Awaiting management audit.',
      date: json['date'] ?? '',
      closureDate: json['closureDate'],
    );
  }
}
