import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:agri_app/services/api_service.dart';
import 'package:agri_app/services/local_storage_service.dart';
import 'package:agri_app/models/data_models.dart';
import 'package:agri_app/screens/drone_tab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DiagnosticTab extends StatefulWidget {
  final ChampVirtuel champ;
  
  const DiagnosticTab({Key? key, required this.champ}) : super(key: key);

  @override
  _DiagnosticTabState createState() => _DiagnosticTabState();
}

class _DiagnosticTabState extends State<DiagnosticTab> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  String _diagnosticResult = '';
  final ImagePicker _picker = ImagePicker();
  int _selectedOption = 0; // Utilisé pour l'état interne
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _selectedOption = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFDFDFD),
        child: SafeArea(
          child: Column(
            children: [
              // ===== HEADER =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1B5E20), size: 20),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diagnostic',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          Text(
                            widget.champ.nom,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== SOUS-MENU Photo / Drone =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.all(3),
                    labelColor: Colors.white,
                    unselectedLabelColor: Color(0xFF1B5E20),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Photo'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.helicopter, size: 16),
                            SizedBox(width: 8),
                            Text('Drone'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8),

              // ===== CONTENU =====
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPhotoContent(),
                    DroneTab(champ: widget.champ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre
          Text(
            'Diagnostic par Photo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          
          // Zone d'image
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedImage != null 
                    ? Color(0xFF43A047)
                    : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_camera_rounded,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucune image sélectionnée',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Prenez ou importez une photo de votre plante',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 20),
          
          // Boutons d'ajout d'image
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF43A047),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  icon: Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                  label: Text(
                    'Galerie',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF43A047),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  icon: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                  label: Text(
                    'Caméra',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Bouton Commencer diagnostic
          if (_selectedImage != null)
            ElevatedButton(
              onPressed: _isAnalyzing ? null : _startDiagnostic,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC62828),
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
              ),
              child: _isAnalyzing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Analyse en cours...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Commencer le diagnostic',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          
          SizedBox(height: 20),
          
          // Résultat du diagnostic
          if (_diagnosticResult.isNotEmpty)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.clipboardCheck, color: Color(0xFF2E7D32), size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Résultat du diagnostic',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Text(
                    _diagnosticResult,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _diagnosticResult = '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startDiagnostic() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _diagnosticResult = '';
    });

    try {
      // Récupération de l'ID de l'agriculteur connecté
      final int? userId = LocalStorageService.getUserId();
      
      // Envoi de l'image au serveur IA avec l'ID utilisateur
      final response = await ApiService.sendImageForDiagnosis(_selectedImage!, agriculteurId: userId);

      if (response != null && response['success'] == true) {
        // Récupération des champs normalisés renvoyés par le serveur IA
        final plantName    = response['plant_name']    ?? 'Inconnue';
        final diseaseName  = response['disease_name']  ?? 'Indéterminée';
        final treatment    = response['treatment']     ?? 'Aucun traitement disponible.';
        final nextInspect  = response['next_inspection'] ?? 'À confirmer';
        final confidence   = response['confidence'];   // ex: 94.3  (%)

        setState(() {
          _isAnalyzing = false;
          _diagnosticResult = '''
🌿 Plante : $plantName${confidence != null ? '  (confiance : $confidence %)' : ''}

🔍 Maladie identifiée : $diseaseName

💊 Traitement recommandé :
$treatment

📅 Prochaine inspection : $nextInspect
''';
        });
      } else {
        // Affiche le message d'erreur retourné par le serveur, sinon message générique
        setState(() {
          _isAnalyzing = false;
          _diagnosticResult = (response != null && response.containsKey('error'))
              ? '❌ Erreur serveur : ${response['error']}'
              : '❌ Erreur inconnue lors de l\'analyse.';
        });
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _diagnosticResult = '❌ Erreur de connexion au serveur IA.\nVérifiez que le serveur est bien démarré sur le réseau.';
      });
    }
  }
}