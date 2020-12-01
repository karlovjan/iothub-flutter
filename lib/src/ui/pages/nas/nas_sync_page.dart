import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//  https://github.com/GIfatahTH/states_rebuilder/tree/master/examples/ex_009_1_3_ca_todo_mvc_with_state_persistence
//https://flutter.dev/docs/cookbook/forms
//https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/lib/src/file_picker_demo.dart

///Class showing a page for setting a NAS folder
class NASSyncMainPage extends StatefulWidget {
  const NASSyncMainPage({Key key}) : super(key: key);

  @override
  _SyncPathEditFormState createState() => _SyncPathEditFormState();
}

class _SyncPathEditFormState extends State<NASSyncMainPage> {
  final _formKey = GlobalKey<FormState>();
  final _localFolderPathTextFieldController = TextEditingController();

  // Here we use a StatefulWidget to hold local fields _nasFolder and _localFolder
  String _nasFolder;

  // String _localFolder;

  String _extension;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;

  @override
  void dispose() {
    _localFolderPathTextFieldController.dispose();
    _clearCachedFiles();
    super.dispose();
  }

  void _selectFolder() {
    if (kIsWeb) {
      _openFileExplorer();
    } else {
      FilePicker.platform.getDirectoryPath().then((value) {
        setState(() => _localFolderPathTextFieldController.text = value);
      });
    }
  }

  void _openFileExplorer() async {
    List<PlatformFile> paths;
    try {
      paths = (await FilePicker.platform.pickFiles(
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
      _localFolderPathTextFieldController.text = paths != null ? paths.map((e) => e.name).toString() : '...';
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
                initialValue: 'public/photos/miron/phonePhotos',
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
                      // initialValue: '',
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
                    onPressed: () => _selectFolder(),
                    child: Text('Pick local folder'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      form.save();
                      //TODO call synch service
                      //use local variables _nasFolder a _localFolder
                    }
                  },
                  child: Text('Synchronize'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
