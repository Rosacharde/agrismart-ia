import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:agri_app/models/data_models.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.145.179:8000/api'; // Adresse IP du PC Laravel / Base de données
  static const String webUrl = 'http://192.168.145.179:8000'; // Adresse IP du PC Laravel / Base de données
  static const String esp32Url = 'http://192.168.1.101'; // Adresse IP de l'ESP32
  static const String aiServerUrl ='http://192.168.0.111:5000'; // Adresse IP de TON pc (Serveur IA)

  // Connexion de l'agriculteur
  static Future<Map<String, dynamic>?> loginAgriculteur(String telephone, String codeTp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telephone': telephone,
          'code_tp': codeTp,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 401) {
        return jsonDecode(response.body);
      } else {
        print('Erreur de connexion: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la connexion: $e');
      return null;
    }
  }

  // Récupérer les parcelles d'un agriculteur
  static Future<List<Parcelle>> getParcelles(int agriculteurId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agriculteurs/$agriculteurId/parcelles'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['parcelles'];
        return data.map((json) => Parcelle.fromJson(json)).toList();
      } else {
        print('Erreur lors de la récupération des parcelles: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des parcelles: $e');
      return [];
    }
  }

  // Récupérer les champs virtuels d'un agriculteur
  static Future<List<ChampVirtuel>> getChampsVirtuels(int agriculteurId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agriculteurs/$agriculteurId/champs-virtuels'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['champs_virtuels'];
        return data.map((json) => ChampVirtuel.fromJson(json)).toList();
      } else {
        print('Erreur lors de la récupération des champs virtuels: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des champs virtuels: $e');
      return [];
    }
  }

  // Récupérer les notifications hybrides (terrain et diagnostics) pour un agriculteur
  static Future<Map<String, dynamic>> getMobileNotifications(String codeTp) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mobile/notifications/$codeTp'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur lors de la récupération des notifications: ${response.statusCode}');
        return {'success': false, 'terrain_notifications': [], 'diagnostic_notifications': []};
      }
    } catch (e) {
      print('Exception lors de la récupération des notifications: $e');
      return {'success': false, 'terrain_notifications': [], 'diagnostic_notifications': []};
    }
  }

  // Récupérer les notifications pour un agriculteur (Ancienne méthode si nécessaire)
  static Future<List<Notification>> getNotifications(int agriculteurId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agriculteurs/$agriculteurId/notifications'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['notifications'];
        return data.map((json) => Notification.fromJson(json)).toList();
      } else {
        print('Erreur lors de la récupération des notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des notifications: $e');
      return [];
    }
  }

  // Récupérer les cultures disponibles
  static Future<List<Culture>> getCultures() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cultures'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['cultures'];
        return data.map((json) => Culture.fromJson(json)).toList();
      } else {
        print('Erreur lors de la récupération des cultures: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des cultures: $e');
      return [];
    }
  }

  // Récupérer les communes
  static Future<List<Commune>> getCommunes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/communes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['communes'];
        return data.map((json) => Commune.fromJson(json)).toList();
      } else {
        print('Erreur lors de la récupération des communes: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des communes: $e');
      return [];
    }
  }

  // Envoyer une image au serveur IA pour diagnostic
  static Future<Map<String, dynamic>?> sendImageForDiagnosis(File imageFile, {int? agriculteurId}) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$aiServerUrl/diagnose')
      );
      
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);

      if (agriculteurId != null) {
        request.fields['agriculteur_id'] = agriculteurId.toString();
      }
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        return {'success': false, 'error': 'Erreur serveur: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur connexion: $e'};
    }
  }

  // Enregistrer le résultat du diagnostic
  static Future<bool> saveDiagnosticResult(int diseaseId, String plantName, String diseaseName) async {
    try {
      final response = await http.post(
        Uri.parse('$webUrl/api/diagnostics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'maladie_id': diseaseId,
          'plant_name': plantName,
          'disease_name': diseaseName,
          'date_diagnostic': DateTime.now().toIso8601String(),
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Exception lors de l\'enregistrement du diagnostic: $e');
      return false;
    }
  }

  // Supprimer une notification (terrain ou diagnostic)
  static Future<bool> deleteNotification(int id, String type) async {
    try {
      final url = '$baseUrl/notifications/$id?type=$type';
      print('Tentative de suppression: $url');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Réponse suppression (${response.statusCode}): ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        print('Erreur serveur lors de la suppression: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception lors de la suppression: $e');
      return false;
    }
  }

  // Récupérer les drones d'un agriculteur
  static Future<List<Drone>> getDrones(int agriculteurId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agriculteurs/$agriculteurId/drones'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['drones'];
        return data.map((json) => Drone.fromJson(json)).toList();
      } else {
        print('Erreur lors de la récupération des drones: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des drones: $e');
      return [];
    }
  }

  // Récupérer les équipements d'un agriculteur
  static Future<List<Equipement>> getEquipements(int agriculteurId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agriculteurs/$agriculteurId/equipements'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['equipements'];
        return data.map((json) => Equipement.fromJson(json)).toList();
      } else {
        print('Erreur lors de la récupération des équipements: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des équipements: $e');
      return [];
    }
  }

  // Envoyer une commande d'irrigation à l'ESP32
  static Future<Map<String, dynamic>?> sendIrrigationCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$esp32Url/command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'command': command,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur ESP32: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de l\'envoi à l\'ESP32: $e');
      return null;
    }
  }

  // Attendre la réponse d'arrêt de l'irrigation
  static Future<Map<String, dynamic>?> waitForIrrigationStop() async {
    try {
      // Attente de la réponse de l'ESP32 (timeout de 5 minutes)
      final response = await http.get(
        Uri.parse('$esp32Url/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(minutes: 5));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur status ESP32: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de l\'attente ESP32: $e');
      return null;
    }
  }

  // Vérifier l'humidité du sol pour un champ virtuel
  static Future<Map<String, dynamic>?> getSoilHumidity(int champVirtuelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parcelles/$champVirtuelId/humidity'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur lors de la récupération de l\'humidité: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la récupération de l\'humidité: $e');
      return null;
    }
  }

  // Envoyer une commande d'irrigation via le backend Laravel
  static Future<Map<String, dynamic>?> controlIrrigation(int champVirtuelId, String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/irrigation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'champ_virtuel_id': champVirtuelId,
          'command': command,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur irrigation: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors du contrôle d\'irrigation: $e');
      return null;
    }
  }
}