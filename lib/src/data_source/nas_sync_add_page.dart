import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../ui/pages/nas/nas_sync_form_widget.dart';

class NasSyncAddPage extends StatefulWidget {
  const NasSyncAddPage({Key? key}) : super(key: key);

  @override
  _NasSyncAddPageState createState() => _NasSyncAddPageState();
}

class _NasSyncAddPageState extends State<NasSyncAddPage> {

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
      body: const NasSyncFormWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FormState? formState = Form.of(context);
          if (formState != null && formState.validate()) {
            formState.save();

            // formState.widget.child.
            // NASSyncMainPage.syncPreferencesRepository.write('', value)
          }
        },
        child: const Icon(Icons.save_rounded),
        backgroundColor: Colors.green,
      ),
    );
  }
}
