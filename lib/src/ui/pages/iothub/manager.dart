import 'package:flutter/material.dart';

class DashboardManagerPage extends StatelessWidget {
  const DashboardManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard manager'),
      ),
      // body is the majority of the screen.
      body: _buildBody(context),
    );

  }

  Widget _buildBody(BuildContext context) {
    //TODO
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Close'),
    );
  }

}