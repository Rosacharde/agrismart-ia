import 'package:flutter/material.dart';
import 'package:agri_app/services/api_service.dart';
import 'package:agri_app/services/local_storage_service.dart';
import 'package:agri_app/models/data_models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class DroneTab extends StatefulWidget {
  final ChampVirtuel champ;

  const DroneTab({Key? key, required this.champ}) : super(key: key);

  @override
  State<DroneTab> createState() => _DroneTabState();
}

class _DroneTabState extends State<DroneTab> with SingleTickerProviderStateMixin {
  // État de l'interface
  bool _isValidated = false;
  bool _isMissionActive = false;
  bool _isPaused = false;
  
  // Cartographie (Suppression des images pour un style épuré)
  final Color _fieldColor = const Color(0xFFE8F5E9);
  final Color _boundaryColor = const Color(0xFF2E7D32);

  // Données du tracé
  List<Offset> _points = [];
  List<Offset> _gridPath = [];
  
  // Animation du drone
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Télémétrie & Drone
  Drone? _activeDrone;
  double _altitude = 12.0;
  String _mode = "Auto";
  int _battery = 98;
  int _signal = 4; // Intensité du signal (1-5)
  bool _showAiResult = false;
  String? _aiDiagnostic;

  @override
  void initState() {
    super.initState();
    _loadActiveDrone();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Vitesse diminuée
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
        if (_animation.value == 1.0 && !_showAiResult) {
          _simulateAiDetection();
        }
      });

    // Initialisation automatique du champ déléguée au LayoutBuilder
  }

  Size? _lastSize;

  void _initializeAutomatedField(Size size) {
    if (_lastSize == size) return; // Éviter les récalculs inutiles si la taille est identique
    _lastSize = size;
    
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    // Ratios ajustés pour une visibilité optimale (H: 70%)
    final double boxWidth = size.width * 0.75; 
    final double boxHeight = size.height * 0.75; 

    setState(() {
      _points = [
        Offset(centerX - boxWidth / 2, centerY - boxHeight / 2),
        Offset(centerX + boxWidth / 2, centerY - boxHeight / 2),
        Offset(centerX + boxWidth / 2, centerY + boxHeight / 2),
        Offset(centerX - boxWidth / 2, centerY + boxHeight / 2),
      ];
      _isValidated = true;
      _generateGrid();
    });
  }

  void _simulateAiDetection() {
    final List<String> results = [
      "Culture saine. Aucune anomalie détectée sur la parcelle ${widget.champ.parcelleName}.",
      "Alerte : Présence potentielle de Rouille (Rust) détectée sur 15% de la parcelle ${widget.champ.parcelleName}. Recommandation : Traitement antifongique.",
      "Alerte : Signes de flétrissement bactérien détectés. Irrigation à vérifier sur la zone Nord.",
      "Stress hydrique détecté : La culture manque d'eau sur la parcelle ${widget.champ.parcelleName}.",
      "Carence en azote suspectée : Coloration jaunâtre des feuilles observée par l'IA.",
    ];
    final randomResult = results[math.Random().nextInt(results.length)];

    setState(() {
      _showAiResult = true;
      _aiDiagnostic = "Analyse IA terminée :\n$randomResult";
    });
  }

  Future<void> _loadActiveDrone() async {
    int? agriculteurId = LocalStorageService.getUserId();
    if (agriculteurId != null) {
      List<Drone> drones = await ApiService.getDrones(agriculteurId);
      if (drones.isNotEmpty) {
        setState(() {
          _activeDrone = drones.first;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE TRACÉ ---

  void _generateGrid() {
    if (_points.isEmpty) return;
    
    double minX = _points.map((p) => p.dx).reduce(math.min);
    double maxX = _points.map((p) => p.dx).reduce(math.max);
    double minY = _points.map((p) => p.dy).reduce(math.min);
    double maxY = _points.map((p) => p.dy).reduce(math.max);
    
    List<Offset> path = [];
    double spacing = 35.0; // Espacement plus large pour une apparence plus claire
    
    bool leftToRight = true;
    for (double y = minY + spacing / 2; y <= maxY; y += spacing) {
      if (leftToRight) {
        path.add(Offset(minX, y));
        path.add(Offset(maxX, y));
      } else {
        path.add(Offset(maxX, y));
        path.add(Offset(minX, y));
      }
      leftToRight = !leftToRight;
    }
    
    setState(() {
      _gridPath = path;
    });
  }

  // --- LOGIQUE DE MISSION ---

  void _startMission() {
    if (!_isValidated) return;
    setState(() {
      _isMissionActive = true;
      _isPaused = false;
      _animationController.forward();
    });
  }

  void _pauseMission() {
    setState(() {
      _isPaused = true;
      _animationController.stop();
    });
  }

  void _stopMission() {
    setState(() {
      _isMissionActive = false;
      _isPaused = false;
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1B5E20), size: 20),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Simulation Mission',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                ],
              ),
            ),

            // ZONE INTERACTIVE (Plein écran disponible)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  // Recalculer le champ si la taille change (ex: rotation ou clavier)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _initializeAutomatedField(size);
                  });

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: _fieldColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Grille de fond subtile
                          CustomPaint(
                            painter: GridBackgroundPainter(),
                            size: Size.infinite,
                          ),
                          
                          if (!_showAiResult)
                            // Custom Painter pour les points et le quadrillage
                            CustomPaint(
                              painter: MissionPainter(
                                points: _points,
                                gridPath: _gridPath,
                                isValidated: _isValidated,
                                progress: _animation.value,
                                isMissionActive: _isMissionActive,
                                boundaryColor: _boundaryColor,
                              ),
                              size: Size.infinite,
                            )
                          else
                            // Affichage du diagnostic à la place de la simulation
                            _buildDiagnosticView(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // CONTROLES (Suppression du bouton de validation manuelle)
            if (_isValidated)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMissionActionButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'Start',
                        color: Colors.green[700]!,
                        onTap: _startMission,
                        isActive: _isMissionActive && !_isPaused,
                      ),
                      const SizedBox(width: 25),
                      _buildMissionActionButton(
                        icon: Icons.pause_rounded,
                        label: 'Pause',
                        color: Colors.orange[700]!,
                        onTap: _pauseMission,
                        isActive: _isPaused,
                      ),
                      const SizedBox(width: 25),
                      _buildMissionActionButton(
                        icon: Icons.stop_rounded,
                        label: 'Stop',
                        color: Colors.red[700]!,
                        onTap: _stopMission,
                        isActive: false,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTelemetryItem('Altitude', '${_altitude.toInt()}m', Icons.height),
                        _buildTelemetryItem('Mode', _mode, Icons.auto_awesome_rounded),
                      ],
                    ),
                  ),
                  
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(FontAwesomeIcons.helicopter, color: Colors.white, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _activeDrone?.nom ?? 'Recherche drone...',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Signal du drone type WiFi
                        Icon(
                          Icons.wifi,
                          size: 18,
                          color: _signal >= 3 ? Colors.greenAccent : Colors.orangeAccent,
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.battery_4_bar_rounded, color: Colors.greenAccent, size: 18),
                        const SizedBox(width: 5),
                        Text('$_battery%', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionActionButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Icon(icon, color: isActive ? Colors.white : color, size: 35),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildDiagnosticView() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(25),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology_outlined, color: Color(0xFF1B5E20), size: 50),
              const SizedBox(height: 15),
              const Text(
                'DIAGNOSTIC IA TERMINÉ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20), letterSpacing: 1.2),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Text(
                  _aiDiagnostic ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: 120, // Taille réduite
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAiResult = false;
                      _stopMission();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 5),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class MissionPainter extends CustomPainter {
  final List<Offset> points;
  final List<Offset> gridPath;
  final bool isValidated;
  final double progress;
  final bool isMissionActive;
  final Color boundaryColor;

  MissionPainter({
    required this.points,
    required this.gridPath,
    required this.isValidated,
    required this.progress,
    required this.isMissionActive,
    required this.boundaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintPolygon = Paint()
      ..color = boundaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
      
    final paintBorder = Paint()
      ..color = boundaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final paintPoint = Paint()
      ..color = boundaryColor
      ..style = PaintingStyle.fill;

    if (points.isNotEmpty) {
      Path path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      if (isValidated) {
        path.close();
        canvas.drawPath(path, paintPolygon);
      }
      canvas.drawPath(path, paintBorder);

      for (var i = 0; i < points.length; i++) {
        canvas.drawCircle(points[i], 4, paintPoint);
      }
    }

    if (isValidated && gridPath.isNotEmpty) {
      final paintGrid = Paint()
        ..color = Colors.white.withAlpha(120)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
        
      final paintProgress = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      Path gPath = Path();
      gPath.moveTo(gridPath[0].dx, gridPath[0].dy);
      for (var i = 1; i < gridPath.length; i++) {
        gPath.lineTo(gridPath[i].dx, gridPath[i].dy);
      }
      canvas.drawPath(gPath, paintGrid);

      if (isMissionActive) {
        Path activePath = _extractSubPath(gPath, progress);
        canvas.drawPath(activePath, paintProgress);
        Offset dronePos = _getOffsetAtProgress(gPath, progress);
        _drawDrone(canvas, dronePos);
      }
    }
  }

  void _drawDrone(Canvas canvas, Offset pos) {
    final paintDrone = Paint()..color = Colors.white;
    const double radius = 12.0;
    canvas.drawCircle(pos, radius, paintDrone);
    canvas.drawCircle(pos, radius, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
    for (int i = 0; i < 4; i++) {
      double angle = (i * 90) * math.pi / 180;
      Offset o1 = Offset(pos.dx + math.cos(angle) * 15, pos.dy + math.sin(angle) * 15);
      canvas.drawCircle(o1, 4, Paint()..color = Colors.grey);
    }
  }

  Path _extractSubPath(Path fullPath, double progress) {
    final metrics = fullPath.computeMetrics();
    Path path = Path();
    for (var metric in metrics) {
      path.addPath(metric.extractPath(0.0, metric.length * progress), Offset.zero);
    }
    return path;
  }

  Offset _getOffsetAtProgress(Path fullPath, double progress) {
    final metrics = fullPath.computeMetrics();
    for (var metric in metrics) {
      final pos = metric.getTangentForOffset(metric.length * progress);
      if (pos != null) return pos.position;
    }
    return points.isNotEmpty ? points[0] : Offset.zero;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 0.5;

    const double step = 30.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
