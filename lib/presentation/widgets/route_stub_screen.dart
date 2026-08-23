import 'package:flutter/material.dart';

/// Placeholder until the real screen exists (T013). Not a Stitch frame.
class RouteStubScreen extends StatelessWidget {
  const RouteStubScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
