import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:iothub/src/domain/value_objects/sync_form_data.dart';

import '../../../service/exceptions/nas_file_sync_exception.dart';
import '../../../service/nas_file_sync_state.dart';
import 'nas_sync_page.dart';
import 'nas_sync_range_date_bar.dart';

class NasSyncFormWidget extends StatefulWidget {
  final SyncFormData initialValue;

  final bool showRangeDateBar;

  const NasSyncFormWidget(
      {Key? key, required this.initialValue, this.showRangeDateBar = true})
      : super(key: key);

  @override
  NasSyncFormWidgetState createState() => NasSyncFormWidgetState();
}

class NasSyncFormWidgetState extends State<NasSyncFormWidget> {
  // static final _data = SyncFormData('', '', '', DateTime.now(), DateTime.now(), FileTypeForSync.image);
  late final SyncFormData _value = widget.initialValue;

  SyncFormData get value => _value;

  final _formKey = GlobalKey<FormState>();

  final _localFolderPathTextFieldController = TextEditingController();

  // final _syncNameTextFieldController = TextEditingController();
  // var _fileTypeForSync = FileTypeForSync.image;

  // Here we use a StatefulWidget to hold local fields _nasFolder and _localFolder
  // String? _nasFolder;

  // String? _extension;
  // final _multiPick = true;
  // final _pickingType = FileType.any;
  // List<PlatformFile>? _paths;

  late final Future<List<String>> _nasFoldersFuture = NASSyncMainPage
      .nasFileSyncState.state
      .listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER);

  @override
  void initState() {
    super.initState();
    _localFolderPathTextFieldController.text = _value.localFolder;
  }

  @override
  void dispose() {
    _localFolderPathTextFieldController.dispose();
    // _syncNameTextFieldController.dispose();
    _clearCachedFiles();
    super.dispose();
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _localFolderPathTextFieldController.text = value!);
    });
  }

  // void _openFileExplorer() async {
  //   try {
  //     _paths = (await FilePicker.platform.pickFiles(
  //       type: _pickingType,
  //       allowMultiple: _multiPick,
  //       allowedExtensions: (_extension?.isNotEmpty ?? false)
  //           ? _extension?.replaceAll(' ', '').split(',')
  //           : null,
  //     ))
  //         ?.files;
  //   } on PlatformException catch (e) {
  //     print('Unsupported operation' + e.toString());
  //   } catch (ex) {
  //     print(ex);
  //   }
  //   if (!mounted) return;
  //   setState(() {
  //     // _loadingPath = false;
  //     _localFolderPathTextFieldController.text =
  //         _paths != null ? _paths!.map((e) => e.name).toString() : '...';
  //   });
  // }

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
            key: const Key('__SyncName'),
            initialValue: _value.name,
            //nesmi byt nastaven kdyz se pouzije controller
            style: Theme.of(context).textTheme.headline5,
            decoration: const InputDecoration(
              hintText: 'Enter sync name',
            ),
            validator: (val) => val!.trim().isEmpty ? 'Cannot be empty' : null,
            // controller: _syncNameTextFieldController,
            onSaved: (value) => _value.name = value!,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('__SyncLocalFolderField'),
                  // initialValue: _value.localFolder,
                  //nesmi byt nastaven kdyz se pouzije controller
                  style: Theme.of(context).textTheme.headline5,
                  decoration: const InputDecoration(
                    hintText: 'Enter local path',
                  ),
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Cannot be empty' : null,
                  controller: _localFolderPathTextFieldController,
                  onSaved: (value) => _value.localFolder = value!,
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
          //remote folder selector
          createDropDownButtonExtLoaded(),
          if (widget.showRangeDateBar)
            NasSyncRangeDateBar(
              dateFrom: _value.from,
              dateTo: _value.to,
              onDateFromSaved: (value) => _value.from = value,
              onDateToSaved: (value) => _value.to = value,
            ),
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
          // ErrorHandler.showSnackBar(snapshot.error);

          return TextFormField(
            key: const Key('__SyncNasFolderTextField'),
            initialValue: _value.remoteFolder,
            //nesmi byt nastaven kdyz se pouzije controller
            style: Theme.of(context).textTheme.headline5,
            decoration: const InputDecoration(
              hintText: 'Enter remote folder path',
            ),
            validator: (val) => val!.trim().isEmpty ? 'Cannot be empty' : null,
            // controller: _syncNameTextFieldController,
            onSaved: (value) => _value.remoteFolder = value!,
          );
        } else {
          return const Text('Loading server folders ...');
        }
        return DropdownButtonFormField<String>(
          key: const Key('__NASFolderField'),
          // value: _value.remoteFolder, pokud value neni null tak to pada
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
              _value.remoteFolder = newValue!;
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
              groupValue: _value.fileType,
              onChanged: (FileTypeForSync? value) {
                setState(() {
                  _value.fileType = value!;
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
              groupValue: _value.fileType,
              onChanged: (FileTypeForSync? value) {
                setState(() {
                  _value.fileType = value!;
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
              groupValue: _value.fileType,
              onChanged: (FileTypeForSync? value) {
                setState(() {
                  _value.fileType = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  bool validate() {
    FormState? formState = _formKey.currentState;
    // NasSyncRangeDateBarState? dateBarState =
    //     _rangeDateBarGlobalKey.currentState;
    // return formState!.validate() && dateBarState!.validate();
    return formState?.validate() ?? false;
  }

  void save() {
    FormState? formState = _formKey.currentState;
    // NasSyncRangeDateBarState? dateBarState =
    //     _rangeDateBarGlobalKey.currentState;
    formState?.save();
    // dateBarState!.save();

    // _value.from = dateBarState!.dateFrom;
    // _value.to = dateBarState.dateTo;
  }
}
