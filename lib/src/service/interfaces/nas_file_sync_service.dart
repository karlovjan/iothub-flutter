import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/sync_folder_result.dart';

abstract class NASFileSyncService {
  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath);

  Future<SyncFolderResult> syncFolderWithNAS(String localFolderPath, String nasFolderPath);
}
