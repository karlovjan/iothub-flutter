import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:iothub/src/data_source/http_dio_nas_file_sync_service.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//  https://github.com/GIfatahTH/states_rebuilder/tree/master/examples/ex_009_1_3_ca_todo_mvc_with_state_persistence
//https://flutter.dev/docs/cookbook/forms
//https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/lib/src/file_picker_demo.dart

//Although foo is global, the state is not.
//The state is automatically cleaned when no longer used.
//The state is easily mocked and tested

//TODO prevest do konfigurace, staci jen staticke - a zavisle na prostredi - devel, test, produkce - nas.local:8443
final nasFileSyncState =
// RM.inject(() => NASFileSyncState(RM.inject<NASFileSyncService>(() => HTTPNASFileSyncService('smbrest.home')).state));
    RM.inject(
        () => NASFileSyncState(RM.inject<NASFileSyncService>(() => DIOHTTPNASFileSyncService('smbrest.home')).state));

///Class showing a page for setting a NAS folder
class NASSyncMainPage extends StatefulWidget {
  const NASSyncMainPage({Key key}) : super(key: key);

  @override
  _SyncPathEditFormState createState() => _SyncPathEditFormState();
}

class _SyncPathEditFormState extends State<NASSyncMainPage> {
  final _formKey = GlobalKey<FormState>();
  final _localFolderPathTextFieldController = TextEditingController();
  var _fileTypeForSync = FileTypeForSync.image;
  var _selectedDate = DateTime.now();

  // Here we use a StatefulWidget to hold local fields _nasFolder and _localFolder
  String _nasFolder;

  // String _localFolder;

  String _extension;
  final bool _multiPick = true;
  final FileType _pickingType = FileType.any;
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
        padding: EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              onWillPop: () {
                return Future(() => true);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            ErrorHandler.showErrorDialog(
                                context, NASFileException('Opening a folder is not allowed on the Web!'));
                          }
                        },
                        child: Text('Pick local folder'),
                      ),
                    ],
                  ),
                  TextFormField(
                    key: Key('__NASFolderField'),
                    // initialValue: '/home/mbaros/Pictures/test',
                    // initialValue: 'films',
                    initialValue: 'photos/miron/phonePhotos/2020',
                    //photos/miron/phoneVideos
                    //photos/miron/whatsapp/2020_photos
                    //photos/miron/whatsapp/2020_video
                    autofocus: false,
                    style: Theme.of(context).textTheme.headline5,
                    decoration: InputDecoration(hintText: 'Enter NAS folder'),
                    validator: (val) => val.trim().isEmpty ? 'Cannot be empty' : null,
                    onSaved: (value) => _nasFolder = value,
                  ),
                  InputDatePickerFormField(
                    firstDate: DateTime(2020, 12),
                    lastDate: DateTime.now(),
                    fieldHintText: 'date from',
                    fieldLabelText: 'Date from',
                    initialDate: _selectedDate,
                    onDateSaved: (value) => _selectedDate = value,
                  ),
                  createRadiobuttonFileTypeList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final form = _formKey.currentState;
                        if (form.validate()) {
                          form.save();

                          nasFileSyncState.state.initSync();

                          try {
                            await nasFileSyncState.setState(
                                (s) async => {
                                      s.transferringFileList = await nasFileSyncState.state.getFilesForSynchronization(
                                          _localFolderPathTextFieldController.value.text,
                                          _nasFolder,
                                          _fileTypeForSync,
                                          _selectedDate)
                                    },
                                shouldAwait: true,
                                onError: (context, error) => ErrorHandler.showErrorDialog(context, error, true));
                          } catch (e) {
                            //TODO neobjevi se okno s chybou, zustava data loader
                            Navigator.of(context).pop(); //dismiss data loader
                            ErrorHandler.showErrorDialog(context, e);
                          }
                        }
                      },
                      child: Text('Show files'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: nasFileSyncState.whenRebuilderOr(
                onIdle: () => Text('No transferred file'),
                onWaiting: () => CommonDataLoadingIndicator(),
                onError: (e) {
                  log('ERROR: ${e}');

                  return Text('${e}');
                },
                builder: () {
                  switch (_fileTypeForSync) {
                    case FileTypeForSync.image:
                      return _showImagesToTransfer(context, nasFileSyncState.state.transferringFileList);
                    default:
                      return showFileAsText(context, nasFileSyncState.state.transferringFileList);
                  }
                  ;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO Add your onPressed code here!
        },
        child: const Icon(Icons.send),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _showImagesToTransfer(BuildContext context, List<File> transferringFileList) {
    return Column(
      children: [
        Text('All: ${transferringFileList.length}'),
        Expanded(
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(4),
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            crossAxisCount: 4,
            shrinkWrap: true,
            children: transferringFileList.take(25).map((imgFile) => _createThumbnail(context, imgFile)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _createThumbnail(BuildContext context, File imgFile) {
    return Ink.image(
      key: ValueKey(imgFile.path),
      image: FileImage(imgFile),
      fit: BoxFit.cover,
      width: 120.0,
      height: 120.0,
      onImageError: (exception, stackTrace) => {},
      child: InkWell(
        splashColor: Colors.blueGrey,
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).backgroundColor,
              padding: EdgeInsets.only(left: 10, right: 10),
              action: SnackBarAction(
                label: 'Remove',
                onPressed: () async {
                  await nasFileSyncState.setState((s) => s.transferringFileList.remove(imgFile));
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).backgroundColor,
                      content: const Text('Foto Removed'),
                    ),
                  );
                },
              ),
              content: Text(imgFile.path),
            ),
          );
        },
      ),
    );
  }

  Widget createRadiobuttonFileTypeList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 50.0,
            child: RadioListTile<FileTypeForSync>(
              title: const Text('Images'),
              value: FileTypeForSync.image,
              groupValue: _fileTypeForSync,
              onChanged: (FileTypeForSync value) {
                setState(() {
                  _fileTypeForSync = value;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 50.0,
            child: RadioListTile<FileTypeForSync>(
              title: const Text('Videos'),
              value: FileTypeForSync.video,
              groupValue: _fileTypeForSync,
              onChanged: (FileTypeForSync value) {
                setState(() {
                  _fileTypeForSync = value;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 50.0,
            child: RadioListTile<FileTypeForSync>(
              title: const Text('Docs'),
              value: FileTypeForSync.doc,
              groupValue: _fileTypeForSync,
              onChanged: (FileTypeForSync value) {
                setState(() {
                  _fileTypeForSync = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget showFileAsText(BuildContext context, List<File> transferringFileList) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: transferringFileList.map((file) => _buildListFileTextItem(context, file)).toList(),
    );
  }

  Widget _buildListFileTextItem(BuildContext context, File file) {
    return Padding(
      key: ValueKey(file.path),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: [
          Text(file.path),
          Text('${file.lastModifiedSync()}'),
        ],
      ),
    );
  }
}
