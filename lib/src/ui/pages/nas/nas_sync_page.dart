import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _localFolderPathTextFieldController.dispose();
    super.dispose();
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _localFolderPathTextFieldController.text = value);
    });
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
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      //TODO open file manager to select a folder
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
                  )
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
