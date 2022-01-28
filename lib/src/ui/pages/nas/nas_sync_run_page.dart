import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:iothub/src/domain/value_objects/sync_form_data.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:path/path.dart' as p;
import 'package:states_rebuilder/states_rebuilder.dart';

import 'nas_sync_page.dart';
import 'nas_sync_range_date_bar.dart';

//  https://github.com/GIfatahTH/states_rebuilder/tree/master/examples/ex_009_1_3_ca_todo_mvc_with_state_persistence
//https://flutter.dev/docs/cookbook/forms
//https://github.com/miguelpruivo/flutter_file_picker/blob/master/example/lib/src/file_picker_demo.dart

///Class showing a page for setting a NAS folder
class NASSyncRunPage extends StatelessWidget {
  final SyncFormData syncData;

  final NasSyncRangeDateBar _dateBar;

  NASSyncRunPage({Key? key, required this.syncData})
      : _dateBar = NasSyncRangeDateBar(
            key: UniqueKey(), dateFrom: syncData.to, dateTo: DateTime.now()),
        super(key: key);

  String get _joinedSambaFolder => p
      .join(NASFileSyncState.BASE_SAMBA_FOLDER, syncData.remoteFolder)
      .toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Run synchronization',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            // await RM.navigate.toNamed(StaticPages.iotHUBApp.routeName);
            RM.navigate.back();
          },
        ),
      ),
      body: _createBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _uploadingFileButtonOnPressed();
        },
        child: const Icon(Icons.send),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _createBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          _getFileSyncDetail(),
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

  Widget _getFileSyncDetail() {
    return Column(
      children: <Widget>[
        Text('From: ' + syncData.localFolder),
        Text('To: ' + syncData.remoteFolder),
        Text('Type: ' + syncData.fileType.name),
        _dateBar,
      ],
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
    switch (syncData.fileType) {
      case FileTypeForSync.image:
        return _showImagesToTransfer(context, transferringFileList);
      case FileTypeForSync.video:
      case FileTypeForSync.doc:
        return showFileAsText(transferringFileList);
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

  Widget showFileAsText(List<File> transferringFileList) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20.0),
      children: transferringFileList
          .map((file) => _buildListFileTextItem(file))
          .toList(),
    );
  }

  Widget _buildListFileTextItem(File file) {
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

    // try {
    await NASSyncMainPage.nasFileSyncState.setState(
      (s) async {
        if (s.allTransferringFilesCount == 0) {
          await s.getFilesForSynchronization(
              syncData.localFolder,
              _joinedSambaFolder,
              syncData.fileType,
              _dateBar.dateFrom,
              _dateBar.dateTo);
        }

        return s.syncFolderWithNAS(
            s.filesForUploading, _joinedSambaFolder, syncData.fileType);
      },
      sideEffects: SideEffects.onError((err, refresh) {
        ErrorHandler.showErrorDialog(err);
      }),
      shouldOverrideDefaultSideEffects: (snap) => true,
    );
  }
}
