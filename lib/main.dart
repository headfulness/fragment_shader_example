// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is an example app showing how to load assets listed in the
// 'shader' section of the 'flutter' manifest in the pubspec.yaml file.
// A shader asset is loaded as a [FragmentProgram] object using the
// `FragmentProgram.fromAsset()` method. Then, [Shader] objects can be obtained
// by passing uniform values to the `FragmentProgram.shader()` method.
// The animation of a shader can be driven by passing the value of a Flutter
// [Animation] as one of the float uniforms of the shader program. In this
// example, the value of the animation is expected to be passed as the
// float uniform at index 0.
//
// The changes in https://github.com/flutter/engine/pull/35253 are a
// breaking change to the [FragmentProgram] API. The compensating changes are
// noted below as `TODO` items. The API is changing to allow re-using
// the float uniform buffer between frames.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() {
  runApp(const MyApp());
}

/// A standard Material application container, like you'd get from Flutter's
/// "Hello, world!" example.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shader Example',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Shader Example Home Page'),
    );
  }
}

/// The body of the app. We'll use this stateful widget to manage initialization
/// of the shader program.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // _initializeFutures();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const CloudShaderWidget();
  }
}

class CloudShaderWidget extends StatefulWidget {
  const CloudShaderWidget({super.key});

  @override
  _CloudShaderWidgetState createState() => _CloudShaderWidgetState();
}

class _CloudShaderWidgetState extends State<CloudShaderWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late Duration _startTime;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTime = Duration.zero; // Initialize start time
    _ticker = Ticker((elapsed) {
      setState(() {
        _elapsed = elapsed; // Update elapsed time since the ticker started
      });
    });
    _ticker.start(); // Start the ticker for continuous updates
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      assetKey: 'shaders/clouds.frag', // Path to your shader file
      (context, shader, child) {
        return CustomPaint(
          painter: _CloudShaderPainter(
            shader,
            time: _elapsed.inMilliseconds / 1000.0, // Elapsed time in seconds
          ),
          // size: MediaQuery.of(context).size, // Full screen size
          // size: MediaQuery.sizeOf(context), // Full screen size
        );
      },
    );
  }
}

class _CloudShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;

  _CloudShaderPainter(this.shader, {required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // print(size.width.toString() + " " + size.height.toString());
    shader
      ..setFloat(0, time) // Pass iTime (elapsed time)
      ..setFloat(1, size.height) // Pass iResolution.x
      ..setFloat(2, size.width); // Pass iResolution.y

    final paint = Paint()..shader = shader;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.height, size.width),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CloudShaderPainter oldDelegate) {
    return time != oldDelegate.time; // Ensures continuous repainting
  }
}

class OceanShaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      assetKey: 'shaders/oceanwaves.frag', // Path to your shader file
      (context, shader, child) {
        return CustomPaint(
          painter: _OceanShaderPainter(shader),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _OceanShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;

  _OceanShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    double time =
        DateTime.now().millisecondsSinceEpoch / 1000.0; // Continuous time
    shader
      ..setFloat(0, time) // iTime
      ..setFloat(1, size.width) // iResolution.x
      ..setFloat(2, size.height); // iResolution.y

    final paint = Paint()..shader = shader;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Continuous repainting
  }
}
