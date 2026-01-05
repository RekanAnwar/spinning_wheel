import 'dart:math'; // For random number generation

import 'package:flutter/material.dart';
import 'package:spinning_wheel/controller/spin_controller.dart';
import 'package:spinning_wheel/spinning_wheel.dart'; // Import your package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spinning Wheel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // double _startRotation = 0.0;
  // double _endRotation = 0.0;

  SpinnerController controller = SpinnerController();
  late AnimationController _zoomController;

  bool _isSpinning = false;
  String _result = 'spin the wheel';
  int _score = 0;
  //total spins
  int _spinsRemaining = 5;
  bool _showConfetti = false;

  final List<WheelSegment> _segments = [
    WheelSegment('+1 spin', const Color(0xFFB21E25), 1,
        path: 'assets/images/coala.png'), // Soft White
    WheelSegment('50', const Color(0xFFFFEAB9), 50,
        path: 'assets/images/bunny.png'), // Royal Blue
    WheelSegment('200', const Color(0xFFB21E25), 200,
        path: 'assets/images/lion.png'), // Emerald Green
    WheelSegment('10', const Color(0xFFFFEAB9), 10,
        path: 'assets/images/cheeseMouse.png'), // Gold
    WheelSegment(
      'Network Img',
      const Color(0xFFB21E25),
      0,
      path:
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
    ), // Bright Orange
    WheelSegment('LOSE ALL', const Color(0xFFFFEAB9), -9999,
        path: 'assets/images/bat.png'), // Deep Chocolate Brown
  ];

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  Future<void> _spinWheel() async {
    if (_isSpinning || _spinsRemaining <= 0) return;

    setState(() {
      _spinsRemaining--;
      _isSpinning = true;
      _result = "Getting result from server...";
      _showConfetti = false;
    });

    // Reset zoom
    _zoomController.reset();

    // 1. Start simulated "loading" spin (infinite)
    controller.startLoadingSpin();

    // 2. Simulate server request delay
    await Future.delayed(const Duration(seconds: 2));

    // 3. Simulate server response (randomly picking a winner index)
    // In a real app, this index would come from your API
    final random = Random();
    final serverWinningIndex = random.nextInt(_segments.length);

    final winningSegment = _segments[serverWinningIndex];
    print(
        "Server says winner is: ${winningSegment.label} (Index: $serverWinningIndex)");

    // 4. Smoothly transition to the result
    await controller.spinToIndex(serverWinningIndex);

    // 5. Trigger full-screen zoom animation after spin completes and stay zoomed
    await _zoomController.forward();
  }

  void _showGameOverDialog() {
    Future.delayed(Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.indigo.shade50,
            title: Text(
              "Game Over",
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, size: 60, color: Colors.amber),
                SizedBox(height: 16),
                Text(
                  "your final score:",
                  style: TextStyle(color: Colors.indigo.shade800),
                ),
                SizedBox(height: 8),
                Text(
                  _score.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _resetGame();
                  },
                  label: Text("Play Again"),
                  icon: Icon(Icons.replay),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _spinsRemaining = 5;
      _result = "spin the wheel";
      _showConfetti = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8F4F8), // Light cyan at top
              Color(0xFFFFFFFF), // White at bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // App bar with back button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Title
                  Text(
                    "SPIN",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Subtitle
                  Text(
                    "Win with Korek",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E5E),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "You have earned $_spinsRemaining spin,\nspin the wheel to earn prizes",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Spinning Wheel
                  SizedBox(
                    width: size.width - 40,
                    child: SpinnerWheel(
                      controller: controller,
                      zoomController: _zoomController,
                      segments: _segments,
                      onComplete: (win, index) {
                        print("index......$index");
                        setState(() {
                          if (win.value == -9999) {
                            _score = 0;
                            _result = "you lost All";
                            _showConfetti = false;
                          } else if (win.value == 1) {
                            _result = 'you got 1 spin';
                            _spinsRemaining++;
                            _showConfetti = false;
                          } else if (win.value > 200) {
                            _score += win.value;
                            _result = 'you won ${win.label}!';
                            _showConfetti = true;
                          } else {
                            _score += win.value;
                            _result = "you won ${win.label}!";
                            _showConfetti = win.value >= 500;
                          }

                          _isSpinning = false;

                          if (_spinsRemaining <= 0) {
                            _showGameOverDialog();
                          }
                        });
                      },
                    ),
                  ),

                  // AnimatedContainer(
                  //   duration: Duration(milliseconds: 300),
                  //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  //   decoration: BoxDecoration(
                  //     color: _showConfetti
                  //         ? Colors.amber.withValues(alpha: 0.9)
                  //         : Colors.white.withValues(alpha: 0.2),
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(
                  //       color: _showConfetti
                  //           ? Colors.amber.shade700
                  //           : Colors.white.withValues(alpha: 0.3),
                  //     ),
                  //     boxShadow: _showConfetti
                  //         ? [
                  //             BoxShadow(
                  //               color: Colors.amber.withValues(alpha: 0.5),
                  //               blurRadius: 10,
                  //               spreadRadius: 2,
                  //             ),
                  //           ]
                  //         : [],
                  //   ),
                  //   child: Text(
                  //     _result,
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       color: _showConfetti
                  //           ? Colors.brown.shade900
                  //           : Colors.white,
                  //       fontSize: 22,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  const Spacer(),
                  // Spin Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSpinning ? null : _spinWheel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          _isSpinning ? "Spinning..." : "Spin The Wheel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
