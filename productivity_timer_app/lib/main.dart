import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  int _remainingSeconds = 0;
  int _endTime = 0;
  late Timer _timer =
      Timer(Duration.zero, () {}); // Initialize with an empty timer
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isPaused = false;
  int _pausedTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void startTimer(int minutes) {
    setState(() {
      _remainingSeconds = minutes * 60;
      _endTime =
          DateTime.now().millisecondsSinceEpoch + (_remainingSeconds * 1000);
      _fadeController.reset();
      _isPaused = false;
      _pausedTime = 0;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        setState(() {
          _remainingSeconds = ((_endTime - currentTime) / 1000).round();
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          print('Timer completed!');
          _fadeController
              .forward(); // Start fading animation when timer completes
        }
      }
    });
  }

  void togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        _pausedTime =
            _remainingSeconds - ((_endTime - currentTime) / 1000).round();
      }
    });
  }

  void resumeTimer() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    _endTime = currentTime + (_pausedTime * 1000);
    startTimer(_pausedTime ~/ 60);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter minutes',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int minutes = int.tryParse(_controller.text) ?? 0;
                if (minutes > 0) {
                  if (_timer.isActive) {
                    _timer.cancel(); // Cancel the existing timer if active
                  }
                  startTimer(minutes);
                }
              },
              child: Text('Start Timer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isPaused) {
                  resumeTimer();
                } else {
                  togglePause();
                }
              },
              child: Text(_isPaused ? 'Resume' : 'Pause'),
            ),
            SizedBox(height: 20),
            Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                'Time remaining: ${_remainingSeconds ~/ 60} minutes ${_remainingSeconds % 60} seconds',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
