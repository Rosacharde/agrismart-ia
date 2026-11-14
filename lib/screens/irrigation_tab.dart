import 'package:flutter/material.dart';
import 'package:agri_app/services/api_service.dart';
import 'package:agri_app/models/data_models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IrrigationTab extends StatefulWidget {
  final ChampVirtuel champ;
  
  const IrrigationTab({Key? key, required this.champ}) : super(key: key);

  @override
  _IrrigationTabState createState() => _IrrigationTabState();
}

class _IrrigationTabState extends State<IrrigationTab>
    with TickerProviderStateMixin {
  
  // États possibles: idle, checking, watering, humid
  String _state = 'idle';
  double? _humidityLevel;
  String _message = 'Appuyez pour vérifier et arroser';
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  late AnimationController _iconBounceController;
  late Animation<double> _iconBounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation de pulsation du cercle
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Animation d'ondulation (ripple)
    _rippleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Animation de rebond de l'icône
    _iconBounceController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _iconBounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _iconBounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _iconBounceController.dispose();
    super.dispose();
  }

  Color _getCircleColor() {
    switch (_state) {
      case 'checking':
        return Color(0xFF42A5F5); // Bleu pendant vérification
      case 'watering':
        return Color(0xFF43A047); // Vert - arrosage en cours
      case 'humid':
        return Color(0xFFE53935); // Rouge - sol déjà humide
      default:
        return Color(0xFF42A5F5); // Bleu par défaut - idle
    }
  }

  Color _getCircleGlowColor() {
    switch (_state) {
      case 'watering':
        return Color(0xFF43A047);
      case 'humid':
        return Color(0xFFE53935);
      default:
        return Color(0xFF42A5F5);
    }
  }

  IconData _getIcon() {
    switch (_state) {
      case 'checking':
        return Icons.hourglass_top_rounded;
      case 'watering':
        return FontAwesomeIcons.droplet;
      case 'humid':
        return Icons.water_drop_outlined;
      default:
        return FontAwesomeIcons.droplet;
    }
  }

  Future<void> _onCircleTapped() async {
    if (_state == 'checking' || _state == 'watering') return; // Déjà en cours

    setState(() {
      _state = 'checking';
      _message = 'Vérification de l\'humidité du sol...';
    });

    // Lancer l'animation de pulsation pendant la vérification
    _pulseController.repeat(reverse: true);

    try {
      // Appel API pour vérifier l'humidité
      final response = await ApiService.getSoilHumidity(widget.champ.id);

      if (response != null && response['success'] == true) {
        final humidity = (response['humidity_level'] as num).toDouble();
        final needsWatering = response['needs_watering'] == true;

        _humidityLevel = humidity;

        if (needsWatering) {
          // Sol sec → Lancer l'arrosage
          setState(() {
            _state = 'watering';
            _message = '🟢 Arrosage en cours...';
          });
          _pulseController.repeat(reverse: true);
          _rippleController.repeat();
          _iconBounceController.forward(from: 0);

          // Appel API pour démarrer l'irrigation
          await ApiService.controlIrrigation(widget.champ.id, 'START');

        } else {
          // Sol humide → Afficher le message rouge
          _pulseController.stop();
          _pulseController.reset();
          _iconBounceController.forward(from: 0);
          
          setState(() {
            _state = 'humid';
            _message = '🔴 Sol déjà humide (${humidity.toStringAsFixed(0)}%)';
          });

          // Réinitialiser après 5 secondes
          Future.delayed(Duration(seconds: 5), () {
            if (mounted) {
              _resetState();
            }
          });
        }
      } else {
        _pulseController.stop();
        _pulseController.reset();
        setState(() {
          _state = 'idle';
          _message = '❌ Erreur de communication avec le capteur';
        });
      }
    } catch (e) {
      _pulseController.stop();
      _pulseController.reset();
      setState(() {
        _state = 'idle';
        _message = '❌ Erreur de connexion';
      });
    }
  }

  void _resetState() {
    _pulseController.stop();
    _pulseController.reset();
    _rippleController.stop();
    _rippleController.reset();
    setState(() {
      _state = 'idle';
      _message = 'Appuyez pour vérifier et arroser';
      _humidityLevel = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final circleColor = _getCircleColor();
    final glowColor = _getCircleGlowColor();
    
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
                            'Irrigation',
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
                    if (_state == 'watering')
                      GestureDetector(
                        onTap: () async {
                          await ApiService.controlIrrigation(widget.champ.id, 'STOP');
                          _resetState();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.stop_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text('STOP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ===== CONTENU PRINCIPAL =====
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ===== ROND INTERACTIF =====
                      GestureDetector(
                        onTap: _onCircleTapped,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_pulseController, _rippleController]),
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ondulation externe (ripple) en mode arrosage
                                if (_state == 'watering')
                                  ...List.generate(3, (index) {
                                    final delay = index * 0.3;
                                    final progress = ((_rippleAnimation.value + delay) % 1.0);
                                    return Container(
                                      width: 160 + (progress * 80),
                                      height: 160 + (progress * 80),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: glowColor.withOpacity(0.3 * (1 - progress)),
                                          width: 2,
                                        ),
                                      ),
                                    );
                                  }),
                                
                                // Halo lumineux
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: glowColor.withOpacity(
                                          _state == 'idle' ? 0.15 : 0.35
                                        ),
                                        blurRadius: _state == 'watering' ? 40 : 25,
                                        spreadRadius: _state == 'watering' ? 10 : 5,
                                      ),
                                    ],
                                  ),
                                ),

                                // Cercle principal
                                Transform.scale(
                                  scale: (_state == 'checking' || _state == 'watering') 
                                      ? _pulseAnimation.value 
                                      : 1.0,
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          circleColor.withOpacity(0.9),
                                          circleColor,
                                        ],
                                        center: Alignment(-0.2, -0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: circleColor.withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: _state == 'checking'
                                        ? Center(
                                            child: SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          )
                                        : AnimatedBuilder(
                                            animation: _iconBounceAnimation,
                                            builder: (context, child) {
                                              return Transform.translate(
                                                offset: Offset(0, _iconBounceAnimation.value),
                                                child: Icon(
                                                  _getIcon(),
                                                  color: Colors.white,
                                                  size: 60,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 40),

                      // ===== MESSAGE =====
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        child: Container(
                          key: ValueKey(_message),
                          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _getCircleColor().withOpacity(0.15),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _state == 'watering'
                                  ? Color(0xFF2E7D32)
                                  : _state == 'humid'
                                      ? Color(0xFFC62828)
                                      : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // ===== HUMIDITÉ AFFICHÉE =====
                      if (_humidityLevel != null)
                        AnimatedOpacity(
                          opacity: _humidityLevel != null ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _state == 'watering' 
                                    ? Color(0xFF43A047).withOpacity(0.3) 
                                    : Color(0xFFE53935).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: _state == 'watering' ? Color(0xFF43A047) : Color(0xFFE53935),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Humidité: ${_humidityLevel!.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}