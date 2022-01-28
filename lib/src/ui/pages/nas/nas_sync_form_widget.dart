import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../service/exceptions/nas_file_sync_exception.dart';
import '../../../service/nas_file_sync_state.dart';
import '../../exceptions/error_handler.dart';
import 'nas_sync_page.dart';
import 'nas_sync_range_date_bar.dart';

class NasSyncFormWidget extends StatefulWidget {
  const NasSyncFormWidget({Key? key}) : super(key: key);


  @override
  _NasSyncFormWidgetState createState() => _NasSyncFormWidgetState();


}

class _NasSyncFormWidgetState extends State<NasSyncFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _localFolderPathTextFieldController = TextEditingController();
  final _syncNameTextFieldController = TextEditingController();
  var _fileTypeForSync = FileTypeForSync.image;

  // Here we use a StatefulWidget to hold local fields _nasFolder and _localFolder
  String? _nasFolder;

  String? _extension;
  final _multiPick = true;
  final _pickingType = FileType.any;
  List<PlatformFile>? _paths;

  late final Future<List<String>> _nasFoldersFuture = _listSambaFolders();

  Future<List<String>> _listSambaFolders() async {
    return await NASSyncMainPage.nasFileSyncState.state
        .listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER);
  }

  final _dateBar = NasSyncRangeDateBar(
      key: UniqueKey(), dateFrom: DateTime.now(), dateTo: DateTime.now());

  @override
  void dispose() {
    _localFolderPathTextFieldController.dispose();
    _syncNameTextFieldController.dispose();
    _clearCachedFiles();
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
          if (kDebugMode) {
            print('Temporary files removed with success.');
          }
        } else {
          if (kDebugMode) {
            print('Temporary files was not removed.');
          }
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print('Failed to clean temporary files ${e.toString()}');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onWillPop: () {
        return Future(() => true);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: const Key('__SyncNameField'),
            // initialValue: '', nesmi byt nastaven kdyz se pouzije controller
            style: Theme.of(context).textTheme.headline5,
            decoration: const InputDecoration(
              hintText: 'Enter name of synchronization',
            ),
            validator: (val) => val!.trim().isEmpty ? 'Cannot be empty' : null,
            controller: _syncNameTextFieldController,
            // onSaved: (value) => _localFolder = value,
          ),
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
          _dateBar,
          createRadiobuttonFileTypeList(),
        ],
      ),
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
}
