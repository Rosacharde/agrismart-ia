import 'package:flutter/material.dart';
import 'package:agri_app/services/local_storage_service.dart';
import 'package:agri_app/services/api_service.dart';
import 'package:agri_app/models/data_models.dart';
import 'package:agri_app/screens/champ_menu_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  List<ChampVirtuel> _champsVirtuels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Animation de pulsation subtile du logo
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadChampsVirtuels();
  }

  Future<void> _loadChampsVirtuels() async {
    final userId = LocalStorageService.getUserId();
    if (userId != null) {
      final champs = await ApiService.getChampsVirtuels(userId);
      if (mounted) {
        setState(() {
          _champsVirtuels = champs;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }

  IconData _getCultureIcon(String nom) {
    final lower = nom.toLowerCase();
    if (lower.contains('tomate') || lower.contains('pomme')) return FontAwesomeIcons.appleWhole;
    if (lower.contains('maïs') || lower.contains('mais') || lower.contains('blé') || lower.contains('ble')) return FontAwesomeIcons.wheatAwn;
    if (lower.contains('carotte') || lower.contains('oignon')) return FontAwesomeIcons.carrot;
    if (lower.contains('riz') || lower.contains('soja')) return FontAwesomeIcons.seedling;
    return FontAwesomeIcons.leaf;
  }

  Color _getCardColor(int index) {
    final colors = [
      Color(0xFF2E7D32), // Vert foncé
      Color(0xFF1565C0), // Bleu
      Color(0xFF6A1B9A), // Violet
      Color(0xFFE65100), // Orange foncé
      Color(0xFF00838F), // Teal
      Color(0xFFC62828), // Rouge foncé
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFDFDFD),
        child: SafeArea(
          child: Column(
            children: [
              // ===== EN-TÊTE : Logo + AGRISMART =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    // Logo animé
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF66BB6A).withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              FontAwesomeIcons.leaf,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 12),
                    // Nom AGRISMART
                    Text(
                      'AGRISMART',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5E20),
                        letterSpacing: 2,
                      ),
                    ),
                    Spacer(),
                    // Bouton de rafraîchissement
                    IconButton(
                      onPressed: () {
                        setState(() => _isLoading = true);
                        _loadChampsVirtuels();
                      },
                      icon: Icon(Icons.refresh_rounded, color: Colors.white70, size: 26),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              // ===== SALUTATION =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B5E20).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF2E7D32).withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()},',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E7D32).withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        LocalStorageService.getUserFullName() ?? 'Agriculteur',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 35),

              // ===== TITRE SECTION CHAMPS =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.layerGroup, color: Color(0xFF2E7D32), size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Mes Champs Virtuels',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E7D32).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_champsVirtuels.length} champ(s)',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 12),

              // ===== LISTE DES CHAMPS VIRTUELS =====
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF2E7D32),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chargement de vos champs...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : _champsVirtuels.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            itemCount: _champsVirtuels.length,
                            itemBuilder: (context, index) {
                              return _buildChampCard(_champsVirtuels[index], index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.seedling,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Aucun champ virtuel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Contactez votre agent ou administrateur\npour créer vos champs virtuels.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChampCard(ChampVirtuel champ, int index) {
    final cardColor = _getCardColor(index);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChampMenuScreen(champ: champ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.15),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Barre colorée à gauche
              Container(
                width: 6,
                height: 100,
                color: cardColor,
              ),
              // Icône de la culture
              Container(
                width: 56,
                height: 56,
                margin: EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getCultureIcon(champ.cultureName ?? champ.nom),
                  color: cardColor,
                  size: 24,
                ),
              ),
              // Informations du champ
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        champ.nom,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[850],
                        ),
                      ),
                      SizedBox(height: 4),
                      if (champ.cultureName != null)
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.seedling, size: 11, color: Colors.grey[500]),
                            SizedBox(width: 6),
                            Text(
                              champ.cultureName!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.cloud_outlined, size: 13, color: Colors.grey[500]),
                          SizedBox(width: 6),
                          Text(
                            champ.climat.isNotEmpty ? champ.climat : 'Climat non défini',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Flèche de navigation
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: cardColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}