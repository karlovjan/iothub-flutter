import 'package:iothub/src/domain/value_objects/sync_folder_result.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';

class NASFileSyncState {
  final NASFileSyncService _fileSyncService;

  NASFileSyncState(this._fileSyncService);

  Future<SyncFolderResult> syncFolderWithNAS(
      String localFolderPath, String nasFolderPath) {}
}
