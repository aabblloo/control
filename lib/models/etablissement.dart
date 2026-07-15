class Etablissement {
  final int? id;
  final int? academieId;
  final String sigle;
  final String nom;
  final String? code;
  final String? statut;
  final String? emailEtb;
  final String? telEtb;
  final int? typeEtabId;
  final int? communeId;
  final String? image;

  const Etablissement({
    this.id,
    this.academieId,
    required this.sigle,
    required this.nom,
    this.code,
    this.statut,
    this.emailEtb,
    this.telEtb,
    this.typeEtabId,
    this.communeId,
    this.image,
  });

  factory Etablissement.fromJson(Map<String, dynamic> json) {
    return Etablissement(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      academieId: json['academie_id'] is int ? json['academie_id'] : int.tryParse(json['academie_id']?.toString() ?? ''),
      sigle: json['sigle']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      code: json['code']?.toString(),
      statut: json['statut']?.toString(),
      emailEtb: json['emailEtb']?.toString(),
      telEtb: json['telEtb']?.toString(),
      typeEtabId: json['type_etab_id'] is int ? json['type_etab_id'] : int.tryParse(json['type_etab_id']?.toString() ?? ''),
      communeId: json['commune_id'] is int ? json['commune_id'] : int.tryParse(json['commune_id']?.toString() ?? ''),
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academie_id': academieId,
      'sigle': sigle,
      'nom': nom,
      'code': code,
      'statut': statut,
      'emailEtb': emailEtb,
      'telEtb': telEtb,
      'type_etab_id': typeEtabId,
      'commune_id': communeId,
      'image': image,
    };
  }
}
