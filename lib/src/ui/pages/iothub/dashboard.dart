import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/measured_property.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/charts/gauge_chart.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iothub/dashboard/manager.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class IOTHubDashboardPage extends StatelessWidget {
  final service = RM.get<IOTHubService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ' + service.state.selectedIOTHub?.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.build),
            tooltip: 'Manage Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<DashboardManagerPage>(
                    builder: (context) => DashboardManagerPage()),
              );
            },
          ),
        ],
      ),
      // body is the majority of the screen.
      body: _buildDashboardBody(context),
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
//    return GaugeChart.withSampleData();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_deviceGaugeChart(context)],
    );
  }

  Widget _deviceGaugeChart(BuildContext context) {
    return WhenRebuilderOr<List<Measurement>>(
      //Create a new ReactiveModel with the stream method.
//TODO selected Device from dashboard Model
      observe: () => RM.stream(service.state.deviceAllMeasurementStream(
          service.state.selectedIOTHub.id,
          Device('Test teplomer',
              id: '1', properties: _testMeasuredPropertyList()))),
      onWaiting: () => CommonDataLoadingIndicator(),
      onSetState: (context, modelRM) {
        if (modelRM.hasError) {
          ErrorHandler.showErrorSnackBar(context, modelRM.error);
        }
      },
      onError: (error) {
        return Center(child: Text(error.toString()));
        },
      builder: (context, modelRM) {
        return Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _listMeasurementWidgets(modelRM.snapshot.data),
              ),
            );
      },
    );
  }

  List<Widget> _listMeasurementWidgets(
      List<Measurement<dynamic>> measurements) {
    if (measurements.isEmpty) {
      return [Text('No Device data... ')];
    }
    final widgets = <Widget>[];
    measurements.forEach((measurement) {
      widgets.add(Text(
          '${measurement.property.name}: ${measurement.value} - ${measurement.createdAt}'));
    });
//TODO title from device name

    widgets.add(Flexible(
      child: GaugeChart.thermometer(
          chartTitle: 'TeplomerObyvak',
          temperature: measurements[0].value as double),
    ));

    // widgets.add(GaugeChart.thermometer(
    //       chartTitle: 'TeplomerObyvak',
    //       temperature: measurements[0].value as double),
    // );

    return widgets;
  }

  List<MeasuredProperty> _testMeasuredPropertyList() {
    final mp1 = MeasuredProperty('temperature', 'C');
    final mp2 = MeasuredProperty('humidity', 'X');
    final mp3 = MeasuredProperty('pressure', 'Pa');

    return [mp1, mp2, mp3];
  }
}
