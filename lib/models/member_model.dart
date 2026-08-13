class Member {
  final String memberId;
  final String? name;
  final String? mobileNumber;
  final String? emailAddress;
  final String? localityPincode;
  final String? membershipEndDate;
  final String? trainerAssigned;
  final bool isActive;

  const Member({
    required this.memberId,
    this.name,
    this.mobileNumber,
    this.emailAddress,
    this.localityPincode,
    this.membershipEndDate,
    this.trainerAssigned,
    this.isActive = false,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: (json['memberId'] ?? 'N/A').toString(),
      name: json['name']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      emailAddress: json['emailAddress']?.toString(),
      localityPincode: json['localityPincode']?.toString(),
      membershipEndDate: json['membershipEndDate']?.toString(),
      trainerAssigned: json['trainerAssigned']?.toString(),
      isActive: json['isActive'] == true,
    );
  }
}
