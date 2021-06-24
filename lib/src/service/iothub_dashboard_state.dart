import 'package:flutter/material.dart';

class DashboardState {
  final _entities = <Widget>[];

  List<Widget> get entities => List.unmodifiable(_entities);

  void addEntity(Widget dashboardWidget) {
    assert(dashboardWidget != null);
    _entities.add(dashboardWidget);
  }
}
