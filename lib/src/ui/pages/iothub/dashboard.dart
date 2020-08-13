import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/device.dart';
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
                   MaterialPageRoute<DashboardManagerPage>(builder: (context) => DashboardManagerPage()),
                 );
               },
             ),
           ],
      ),
      // body is the majority of the screen.
      body: _buildBody(context),
    );

  }


  Widget _buildBody(BuildContext context) {
    return GaugeChart.withSampleData();
  }

}
