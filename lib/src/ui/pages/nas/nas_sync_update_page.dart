import 'package:flutter/material.dart';
import 'package:iothub/src/domain/value_objects/sync_form_data.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'nas_sync_form_widget.dart';
import 'nas_sync_page.dart';

class NasSyncUpdatePage extends StatefulWidget {
  final int syncDataIndex;

  const NasSyncUpdatePage({Key? key, required this.syncDataIndex})
      : super(key: key);

  @override
  _NasSyncUpdatePageState createState() => _NasSyncUpdatePageState();
}

class _NasSyncUpdatePageState extends State<NasSyncUpdatePage> {
  final _syncFormGlobalKey = GlobalKey<NasSyncFormWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit synchronization'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Close IOT HUb',
          onPressed: () {
            // await RM.navigate.toNamed(StaticPages.iotHUBApp.routeName);
            RM.navigate.back();
          },
        ),
      ),
      body: NasSyncFormWidget(
        key: _syncFormGlobalKey,
        initialValue: SyncFormData.fromJson(NASSyncMainPage
            .syncPreferencesRepository
            .readAt(widget.syncDataIndex)),
        showRangeDateBar: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          NasSyncFormWidgetState? formState = _syncFormGlobalKey.currentState;
          if (formState?.validate() ?? false) {
            formState!.save();

            await NASSyncMainPage.syncPreferencesRepository
                .update(widget.syncDataIndex, formState.value.toJson());

            RM.navigate.back();
          }
        },
        child: const Icon(Icons.save_rounded),
        backgroundColor: Colors.green,
      ),
    );
  }
}
