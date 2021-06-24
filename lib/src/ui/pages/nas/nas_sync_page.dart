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
import 'package:path/path.dart' as p;
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
  static const _BASE_SAMBA_FOLDER = 'photos/miron';
  final _formKey = GlobalKey<FormState>();
  final _localFolderPathTextFieldController = TextEditingController();
  var _fileTypeForSync = FileTypeForSync.image;
  final nowDate = DateTime.now();

  // var _selectedDateFrom = DateTime.now().dateNow(); //only date from midnight
  var _selectedDateFrom = DateTime.now(); //now -> date input field format datetime to only date
  var _selectedDateTo = DateTime.now(); //date up to now including time

  // Here we use a StatefulWidget to hold local fields _nasFolder and _localFolder
  String _nasFolder;

  // String _localFolder;

  String _extension;
  final bool _multiPick = true;
  final FileType _pickingType = FileType.any;
  List<PlatformFile> _paths;

  bool _showingFiles = false;

  String get _joinedSambaFolder => p.join(_BASE_SAMBA_FOLDER, _nasFolder).toString();

  @override
  void dispose() {
    _localFolderPathTextFieldController.dispose();
    _clearCachedFiles();
    nasFileSyncState.state.clearFiles();
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
      body: _createBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadingFileButtonOnPressed,
        child: const Icon(Icons.send),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _createBody() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          _getForm(),
          Divider(),
          _createTransferingStatusBar(),
          Divider(),
          On.all(
              onIdle: () => Text('No transferred file'),
              onWaiting: onWaiting, onError: onError, onData: onData)
          nasFileSyncState.whenRebuilderOr(
            watch: () => nasFileSyncState.state.transferringFileList,
            onIdle: () => Text('No transferred file'),
            onError: (e) {
              log('ERROR: ${e}');

              return Text('${e}');
            },
            builder: () => _showFilesToTransfer(context, nasFileSyncState.state.transferringFileList),
          ),
        ],
      ),
    );
  }

  Widget _getForm() {
    return Form(
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
          createDropDownButtonExtLoaded(),
          createInputDateBar(),
          createRadiobuttonFileTypeList(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (nasFileSyncState.state.uploading) {
                      return;
                    }
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      form.save();

                      _showingFiles = true;

                      await nasFileSyncState.setState(
                        (s) async {
                          if (nasFileSyncState.state.allTransferringFilesCount == 0) {
                            // try {
                            await s.getFilesForSynchronization(_localFolderPathTextFieldController.value.text,
                                _joinedSambaFolder, _fileTypeForSync, _selectedDateFrom, _selectedDateTo);
                          }

                          s.showFirstFiles();
                          // } catch (e) {
                          //   //TODO neobjevi se okno s chybou, zustava data loader
                          //   Navigator.of(context).pop(); //dismiss data loader
                          //   ErrorHandler.showErrorDialog(context, e);
                          // }
                        },
                      );
                    }
                  },
                  child: Text('Show files'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (nasFileSyncState.state.uploading) {
                      return;
                    }

                    await nasFileSyncState.setState(
                      (s) async {
                        _showingFiles = false;
                        s.clearShowingFiles();
                      },
                    );
                  },
                  child: Text('Clear files'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _createTransferingStatusBar() {
    return nasFileSyncState.whenRebuilderOr(
      watch: () => nasFileSyncState.state.allTransferringFilesCount,
      builder: () => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Transferred / All - '),
              Text('${nasFileSyncState.state.transferredFilesCount}'),
              Text('/'),
              Text('${nasFileSyncState.state.allTransferringFilesCount}'),
            ],
          ),
          _uploadingFileStatusBar(),
        ],
      ),
    );
  }

  Widget _uploadingFileStatusBar() {
    return nasFileSyncState.whenRebuilderOr(
        watch: () => nasFileSyncState.state.uploadedFileStatus,
        builder: () {
          if (nasFileSyncState.state.uploading &&
              nasFileSyncState.state.uploadedFileStatus != null &&
              !nasFileSyncState.state.uploadedFileStatus.uploaded) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Uploading...  ${nasFileSyncState.state.uploadedFileStatus.uploadingFilePath}',
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nasFileSyncState.state.uploading) {
                          print('Cancel upload');
                          nasFileSyncState.state.cancelUploading();
                        } else {
                          print('No file is uploading! Canceling is dismissed');
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
              ],
            );
          }
          return Text('');
        });
  }

  Widget _showFilesToTransfer(BuildContext context, List<File> transferringFileList) {
    if (!_showingFiles) {
      return const Text('Uploading files is running in background.....');
    }

    switch (_fileTypeForSync) {
      case FileTypeForSync.image:
        return _showImagesToTransfer(context, transferringFileList);
      case FileTypeForSync.video:
      case FileTypeForSync.doc:
        return showFileAsText(context, transferringFileList);
      default:
        return const Text('Unknown file sync type!!!!');
    }
  }

  Widget _showImagesToTransfer(BuildContext context, List<File> transferringFileList) {
    // return Expanded(
    //   child: GridView.count(
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(4),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      crossAxisCount: 4,
      shrinkWrap: true,
      children: transferringFileList.map((imgFile) => _createThumbnail(context, imgFile)).toList(),
      // ),
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
                  await nasFileSyncState.setState((s) => s.removeFile(imgFile.path));
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).backgroundColor,
                      content: const Text('File removed'),
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
              dense: true,
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
              dense: true,
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
              dense: true,
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

  Future<void> _uploadingFileButtonOnPressed() async {
    if (nasFileSyncState.state.uploading) {
      return null; //disable button
    }
    print('uploading starting');

    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      if (nasFileSyncState.state.allTransferringFilesCount == 0) {
        try {
          await nasFileSyncState.state.getFilesForSynchronization(_localFolderPathTextFieldController.value.text,
              _joinedSambaFolder, _fileTypeForSync, _selectedDateFrom, _selectedDateTo);
        } catch (e) {
          nasFileSyncState.state.uploading = false;
          //TODO neobjevi se okno s chybou, zustava data loader
          // Navigator.of(context).pop(); //dismiss data loader
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }

      if (nasFileSyncState.state.allTransferringFilesCount == 0) {
        //there is no files to upload
        print('there is no files to upload');
        nasFileSyncState.state.uploading = false;
        return;
      }
      // try {
      await nasFileSyncState.setState(
        (s) {
          // nasFileSyncState.state.showNextFiles(nasFileSyncState.state.allTransferringFilesCount);

          try {
            return s.syncFolderWithNAS(s.filesForUploading, _joinedSambaFolder, _fileTypeForSync);
          } catch (e) {
            nasFileSyncState.state.uploading = false;
            //TODO neobjevi se okno s chybou, zustava data loader
            // Navigator.of(context).pop(); //dismiss data loader
            ErrorHandler.showErrorSnackBar(context, e);
          }
        },
        onError: (context, error) {
          nasFileSyncState.state.uploading = false;
          ErrorHandler.showErrorSnackBar(context, error);
        },
      );
      // } catch (e) {
      //   nasFileSyncState.state.uploading = false;
      //   //TODO neobjevi se okno s chybou, zustava data loader
      //   // Navigator.of(context).pop(); //dismiss data loader
      //   ErrorHandler.showErrorSnackBar(context, e);
      // }
    }
  }

  Widget createInputDateBar() {
    return Row(
      children: [
        Expanded(
          child: InputDatePickerFormField(
            firstDate: DateTime(2020, 01),
            lastDate: DateTime.now(),
            fieldHintText: 'date from',
            fieldLabelText: 'Date from',
            initialDate: _selectedDateFrom,
            onDateSaved: (value) => _selectedDateFrom = value,
          ),
        ),
        Expanded(
          child: InputDatePickerFormField(
            firstDate: DateTime(2020, 01),
            lastDate: DateTime.now(),
            fieldHintText: 'date to',
            fieldLabelText: 'Date to',
            initialDate: _selectedDateTo,
            onDateSaved: (value) => _selectedDateTo = value,
          ),
        ),
      ],
    );
  }

  Widget createDropDownButtonExtLoaded() {
    return FutureBuilder(
      future: _listSambaFolders(),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        var comboItems = <DropdownMenuItem<String>>[];
        if (snapshot.hasData) {
          comboItems = snapshot.data.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList();
        } else if (snapshot.hasError) {
          // ErrorHandler.showErrorDialog(context, snapshot.error);
          return Text('${snapshot.error}');
        } else {
          return Text('Loading server folders ...');
          // return CommonDataLoadingIndicator();
        }
        return DropdownButtonFormField<String>(
          key: Key('__NASFolderField'),
          value: _nasFolder,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          isExpanded: true,
          disabledHint: Text('Not supported on Web'),
          autofocus: false,
          hint: Text('Click for a folder list'),
          style: Theme.of(context).textTheme.headline5,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0.0),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple),
            ),
          ),
          onChanged: (String newValue) {
            setState(() {
              _nasFolder = newValue;
            });
          },
          items: comboItems,
          validator: (val) => (val == null || val.trim().isEmpty) ? 'Cannot be empty' : null,
        );
      },
    );
  }

  Future<List<String>> _listSambaFolders() async {
    if (kIsWeb) {
      throw NASFileException('Not implemented on Web'); //not implemented on Web
    }

    return await nasFileSyncState.state.listSambaFolders(_BASE_SAMBA_FOLDER);
  }
}
