import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class DashboardDeviceCard extends StatelessWidget {
  final List<Device> _devices;
  final IOTHub _selectedIOTHub;

  const DashboardDeviceCard(this._selectedIOTHub, this._devices);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 10.0),
        children: _devices.map((device) => _buildCard(context, device)).toList(),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Device device) {
    return Card(
      key: ValueKey(device.name),
      child: Column(children: [
        ListTile(
          leading: Icon(Icons.attach_file),
          trailing: Icon(Icons.addchart),
          title: Text(device.name),
          subtitle: Text(device.description + ' - ' + device.vendor),
        ),
        _deviceGaugeChart(context, device),
      ]),
    );
  }

  Widget _deviceGaugeChart(BuildContext context, Device device) {
    return On.future<List<Measurement>>(
      onWaiting: () => CommonDataLoadingIndicator(),
      onError: (error, refresher) => Text(ErrorHandler.getErrorMessage(error)),
      //Future can be reinvoked
      onData: (data, refresh) => _measurmentWidget(data),
    ).future(() => IOTHubsMainPage.iotHubService.state.loadLastMeasurement(_selectedIOTHub.id, device));
  }

  Widget _measurmentWidget(List<Measurement<dynamic>> measurements) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: _listMeasurementWidgets(measurements),
      ),
    );
  }

  List<Widget> _listMeasurementWidgets(List<Measurement<dynamic>> measurements) {
    if (measurements.isEmpty) {
      return [Text('No Device data... ')];
    }

    final widgets = <Widget>[];
    widgets.add(Text(
      '${measurements[0].createdAt}',
      style: TextStyle(fontWeight: FontWeight.bold),
    ));

    final termometer = measurements.where((element) => element.property.name == 'temperature').take(1).isNotEmpty;

    if (termometer) {
      widgets.addAll(_temperatureSensorDashboardWidget(measurements));
    } else {
      measurements.forEach((measurement) {
        widgets.add(_commonSensorDashboardWidget(measurement));
      });
    }

    // widgets.add(Flexible(
    //   child: GaugeChart.thermometer(
    //       chartTitle: 'Teplomer', temperature: measurements[0].value as double),
    // ));

    // widgets.add(GaugeChart.thermometer(
    //       chartTitle: 'TeplomerObyvak',
    //       temperature: measurements[0].value as double),
    // );

    return widgets;
  }

  Widget _commonSensorDashboardWidget(final Measurement<dynamic> measurement) {
    return Text.rich(
      TextSpan(
        text: '${measurement.property.name}:    ',
        children: <TextSpan>[
          TextSpan(
            text: '${measurement.value}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _temperatureSensorDashboardWidget(final List<Measurement<dynamic>> measurements) {
    assert(measurements != null);
    assert(measurements.isNotEmpty);

    Measurement<dynamic> temperature;
    Measurement<dynamic> humidity;
    Measurement<dynamic> pressure;

    var otherMeasurements = <Measurement<dynamic>>[];

    measurements.forEach((measurement) {
      if (measurement.property.name == 'temperature') {
        temperature = measurement;
      } else if (measurement.property.name == 'humidity') {
        humidity = measurement;
      } else if (measurement.property.name == 'pressure') {
        pressure = measurement;
      } else {
        otherMeasurements.add(measurement);
      }
    });

    final widgets = <Widget>[];
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        verticalDirection: VerticalDirection.down,
        children: [
          _termometerMeasurementWidget(temperature, Colors.deepOrange),
          if (humidity != null) _termometerMeasurementWidget(humidity, Colors.green),
          if (pressure != null) _termometerMeasurementWidget(pressure, Colors.blue),
        ],
      ),
    );

    otherMeasurements.forEach((measurement) {
      widgets.add(_commonSensorDashboardWidget(measurement));
    });

    return widgets;
  }

  Widget _termometerMeasurementWidget(final Measurement<dynamic> measurement, final MaterialColor color) {
    return Text.rich(
      TextSpan(
        text: '${measurement.property.name}\n',
        style: TextStyle(
          fontSize: 14,
        ),
        children: <TextSpan>[
          TextSpan(
            text: '${measurement.value}',
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
