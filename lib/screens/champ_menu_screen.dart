import 'package:flutter/material.dart';
import 'package:agri_app/models/data_models.dart';
import 'package:agri_app/screens/diagnostic_tab.dart';
import 'package:agri_app/screens/irrigation_tab.dart';
import 'package:agri_app/screens/notification_tab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChampMenuScreen extends StatefulWidget {
  final ChampVirtuel champ;
  
  const ChampMenuScreen({Key? key, required this.champ}) : super(key: key);

  @override
  _ChampMenuScreenState createState() => _ChampMenuScreenState();
}

class _ChampMenuScreenState extends State<ChampMenuScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    );

    _slideAnimations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.5;
      return Tween<double>(begin: 60, end: 0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
        ),
      );
    });

    _fadeAnimations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.5;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
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
                    // Bouton retour
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
                            widget.champ.nom,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          if (widget.champ.cultureName != null)
                            Text(
                              widget.champ.cultureName!,
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

              // ===== INFO CARD =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B5E20).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF2E7D32).withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.cloud_outlined, 'Climat', widget.champ.climat.isNotEmpty ? widget.champ.climat : 'N/A'),
                      Container(width: 1, height: 36, color: Colors.black12),
                      _buildInfoItem(FontAwesomeIcons.calendarDay, 'Semis', _formatDate(widget.champ.dateSemis)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // ===== TITRE ACTIONS =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.dashboard_customize_rounded, color: Color(0xFF2E7D32), size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // ===== MENU CARDS =====
              Expanded(
                child: AnimatedBuilder(
                  animation: _staggerController,
                  builder: (context, child) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Diagnostic
                          Transform.translate(
                            offset: Offset(0, _slideAnimations[0].value),
                            child: Opacity(
                              opacity: _fadeAnimations[0].value,
                              child: _buildMenuCard(
                                icon: FontAwesomeIcons.stethoscope,
                                title: 'Diagnostic',
                                subtitle: 'Analysez la santé de vos plantes par photo ou drone',
                                gradient: [Color(0xFF43A047), Color(0xFF66BB6A)],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiagnosticTab(champ: widget.champ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Irrigation
                          Transform.translate(
                            offset: Offset(0, _slideAnimations[1].value),
                            child: Opacity(
                              opacity: _fadeAnimations[1].value,
                              child: _buildMenuCard(
                                icon: FontAwesomeIcons.droplet,
                                title: 'Irrigation',
                                subtitle: 'Vérifiez l\'humidité et arrosez votre champ',
                                gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IrrigationTab(champ: widget.champ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Notification
                          Transform.translate(
                            offset: Offset(0, _slideAnimations[2].value),
                            child: Opacity(
                              opacity: _fadeAnimations[2].value,
                              child: _buildMenuCard(
                                icon: FontAwesomeIcons.bell,
                                title: 'Notifications',
                                subtitle: 'Consultez les alertes et recommandations',
                                gradient: [Color(0xFFE65100), Color(0xFFFF8F00)],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotificationTab(champ: widget.champ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Color(0xFF2E7D32)),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.2),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône dans un cercle en dégradé
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[850],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Flèche
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: gradient[0].withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: gradient[0],
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
