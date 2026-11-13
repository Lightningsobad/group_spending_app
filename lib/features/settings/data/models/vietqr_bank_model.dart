class VietQrBankModel {
  final int id;
  final String name;
  final String code;
  final String bin;
  final String shortName;
  final String logo;

  const VietQrBankModel({
    required this.id,
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.logo,
  });

  factory VietQrBankModel.fromJson(Map<String, dynamic> json) {
    return VietQrBankModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      bin: (json['bin'] as String?) ?? '',
      shortName: (json['shortName'] as String?) ??
          (json['short_name'] as String?) ??
          (json['code'] as String?) ??
          '',
      logo: (json['logo'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'bin': bin,
      'shortName': shortName,
      'logo': logo,
    };
  }
}
