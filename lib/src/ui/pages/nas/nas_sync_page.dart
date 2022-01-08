import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iothub/src/data_source/http_dio_nas_file_sync_service.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/local_file_system_util.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:path/path.dart' as p;
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

  @override
  _SyncPathEditFormState createState() => _SyncPathEditFormState();
}

class _SyncPathEditFormState extends State<NASSyncMainPage> {
  final _formKey = GlobalKey<FormState>();
  final _localFolderPathTextFieldController = TextEditingController();
  var _fileTypeForSync = FileTypeForSync.image;

  // var _selectedDateFrom = DateTime.now().dateNow(); //only date from midnight
  var _selectedDateFrom =
      DateTime.now(); //now -> date input field format datetime to only date
  var _selectedDateTo = DateTime.now(); //date up to now including time

  // Here we use a StatefulWidget to hold local fields _nasFolder and _localFolder
  String? _nasFolder;

  String? _extension;
  final _multiPick = true;
  final _pickingType = FileType.any;
  List<PlatformFile>? _paths;

  String get _joinedSambaFolder =>
      p.join(NASFileSyncState.BASE_SAMBA_FOLDER, _nasFolder).toString();

  late final Future<List<String>> _nasFoldersFuture = _listSambaFolders();

  @override
  void dispose() {
    _localFolderPathTextFieldController.dispose();
    _clearCachedFiles();
    NASSyncMainPage.nasFileSyncState.state.clearFiles();
    super.dispose();
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _localFolderPathTextFieldController.text = value!);
    });
  }

  void _openFileExplorer() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
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
      _localFolderPathTextFieldController.text =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
    });
  }

  void _clearCachedFiles() {
    if (kIsWeb) {
      return; //not implemented on Web
    }

    FilePicker.platform.clearTemporaryFiles().then(
      (result) {
        if (result!) {
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
        title: const Text(
          'Synchronize to NAS',
        ),
      ),
      body: _createBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _uploadingFileButtonOnPressed();
        },
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
          const Divider(),
          _createTransferingStatusBar(),
          const Divider(),
          OnBuilder<NASFileSyncState>.orElse(
            listenTo: NASSyncMainPage.nasFileSyncState,
            watch: () =>
                NASSyncMainPage.nasFileSyncState.state.transferringFileList,
            orElse: (data) =>
                _showFilesToTransfer(context, data.transferringFileList),
            onWaiting: () => const CommonDataLoadingIndicator(),
            onIdle: () => const Center(
              child: Text('Waiting for files to synchronize...'),
            ),
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
                  key: const Key('__LocalFolderField'),
                  // initialValue: '', nesmi byt nastaven kdyz se pouzije controller
                  style: Theme.of(context).textTheme.headline5,
                  decoration: const InputDecoration(
                    hintText: 'Enter local folder',
                  ),
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Cannot be empty' : null,
                  controller: _localFolderPathTextFieldController,
                  // onSaved: (value) => _localFolder = value,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!kIsWeb) {
                    _selectFolder();
                  } else {
                    //TODO remake on a new widget LocalFolderPathFromInput that solving if (!kIsWeb)
                    throw NASFileException(
                        'Opening a folder is not allowed on the Web!');
                  }
                },
                child: const Text('Pick local folder'),
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
                  child: const Text('Show files'),
                  onPressed: () {
                    if (NASSyncMainPage.nasFileSyncState.state.uploading) {
                      return;
                    }
                    final form = _formKey.currentState!;
                    if (form.validate()) {
                      form.save();

                      if (NASSyncMainPage.nasFileSyncState.state
                              .allTransferringFilesCount !=
                          0) {

                        if(NASSyncMainPage.nasFileSyncState.state.transferringFileList.isEmpty) {
                          NASSyncMainPage.nasFileSyncState.setState(
                                (s) => s.showFirstFiles(),
                          );
                        }
                        return;
                      }

                      NASSyncMainPage.nasFileSyncState.setState(
                        (s) => s.getFilesForSynchronization(
                            _localFolderPathTextFieldController.value.text,
                            _joinedSambaFolder,
                            _fileTypeForSync,
                            _selectedDateFrom,
                            _selectedDateTo),
                        sideEffects: SideEffects.onOrElse(
                          orElse: (data) => data.showFirstFiles(),
                        ),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (NASSyncMainPage.nasFileSyncState.state.uploading) {
                      return;
                    }

                    NASSyncMainPage.nasFileSyncState.setState(
                      (s) => s.clearShowingFiles(),
                    );
                  },
                  child: const Text('Clear files'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _createTransferingStatusBar() {
    return OnBuilder<NASFileSyncState>.data(
      listenTo: NASSyncMainPage.nasFileSyncState,
      watch: () => NASSyncMainPage.nasFileSyncState.state.transferredFilesCount,
      builder: (data) => data.uploading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Transferred / All - '),
                    Text('${data.transferredFilesCount}'),
                    const Text('/'),
                    Text('${data.allTransferringFilesCount}'),
                  ],
                ),
                _uploadingFileStatusBar(),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _uploadingFileStatusBar() {
    return OnBuilder<NASFileSyncState>.data(
      listenTo: NASSyncMainPage.nasFileSyncState,
      watch: () => NASSyncMainPage.nasFileSyncState.state.uploadingFileStatus,
      builder: (data) {
        if (data.uploading && !data.uploadingFileStatus.uploaded) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Uploading...  ${data.uploadingFileStatus.uploadingFilePath}',
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (data.uploading) {
                        data.cancelUploading();
                      }
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _showFilesToTransfer(
      BuildContext context, List<File> transferringFileList) {
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

  Widget _showImagesToTransfer(
      BuildContext context, List<File> transferringFileList) {
    // return Expanded(
    //   child: GridView.count(
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(4),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      crossAxisCount: 4,
      shrinkWrap: true,
      children: transferringFileList
          .map((imgFile) => _createThumbnail(context, imgFile))
          .toList(),
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
      onImageError: (exception, stackTrace) => Text(imgFile.path),
      child: InkWell(
        splashColor: Colors.blueGrey,
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).backgroundColor,
              padding: const EdgeInsets.only(left: 10, right: 10),
              action: SnackBarAction(
                label: 'Remove',
                onPressed: () {
                  NASSyncMainPage.nasFileSyncState.setState(
                    (s) => s.removeFile(imgFile.path),
                    sideEffects: SideEffects.onData((data) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).backgroundColor,
                          content: const Text('File removed'),
                        ),
                      );
                    }),
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
              onChanged: (FileTypeForSync? value) {
                setState(() {
                  _fileTypeForSync = value!;
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
              onChanged: (FileTypeForSync? value) {
                setState(() {
                  _fileTypeForSync = value!;
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
              onChanged: (FileTypeForSync? value) {
                setState(() {
                  _fileTypeForSync = value!;
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
      children: transferringFileList
          .map((file) => _buildListFileTextItem(context, file))
          .toList(),
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
    if (NASSyncMainPage.nasFileSyncState.state.uploading) {
      return; //disable button
    }
    if (kDebugMode) {
      print('uploading starting');
    }

    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();

      // try {
      await NASSyncMainPage.nasFileSyncState.setState(
        (s) async {
          if (s.allTransferringFilesCount == 0) {
            await s.getFilesForSynchronization(
                _localFolderPathTextFieldController.value.text,
                _joinedSambaFolder,
                _fileTypeForSync,
                _selectedDateFrom,
                _selectedDateTo);
          }

          return s.syncFolderWithNAS(
              s.filesForUploading, _joinedSambaFolder, _fileTypeForSync);
        },
        sideEffects: SideEffects.onError((err, refresh) {
          ErrorHandler.showErrorDialog(err);
        }),
        shouldOverrideDefaultSideEffects: (snap) => true,
      );
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
    //TODO remake on a new widget LocalFolderPathFromInput that solving if (!kIsWeb) and if is web return onlu textforminput
    if (kIsWeb) {
      throw NASFileException('Not implemented on Web'); //not implemented on Web
    }
    return FutureBuilder(
      future: _nasFoldersFuture,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        var comboItems = <DropdownMenuItem<String>>[];
        if (snapshot.hasData) {
          comboItems =
              snapshot.data!.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList();
        } else if (snapshot.hasError) {
          return ErrorHandler.getErrorDialog(snapshot.error);
        } else {
          return const Text('Loading server folders ...');
        }
        return DropdownButtonFormField<String>(
          key: const Key('__NASFolderField'),
          value: _nasFolder,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          isExpanded: true,
          disabledHint: const Text('Not supported on Web'),
          autofocus: false,
          hint: const Text('Select NAS folder'),
          style: Theme.of(context).textTheme.headline5,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(0.0),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              _nasFolder = newValue;
            });
          },
          items: comboItems,
          validator: (val) =>
              (val == null || val.trim().isEmpty) ? 'Cannot be empty' : null,
        );
      },
    );
  }

  Future<List<String>> _listSambaFolders() async {
    return await NASSyncMainPage.nasFileSyncState.state
        .listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER);
  }
}
