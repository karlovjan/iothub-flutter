import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class GaugeChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  static const double _low = 16.0;
  static const double _high = 26.0;

  GaugeChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with temperature data and no transition.
  factory GaugeChart.thermometer(
      {@required String chartTitle, @required double temperature}) {
    return GaugeChart(
      _createTemperatureGaugeData(chartTitle, temperature),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart<String>(seriesList,
        animate: animate,
        // Configure the width of the pie slices to 30px. The remaining space in
        // the chart will be left as a hole in the center. Adjust the start
        // angle and the arc length of the pie so it resembles a gauge.
        defaultRenderer: charts.ArcRendererConfig<String>(
            arcWidth: 50,
            startAngle: -pi,
            arcLength: pi,
            arcRendererDecorators: [charts.ArcLabelDecorator()]));
  }

  static List<charts.Series<double, String>> _createTemperatureGaugeData(
      String title, double temperature) {
    final data = [
      // TemperatureGaugeSegment('Low', 18),
      _low - 1.0,
      temperature,
      _high,
      // TemperatureGaugeSegment('High', 25),
    ];

    return [
      charts.Series<double, String>(
        id: 'DeviceThermometerNameGauge',
        domainFn: (double temperature, _) => temperature < _low
            ? 'Low'
            : (temperature >= _high ? 'High' : 'Normal'),
        measureFn: (double temperature, _) => temperature,
        data: data,
        displayName: title ?? 'Temperature',
        // domainLowerBoundFn: (datum, index) => 'Low',
        // domainUpperBoundFn: (datum, index) => 'High',
        // measureLowerBoundFn: (datum, index) => 0,
        // measureUpperBoundFn: (datum, index) => 40,
        labelAccessorFn: (m, _) => '${m} C',
        // fillColorFn: (m, _) => m < _low
        //     ? charts.ColorUtil.fromDartColor(Color.fromARGB(255, 255, 128, 0))
        //     : (m >= _high ? charts.ColorUtil.fromDartColor(Color.fromARGB(255, 255, 0, 0)) : charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 255, 0))),
        colorFn: (m, _) => m < _low
            ? charts.ColorUtil.fromDartColor(Color.fromARGB(255, 255, 128, 0))
            : (m >= _high
                ? charts.ColorUtil.fromDartColor(Color.fromARGB(255, 255, 0, 0))
                : charts.ColorUtil.fromDartColor(
                    Color.fromARGB(255, 0, 255, 0))),
        // areaColorFn: (m, _) => m < _low
        //     ? charts.ColorUtil.fromDartColor(Color.fromARGB(255, 255, 128, 0))
        //     : (m >= _high ? charts.ColorUtil.fromDartColor(Color.fromARGB(255, 255, 0, 0)) : charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 255, 0))),
      ),
    ];
  }
}

class TemperatureGaugeSegment {
  final int segment;
  final double temperature;

  TemperatureGaugeSegment(this.segment, this.temperature);
}
