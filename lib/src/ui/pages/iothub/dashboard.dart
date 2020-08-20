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
    return Injector(
      //Inject Model instance into the widget tree.
      inject: [Inject<List<Measurement<dynamic>>>(() => <Measurement>[])],
      builder: (context) {
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
          body: _buildBody(context),
        );
      },
    );

  }

  Widget _buildBody(BuildContext context) {
//    return GaugeChart.withSampleData();
    return WhenRebuilderOr<List<Measurement>>(
      //Create a new ReactiveModel with the stream method.

      observe: () => RM.get<List<Measurement>>().stream((state, subscription) {
        //It exposes the current state and the current StreamSubscription.
        return service.state.deviceAllMeasurementStream(
            service.state.selectedIOTHub.id, Device('Test teplomer', id: '1', properties: _testMeasuredPropertyList()));
      }),
      onWaiting: () => CommonDataLoadingIndicator(),
      onSetState: (context, modelRM) {
        if (modelRM.hasError) {
          ErrorHandler.showErrorSnackBar(context, modelRM.error);
        }
      },
      builder: (context, modelRM) {
        return Column(
          children: _listMeasurementWidgets(modelRM.state),
        );
      },
    );
  }

  List<Widget> _listMeasurementWidgets(
      List<Measurement<dynamic>> measurements) {
    final widgets = <Widget>[];
    for (var measurement in measurements) {
      widgets.add(Text('${measurement.property.name}: ${measurement.value} - ${measurement.createdAt}'));
    }

    return widgets;
  }

  List<MeasuredProperty> _testMeasuredPropertyList() {

    final mp1 = MeasuredProperty('temperature', 'C');
    final mp2 = MeasuredProperty('humidity', 'X');
    final mp3 = MeasuredProperty('pressure', 'Pa');

    return [mp1, mp2, mp3];
  }
}
