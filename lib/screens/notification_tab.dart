import 'package:flutter/material.dart';
import 'package:agri_app/services/api_service.dart';
import 'package:agri_app/services/local_storage_service.dart';
import 'package:agri_app/models/data_models.dart';

class NotificationTab extends StatefulWidget {
  final ChampVirtuel champ;
  
  const NotificationTab({Key? key, required this.champ}) : super(key: key);

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  // Données réelles
  List<DiagnosticNotification> _diagnosticNotifications = [];
  List<TerrainNotification> _terrainNotifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final codeTp = LocalStorageService.getUserCodeTp();
      if (codeTp != null) {
        final data = await ApiService.getMobileNotifications(codeTp);
        
        if (data['success'] == true) {
          final List<dynamic> terrainData = data['terrain_notifications'] ?? [];
          final List<dynamic> diagnosticData = data['diagnostic_notifications'] ?? [];
          
          // Filtrer par le champ virtuel sélectionné
          final champNom = widget.champ.nom.toLowerCase();
          
          setState(() {
            _terrainNotifications = terrainData.map((json) => TerrainNotification(
              id: json['id'],
              culture: json['culture'] ?? 'Culture inconnue',
              phase: json['phase'] ?? 'avant_semis',
              action: json['action'] ?? 'Action recommandée',
              date: DateTime.parse(json['created_at']),
              champVirtuel: json['champ_virtuel'] ?? '',
            )).where((n) => n.champVirtuel.toLowerCase().contains(champNom) || champNom.contains(n.champVirtuel.toLowerCase()) || n.champVirtuel.isEmpty).toList();
            
            _diagnosticNotifications = diagnosticData.map((json) => DiagnosticNotification(
              id: json['id'],
              culture: json['culture'] ?? 'Inconnue',
              maladie: json['maladie'] ?? 'Indéterminée',
              traitement: json['traitement'] ?? 'Aucun traitement spécifié',
              date: DateTime.parse(json['date']),
              description: json['description'] ?? '',
              parcelle: json['parcelle'] ?? 'Mon champ',
              champVirtuel: json['champ_virtuel'] ?? '',
            )).where((n) => n.champVirtuel.toLowerCase().contains(champNom) || champNom.contains(n.champVirtuel.toLowerCase()) || n.champVirtuel.isEmpty).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erreur chargement notifications: $e');
      setState(() => _isLoading = false);
    }
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
                            'Notifications',
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
                    // Bouton de rafraîchissement
                    GestureDetector(
                      onTap: _loadNotifications,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.refresh_rounded, color: Color(0xFF1B5E20), size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Barre de recherche
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 8),

              // Onglets
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.all(3),
                    labelColor: Colors.white,
                    unselectedLabelColor: Color(0xFF1B5E20),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'Diagnostics'),
                      Tab(text: 'Analyse Terrain'),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 8),

              // Contenu des onglets
              Expanded(
                child: _isLoading 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF2E7D32), strokeWidth: 3),
                          SizedBox(height: 16),
                          Text('Chargement...', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDiagnosticTab(),
                        _buildTerrainTab(),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticTab() {
    List<DiagnosticNotification> filteredNotifications = _diagnosticNotifications
        .where((notification) =>
            notification.culture.toLowerCase().contains(_searchQuery) ||
            notification.maladie.toLowerCase().contains(_searchQuery) ||
            notification.parcelle.toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.healing_rounded, size: 50, color: Colors.grey[400]),
            ),
            SizedBox(height: 16),
            Text(
              'Aucun diagnostic trouvé',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'pour le champ "${widget.champ.nom}"',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationCard(
          title: '${notification.culture} - ${notification.maladie}',
          subtitle: notification.parcelle,
          description: notification.description,
          traitement: notification.traitement,
          date: notification.date,
          onDelete: () => _deleteDiagnosticNotification(notification.id),
          color: Colors.red[100]!,
          icon: Icons.healing_rounded,
          iconColor: Color(0xFFC62828),
        );
      },
    );
  }

  Widget _buildTerrainTab() {
    List<TerrainNotification> filteredNotifications = _terrainNotifications
        .where((notification) =>
            notification.culture.toLowerCase().contains(_searchQuery) ||
            notification.action.toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.agriculture_rounded, size: 50, color: Colors.grey[400]),
            ),
            SizedBox(height: 16),
            Text(
              'Aucun travail avant semis trouvé',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'pour le champ "${widget.champ.nom}"',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationCard(
          title: 'Travaux avant semis - ${notification.culture}',
          subtitle: notification.culture,
          description: notification.action,
          traitement: null,
          date: notification.date,
          onDelete: () => _deleteTerrainNotification(notification.id),
          color: Colors.blue[100]!,
          icon: Icons.agriculture_rounded,
          iconColor: Color(0xFF1565C0),
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required String description,
    String? traitement,
    required DateTime date,
    required VoidCallback onDelete,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre colorée
            Container(width: 5, height: 120, color: iconColor),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: iconColor, size: 16),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.delete_outline_rounded, color: Colors.red[400], size: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (traitement != null && traitement.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFFC5E1A5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Traitement recommandé :',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              traitement,
                              style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 6),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure(s)';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute(s)';
    } else {
      return 'À l\'instant';
    }
  }

  void _deleteDiagnosticNotification(int id) async {
    try {
      final success = await ApiService.deleteNotification(id, 'diagnostic');
      if (success) {
        setState(() {
          _diagnosticNotifications.removeWhere((notification) => notification.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification de diagnostic supprimée'),
            backgroundColor: Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la suppression sur le serveur'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      print('Erreur suppression: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _deleteTerrainNotification(int id) async {
    try {
      final success = await ApiService.deleteNotification(id, 'terrain');
      if (success) {
        setState(() {
          _terrainNotifications.removeWhere((notification) => notification.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification d\'analyse terrain supprimée'),
            backgroundColor: Color(0xFF1565C0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la suppression sur le serveur'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      print('Erreur suppression: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class DiagnosticNotification {
  final int id;
  final String culture;
  final String maladie;
  final String traitement;
  final DateTime date;
  final String description;
  final String parcelle;
  final String champVirtuel;

  DiagnosticNotification({
    required this.id,
    required this.culture,
    required this.maladie,
    required this.traitement,
    required this.date,
    required this.description,
    required this.parcelle,
    this.champVirtuel = '',
  });
}

class TerrainNotification {
  final int id;
  final String culture;
  final String phase;
  final String action;
  final DateTime date;
  final String champVirtuel;

  TerrainNotification({
    required this.id,
    required this.culture,
    required this.phase,
    required this.action,
    required this.date,
    this.champVirtuel = '',
  });
}