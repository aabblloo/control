class Eleve {
  final int id;
  final String matricule;
  final String prenoms;
  final String nom;
  final int? etablissementId;
  final String? serie;
  final String? classroom;
  final String? prisEnCharge;
  final String? anneeDef;
  final String? codeAeDef;
  final String? numPlaceDef;

  const Eleve({
    required this.id,
    required this.matricule,
    required this.prenoms,
    required this.nom,
    this.etablissementId,
    this.serie,
    this.classroom,
    this.prisEnCharge,
    this.anneeDef,
    this.codeAeDef,
    this.numPlaceDef,
  });

  factory Eleve.fromJson(Map<String, dynamic> json) {
    return Eleve(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      matricule: json['matricule']?.toString() ?? '',
      prenoms: json['prenoms']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      etablissementId: json['etablissement_id'] is int ? json['etablissement_id'] : int.tryParse(json['etablissement_id']?.toString() ?? ''),
      serie: json['serie']?.toString(),
      classroom: json['classroom']?.toString(),
      prisEnCharge: json['pris_en_charge']?.toString(),
      anneeDef: json['annee_def']?.toString(),
      codeAeDef: json['code_ae_def']?.toString(),
      numPlaceDef: json['num_place_def']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricule': matricule,
      'prenoms': prenoms,
      'nom': nom,
      'etablissement_id': etablissementId,
      'serie': serie,
      'classroom': classroom,
      'pris_en_charge': prisEnCharge,
      'annee_def': anneeDef,
      'code_ae_def': codeAeDef,
      'num_place_def': numPlaceDef,
    };
  }
}

class ElevesResponse {
  final int nombreEleves;
  final int nombreGarcons;
  final int nombreFilles;
  final List<Eleve> eleves;

  const ElevesResponse({
    required this.nombreEleves,
    required this.nombreGarcons,
    required this.nombreFilles,
    required this.eleves,
  });

  factory ElevesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['eleves'] ?? json['data'] ?? json['items'] ?? []) as List;
    return ElevesResponse(
      nombreEleves: json['nombre_eleves'] is int ? json['nombre_eleves'] : int.tryParse(json['nombre_eleves']?.toString() ?? '0') ?? list.length,
      nombreGarcons: json['nombre_garcons'] is int ? json['nombre_garcons'] : int.tryParse(json['nombre_garcons']?.toString() ?? '0') ?? 0,
      nombreFilles: json['nombre_filles'] is int ? json['nombre_filles'] : int.tryParse(json['nombre_filles']?.toString() ?? '0') ?? 0,
      eleves: list.map((e) => Eleve.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
