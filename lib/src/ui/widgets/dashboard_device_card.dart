import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class DashboardDeviceCard extends StatelessWidget {
  final List<Device> devices;
  final ReactiveModel<IOTHubService> iotHubService;

  DashboardDeviceCard({@required this.devices, this.iotHubService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 20.0),
        children: devices.map((device) => _buildCard(context, device)).toList(),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _deviceGaugeChart(context, device),
        ),
      ]),
    );
  }

  Widget _deviceGaugeChart(BuildContext context, Device device) {
    return WhenRebuilderOr<List<Measurement>>(
      //Create a new ReactiveModel with the stream method.

      observe: () => RM.stream(
        iotHubService.state.deviceAllMeasurementStream(
            iotHubService.state.selectedIOTHub.id, device),
      ),
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
    widgets.add(Text('${measurements[0].createdAt}'));
    measurements.forEach((measurement) {
      widgets.add(Text('${measurement.property.name}: ${measurement.value}'));
    });

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
}
