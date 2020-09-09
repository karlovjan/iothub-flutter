import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';

class HTTPNASFileSyncService implements NASFileSyncService {
  @override
  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath) {
    // TODO: implement retrieveDirectoryItems
    throw UnimplementedError();
  }

  @override
  Future<void> syncFolderWithNAS(String localFolderPath, String nasFolderPath) {
    // TODO: implement syncFolderWithNAS
    throw UnimplementedError();
  }



}