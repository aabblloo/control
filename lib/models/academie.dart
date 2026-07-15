class Academie {
  final int? id;
  final String nom;
  final String code;
  final String? email;
  final String? tel;
  final String? image;
  final int? regionId;

  const Academie({
    this.id,
    required this.nom,
    required this.code,
    this.email,
    this.tel,
    this.image,
    this.regionId,
  });

  factory Academie.fromJson(Map<String, dynamic> json) {
    return Academie(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      nom: json['nom']?.toString() ?? json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      email: json['email']?.toString(),
      tel: json['tel']?.toString(),
      image: json['image']?.toString(),
      regionId: json['region_id'] is int ? json['region_id'] : int.tryParse(json['region_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'code': code,
      'email': email,
      'tel': tel,
      'image': image,
      'region_id': regionId,
    };
  }

  @override
  String toString() => nom;
}
