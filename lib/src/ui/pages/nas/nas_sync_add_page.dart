import 'package:flutter/material.dart';
import 'package:iothub/src/domain/value_objects/sync_form_data.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../service/nas_file_sync_state.dart';
import 'nas_sync_form_widget.dart';
import 'nas_sync_page.dart';

class NasSyncAddPage extends StatefulWidget {
  const NasSyncAddPage({Key? key}) : super(key: key);

  @override
  _NasSyncAddPageState createState() => _NasSyncAddPageState();
}

class _NasSyncAddPageState extends State<NasSyncAddPage> {
  final _syncForm = NasSyncFormWidget(
    key: GlobalKey<NasSyncFormWidgetState>(),
    initialValue: SyncFormData(
        '', '', '', DateTime.now(), DateTime.now(), FileTypeForSync.image),
    showRangeDateBar: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new synchronization'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Close IOT HUb',
          onPressed: () {
            // await RM.navigate.toNamed(StaticPages.iotHUBApp.routeName);
            RM.navigate.back();
          },
        ),
      ),
      body: _syncForm,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          NasSyncFormWidgetState? formState =
              (_syncForm.key as GlobalKey<NasSyncFormWidgetState>).currentState;
          if (formState!.validate()) {
            formState.save();

            await NASSyncMainPage.syncPreferencesRepository
                .add(formState.value.toJson());

            RM.navigate.back();
          }
        },
        child: const Icon(Icons.save_rounded),
        backgroundColor: Colors.green,
      ),
    );
  }
}
