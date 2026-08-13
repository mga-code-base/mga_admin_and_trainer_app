class Trainer {
  final String trainerId;
  final String? name;
  final String? username;
  final String? emailAddress;
  final String? mobileNumber;
  final bool isActive;

  const Trainer({
    required this.trainerId,
    this.name,
    this.username,
    this.emailAddress,
    this.mobileNumber,
    this.isActive = true,
  });

  static String? _unwrapScalar(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map && raw['\$numberLong'] != null) {
      return raw['\$numberLong'].toString();
    }
    return raw.toString();
  }

  static String normalizeId(dynamic rawId) => _unwrapScalar(rawId) ?? 'N/A';

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      trainerId: normalizeId(json['trainerId']),
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      emailAddress: json['emailAddress']?.toString(),
      mobileNumber: _unwrapScalar(json['mobileNumber']),
      isActive: json['isActive'] ?? true,
    );
  }
}
