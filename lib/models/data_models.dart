class Agriculteur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String codeTp;
  final DateTime dateCreation;

  Agriculteur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.codeTp,
    required this.dateCreation,
  });

  factory Agriculteur.fromJson(Map<String, dynamic> json) {
    return Agriculteur(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      codeTp: json['code_tp'] ?? '',
      dateCreation: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }
}

class Parcelle {
  final int id;
  final String nom;
  final double surface;
  final int agriculteurId;
  final double latitude;
  final double longitude;
  final int communeId;
  final String typeSol;
  final double humidite;
  final double ph;
  final double conductivite;
  final double temperatureSol;
  final double matiereOrganique;
  final DateTime dateCreation;

  Parcelle({
    required this.id,
    required this.nom,
    required this.surface,
    required this.agriculteurId,
    required this.latitude,
    required this.longitude,
    required this.communeId,
    required this.typeSol,
    required this.humidite,
    required this.ph,
    required this.conductivite,
    required this.temperatureSol,
    required this.matiereOrganique,
    required this.dateCreation,
  });

  factory Parcelle.fromJson(Map<String, dynamic> json) {
    return Parcelle(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      surface: double.tryParse(json['surface']?.toString() ?? '0') ?? 0.0,
      agriculteurId: json['agriculteur_id'] ?? 0,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      communeId: json['commune_id'] ?? 0,
      typeSol: json['type_sol'] ?? '',
      humidite: double.tryParse(json['humidite']?.toString() ?? '0') ?? 0.0,
      ph: double.tryParse(json['ph']?.toString() ?? '0') ?? 0.0,
      conductivite: double.tryParse(json['conductivite']?.toString() ?? '0') ?? 0.0,
      temperatureSol: double.tryParse(json['temperature_sol']?.toString() ?? '0') ?? 0.0,
      matiereOrganique: double.tryParse(json['matiere_organique']?.toString() ?? '0') ?? 0.0,
      dateCreation: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }
}

class Culture {
  final int id;
  final String nom;
  final String emoji;

  Culture({
    required this.id,
    required this.nom,
    required this.emoji,
  });

  factory Culture.fromJson(Map<String, dynamic> json) {
    return Culture(
      id: json['id'],
      nom: json['name'] ?? '',
      emoji: json['emoji'] ?? '',
    );
  }
}

class ChampVirtuel {
  final int id;
  final String nom;
  final int agriculteurId;
  final int parcelleId;
  final int cultureId;
  final String climat;
  final DateTime dateSemis;
  final DateTime dateCreation;
  final String? cultureName;
  final String? parcelleName;
  final Parcelle? parcelle;

  ChampVirtuel({
    required this.id,
    required this.nom,
    required this.agriculteurId,
    required this.parcelleId,
    required this.cultureId,
    required this.climat,
    required this.dateSemis,
    required this.dateCreation,
    this.cultureName,
    this.parcelleName,
    this.parcelle,
  });

  factory ChampVirtuel.fromJson(Map<String, dynamic> json) {
    return ChampVirtuel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      agriculteurId: json['agriculteur_id'] ?? 0,
      parcelleId: json['parcelle_id'] ?? 0,
      cultureId: json['culture_id'] ?? 0,
      climat: json['climat'] ?? '',
      dateSemis: DateTime.parse(json['date_semis'] ?? DateTime.now().toString()),
      dateCreation: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      cultureName: json['culture'] != null ? (json['culture']['name'] ?? '') : null,
      parcelleName: json['parcelle'] != null ? (json['parcelle']['nom'] ?? '') : null,
      parcelle: json['parcelle'] != null ? Parcelle.fromJson(json['parcelle']) : null,
    );
  }
}

class Notification {
  final int id;
  final int? cultureId;
  final String phase; // 'avant_semis' or 'apres_semis'
  final int? jour;
  final String action;
  final DateTime dateCreation;

  Notification({
    required this.id,
    this.cultureId,
    required this.phase,
    this.jour,
    required this.action,
    required this.dateCreation,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? 0,
      cultureId: json['culture_id'],
      phase: json['phase'] ?? '',
      jour: json['jour'],
      action: json['action'] ?? '',
      dateCreation: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }
}

class Commune {
  final int id;
  final String name;

  Commune({
    required this.id,
    required this.name,
  });

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Drone {
  final int id;
  final String nom;
  final String statut;
  final int agriculteurId;

  Drone({
    required this.id,
    required this.nom,
    required this.statut,
    required this.agriculteurId,
  });

  factory Drone.fromJson(Map<String, dynamic> json) {
    return Drone(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      statut: json['statut'] ?? 'inactif',
      agriculteurId: json['agriculteur_id'] ?? 0,
    );
  }
}

class Equipement {
  final int id;
  final String nom;
  final bool estAllume;
  final int champVirtuelId;
  final ChampVirtuel? champVirtuel;

  Equipement({
    required this.id,
    required this.nom,
    required this.estAllume,
    required this.champVirtuelId,
    this.champVirtuel,
  });

  factory Equipement.fromJson(Map<String, dynamic> json) {
    return Equipement(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      estAllume: json['est_allume'] == 1 || json['est_allume'] == true,
      champVirtuelId: json['champ_virtuel_id'] ?? 0,
      champVirtuel: json['champ_virtuel'] != null 
          ? ChampVirtuel.fromJson(json['champ_virtuel']) 
          : null,
    );
  }
}