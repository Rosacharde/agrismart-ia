import 'package:flutter/material.dart';
import 'package:agri_app/screens/main_screen.dart';
import 'package:agri_app/services/api_service.dart';
import 'package:agri_app/services/local_storage_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeTpController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête courbé vert avec Logo
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.leaf, // fas fa-leaf
                            size: 40,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Agri Smart',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 40),
            
            // Titre de connexion
            Text(
              'Connexion Agriculteur',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 40),
            
            // Formulaire
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  // Champ Code TP
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: TextField(
                      controller: _codeTpController,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.black54),
                        hintText: 'Entrez votre code TP',
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Bouton Se connecter
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA5D6A7), // Vert clair comme sur la maquette
                        foregroundColor: Colors.black87,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.black87),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.black87)
                          : Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Mot de passe oublié
                  TextButton(
                    onPressed: () {
                      // Action mot de passe oublié
                    },
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  // Message d'erreur
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String codeTp = _codeTpController.text.trim();
    
    if (codeTp.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre code TP';
        _isLoading = false;
      });
      return;
    }

    try {
      // Vérification du code TP via l'API
      Map<String, dynamic>? result = await ApiService.loginAgriculteur('', codeTp);
      
      if (result != null) {
        if (result['success'] == true) {
          // Sauvegarde des informations utilisateur
          await LocalStorageService.setUserConnected(true);
          await LocalStorageService.setUserId(result['agriculteur_id']); // Correspond à la clé renvoyée par le serveur
          await LocalStorageService.setUserCodeTp(codeTp);
          await LocalStorageService.setUserFullName(result['name'] ?? 'Agriculteur');
          
          // Navigation vers l'écran principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Code TP invalide ou non enregistré';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Impossible de contacter le serveur (Vérifiez IP/Réseau)';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _codeTpController.dispose();
    super.dispose();
  }
}

// Clipper personnalisé pour la forme courbée
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50); // Commence en bas à gauche (moins la courbe)
    
    // Courbe de Bézier quadratique
    // Point de contrôle (milieu bas) et Point final (bas droite)
    // On fait une vague : descend puis remonte
    path.quadraticBezierTo(
      size.width / 4, size.height, // 1er point de contrôle (bas gauche)
      size.width / 2, size.height - 30, // Point milieu
    );
    
    path.quadraticBezierTo(
      size.width * 3 / 4, size.height - 60, // 2ème point de contrôle
      size.width, size.height - 20, // Fin à droite
    );
    
    path.lineTo(size.width, 0); // Remonte en haut à droite
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}