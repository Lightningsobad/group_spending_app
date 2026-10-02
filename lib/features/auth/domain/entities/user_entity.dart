class UserEntity {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final bool isEmailVerified;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.role,
    required this.isEmailVerified,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.createdAt,
  });

  UserEntity copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? role,
    bool? isEmailVerified,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
