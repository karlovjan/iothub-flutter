import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:iothub/src/data_source/http_dio_nas_file_sync_service.dart';
import 'package:iothub/src/data_source/nas_sync_add_page.dart';
import 'package:iothub/src/data_source/nas_sync_preferences_repository.dart';
import 'package:iothub/src/domain/value_objects/sync_form_data.dart';
import 'package:iothub/src/service/local_file_system_util.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/nas/nas_sync_run_page.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//  https://github.com/GIfatahTH/states_rebuilder/tree/master/examples/ex_009_1_3_ca_todo_mvc_with_state_persistence
//https://flutter.dev/docs/cookbook/forms
//https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/lib/src/file_picker_demo.dart

///Class showing a page for setting a NAS folder
class NASSyncMainPage extends StatefulWidget {
  const NASSyncMainPage({Key? key}) : super(key: key);

  //TODO prevest do konfigurace, staci jen staticke - a zavisle na prostredi - devel, test, produkce - nas.local:8443
  static late final nasFileSyncState = RM.inject<NASFileSyncState>(
    () => NASFileSyncState(
        //smbrest.home
        DIOHTTPNASFileSyncService('192.168.0.24', 'assets/certs/ca.crt',
            'assets/certs/smbresthomeclient.p12'),
        LocalFileSystemUtil()),
    sideEffects: SideEffects.onError(
        (err, refresh) => ErrorHandler.showErrorDialog(err)),
  );

  static final NasSyncPreferencesRepository syncPreferencesRepository =
      NasSyncPreferencesRepository();

  @override
  _SyncPathEditFormState createState() => _SyncPathEditFormState();
}

class _SyncPathEditFormState extends State<NASSyncMainPage> {
  final _initSyncPrefFuture = NASSyncMainPage.syncPreferencesRepository.init();

  @override
  void dispose() {
    NASSyncMainPage.nasFileSyncState.state.clearFiles();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Synchronize files to NAS',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Close IOT HUb',
          onPressed: () {
            // await RM.navigate.toNamed(StaticPages.iotHUBApp.routeName);
            RM.navigate.back();
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initSyncPrefFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PreferencesLoadingIndicator();
          }

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('cannot load saved synchronization items. Error: ' +
                  ErrorHandler.getErrorMessage(snapshot.error));
            } else {
              return ValueListenableBuilder(
                valueListenable:
                    Hive.box(NasSyncPreferencesRepository.boxName).listenable(),
                builder: (context, Box box, _) => _syncDataListView(box),
              );
            }
          }
          return const Text('Sync preferences was not loaded...');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          RM.navigate.to(const NasSyncAddPage());
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _syncDataListView(Box box) {
    return ListView.builder(
      itemCount: box.length,
      itemBuilder: (context, index) {
        SyncFormData item = SyncFormData.fromJson(box.getAt(index));
        return ListTile(
          key: ObjectKey(item),
          title: Text(item.name + ' - ' + item.fileType.name),
          subtitle: Text(
              item.remoteFolder + ' / ' + DateFormat.yMd().format(item.to)),
          leading: const IconButton(
            icon: Icon(Icons.open_in_new),
            onPressed: null,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  tooltip: 'Edit sync data',
                  onPressed: () {},
                  icon: const Icon(Icons.edit)),
              IconButton(
                  tooltip: 'remove sync data',
                  onPressed: () {
                    NASSyncMainPage.syncPreferencesRepository.deleteAt(index);
                  },
                  icon: const Icon(Icons.delete_forever)),
            ],
          ),
          onTap: () {
            RM.navigate.to(NASSyncRunPage(
              syncDataIndex: index,
            ));
          },
          isThreeLine: true,
        );
      },
    );
  }
}
