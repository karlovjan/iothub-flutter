import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class GaugeChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GaugeChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory GaugeChart.withSampleData() {
    return GaugeChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  factory GaugeChart.thermometer({String chartTitle, double temperature}) {
    return GaugeChart(
      _createTemperatureGaugeData(temperature),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return charts.PieChart<dynamic>(seriesList,
        animate: animate,
        // Configure the width of the pie slices to 30px. The remaining space in
        // the chart will be left as a hole in the center. Adjust the start
        // angle and the arc length of the pie so it resembles a gauge.
        defaultRenderer: charts.ArcRendererConfig<dynamic>(
            arcWidth: 30, startAngle: 4 / 5 * pi, arcLength: 7 / 5 * pi));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> _createSampleData() {
    final data = [
      GaugeSegment('Low', 75),
      GaugeSegment('Acceptable', 100),
      GaugeSegment('High', 50),
      GaugeSegment('Highly Unusual', 5),
    ];

    return [
      charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        data: data,
      )
    ];
  }

  static List<charts.Series<TemperatureGaugeSegment, String>> _createTemperatureGaugeData(double temperature) {
    final data = [
      TemperatureGaugeSegment('Low', 18),
      TemperatureGaugeSegment('Actual', temperature),
      TemperatureGaugeSegment('High', 25),
    ];

    return [
      charts.Series<TemperatureGaugeSegment, String>(
        id: 'DeviceThermometerNameGauge',
        domainFn: (TemperatureGaugeSegment segment, _) => segment.segment,
        measureFn: (TemperatureGaugeSegment segment, _) => segment.temperature,
        data: data,
      )
    ];
  }
}

/// Sample data type.
class GaugeSegment {
  final String segment;
  final int size;

  GaugeSegment(this.segment, this.size);
}

class TemperatureGaugeSegment {
  final String segment;
  final double temperature;

  TemperatureGaugeSegment(this.segment, this.temperature);
}