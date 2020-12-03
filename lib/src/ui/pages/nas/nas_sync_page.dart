import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iothub/src/data_source/http_nas_file_sync_service.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//  https://github.com/GIfatahTH/states_rebuilder/tree/master/examples/ex_009_1_3_ca_todo_mvc_with_state_persistence
//https://flutter.dev/docs/cookbook/forms
//https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/lib/src/file_picker_demo.dart

//Although foo is global, the state is not.
//The state is automatically cleaned when no longer used.
//The state is easily mocked and tested
final nasFileSyncState =
    RM.inject(() => NASFileSyncState(RM.inject<NASFileSyncService>(() => HTTPNASFileSyncService()).state));

///Class showing a page for setting a NAS folder
class NASSyncMainPage extends StatefulWidget {
  const NASSyncMainPage({Key key}) : super(key: key);

  @override
  _SyncPathEditFormState createState() => _SyncPathEditFormState();
}

class _SyncPathEditFormState extends State<NASSyncMainPage> {
  final _formKey = GlobalKey<FormState>();
  final _localFolderPathTextFieldController = TextEditingController(text: '/home/mbaros/Pictures/Prukaz');

  // Here we use a StatefulWidget to hold local fields _nasFolder and _localFolder
  String _nasFolder;

  // String _localFolder;

  String _extension;
  bool _multiPick = true;
  FileType _pickingType = FileType.any;
  List<PlatformFile> _paths;

  @override
  void dispose() {
    _localFolderPathTextFieldController.dispose();
    _clearCachedFiles();
    super.dispose();
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _localFolderPathTextFieldController.text = value);
    });
  }

  void _openFileExplorer() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false) ? _extension?.replaceAll(' ', '')?.split(',') : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print('Unsupported operation' + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      // _loadingPath = false;
      _localFolderPathTextFieldController.text = _paths != null ? _paths.map((e) => e.name).toString() : '...';
    });
  }

  void _clearCachedFiles() {
    if (kIsWeb) {
      return; //not implemented on Web
    }

    FilePicker.platform.clearTemporaryFiles().then(
      (result) {
        if (result) {
          print('Temporary files removed with success.');
        } else {
          print('Temporary files was not removed.');
        }
      },
      onError: (e) => print('Failed to clean temporary files ${e.toString()}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Synchronize to NAS',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidate: false,
          onWillPop: () {
            return Future(() => true);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: Key('__NASFolderField'),
                initialValue: '/home/mbaros/Pictures/test',
                // initialValue: 'public/photos/miron/phonePhotos',
                //public/photos/miron/phoneVideos
                //public/photos/miron/whatsapp/2020_photos
                //public/photos/miron/whatsapp/2020_video
                autofocus: false,
                style: Theme.of(context).textTheme.headline5,
                decoration: InputDecoration(hintText: 'Enter NAS folder'),
                validator: (val) => val.trim().isEmpty ? 'Cannot be empty' : null,
                onSaved: (value) => _nasFolder = value,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: Key('__LocalFolderField'),
                      // initialValue: '', nesmi byt nastaven kdyz se pouzije controller
                      style: Theme.of(context).textTheme.headline5,
                      decoration: InputDecoration(
                        hintText: 'Enter local folder',
                      ),
                      validator: (val) => val.trim().isEmpty ? 'Cannot be empty' : null,
                      controller: _localFolderPathTextFieldController,
                      // onSaved: (value) => _localFolder = value,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!kIsWeb) {
                        _selectFolder();
                      } else {
                        ErrorHandler.showErrorDialog(context, NASFileException('Opening a folder is not allowed on the Web!'));
                      }

                      },
                    child: Text('Pick local folder'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      form.save();

                      nasFileSyncState.state.initSync();

                      try {
                        final transferedFileStream = nasFileSyncState.state
                            .syncFolderWithNAS(_localFolderPathTextFieldController.value.text, _nasFolder);

                        await for (var transferedFile in transferedFileStream) {
                          await nasFileSyncState.setState((s) => s.transferedFile = transferedFile.fileName);
                        }
                      } catch (e) {

                        ErrorHandler.showErrorDialog(context, e);
                      }
                    }
                  },
                  child: Text('Synchronize'),
                ),
              ),
              nasFileSyncState.whenRebuilderOr(
                onIdle: () => Text('No transferred file'),
                onError: (e) => Text('error : $e'),
                builder: () => Text(nasFileSyncState.state.transferedFile ?? '...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
