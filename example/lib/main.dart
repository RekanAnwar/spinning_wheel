import 'dart:developer' as dev;
import 'dart:math'; // For random number generation

import 'package:flutter/material.dart';
import 'package:spinning_wheel/controller/spin_controller.dart';
import 'package:spinning_wheel/spinning_wheel.dart'; // Import your package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  // String _result = 'spin the wheel';
  int _score = 0;
  //total spins
  int _spinsRemaining = 5;
  // bool _showConfetti = false;

  final List<WheelSegment> _segments = [
    WheelSegment(
      label: '20,000 د.ع',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: 5,
      path:
          'https://minio.a.trytiptop.app/public/public/c1b46fd0-8fb6-4206-930b-5230d2ce732d.png',
    ),
    WheelSegment(
      label: 'New Bashar Seafood Branch Coupon',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: 500,
      path:
          'https://minio.a.trytiptop.app/public/public/e3000311-a99b-49bd-8ec6-7df21c562226.png',
    ),
    WheelSegment(
      label: '1000',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: 1000,
      path:
          'https://minio.a.trytiptop.app/public/public/e3000311-a99b-49bd-8ec6-7df21c562226.png',
    ),
    WheelSegment(
      label: '-100',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: -100,
      path:
          'https://minio.a.trytiptop.app/public/public/c1b46fd0-8fb6-4206-930b-5230d2ce732d.png',
    ),
    WheelSegment(
      label: 'Network Img',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: 0,
      path:
          'https://minio.a.trytiptop.app/public/public/e3000311-a99b-49bd-8ec6-7df21c562226.png',
    ),
    WheelSegment(
      label: 'Free Spin',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: -9999,
      path:
          'https://minio.a.trytiptop.app/public/public/2c3c11d8-864b-4ce2-bd2f-697db6126f02.png',
    ),
    WheelSegment(
      label: 'Free Spin',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: -9999,
      path:
          'https://minio.a.trytiptop.app/public/public/4d7397e8-6168-439d-8cb6-c07fb2a5d545.png',
    ),
    WheelSegment(
      label: 'Free Spin',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: -9999,
      path:
          'https://minio.a.trytiptop.app/public/public/2c3c11d8-864b-4ce2-bd2f-697db6126f02.png',
    ),
    WheelSegment(
      label: 'Free Spin',
      color: Color.fromARGB(
        255,
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
      ),
      value: -9999,
      path:
          'https://minio.a.trytiptop.app/public/public/4d7397e8-6168-439d-8cb6-c07fb2a5d545.png',
    ),
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
      // _result = "Getting result from server...";
      // _showConfetti = false;
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
    dev.log(
        "Server says winner is: ${winningSegment.label} (Index: $serverWinningIndex)");

    // 4. Smoothly transition to the result
    await controller.spinToIndex(serverWinningIndex);

    // 5. Trigger full-screen zoom animation after spin completes and stay zoomed
    await _zoomController.forward();
  }

  void _showGameOverDialog() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;

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
      // _result = "spin the wheel";
      // _showConfetti = false;
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
              Color(0xFF59CBE8), // Light cyan at top
              Color(0xFF003460), // White at bottom
              Color(0xFF003460), // White at bottom
            ],
            stops: [0.05, 0.7, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(20),
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
                  color: Colors.white,
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
                  color: Colors.white,
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
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Spinning Wheel with Stand - wrapped together for zoom animation
              AnimatedBuilder(
                animation: _zoomController,
                builder: (context, child) => Transform.scale(
                  alignment: Alignment.topCenter,
                  scale: Tween<double>(begin: 1.0, end: 2.0)
                      .animate(
                        CurvedAnimation(
                          parent: _zoomController,
                          curve: Curves.easeInOutCubic,
                        ),
                      )
                      .value,
                  child: Column(
                    children: [
                      SizedBox(
                        width: size.width - 40,
                        child: SpinnerWheel(
                          showStand: true,
                          segments: _segments,
                          zoomController: null,
                          controller: controller,
                          onComplete: (win, index) {
                            setState(() {
                              // if (win.value == -9999) {
                              //   _score = 0;
                              //   _result = "you lost All";
                              //   _showConfetti = false;
                              // } else if (win.value == 1) {
                              //   _result = 'you got 1 spin';
                              //   _spinsRemaining++;
                              //   _showConfetti = false;
                              // } else if (win.value > 200) {
                              //   _score += win.value;
                              //   _result = 'you won ${win.label}!';
                              //   _showConfetti = true;
                              // } else {
                              //   _score += win.value;
                              //   _result = "you won ${win.label}!";
                              //   _showConfetti = win.value >= 500;
                              // }

                              _isSpinning = false;

                              if (_spinsRemaining <= 0) {
                                _showGameOverDialog();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              SizedBox(height: 100),

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
        ),
      ),
    );
  }
}
