import 'package:iothub/src/domain/entities/nas_file_item.dart';

abstract class NASFileSyncService {
  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath);

  Future<void> syncFolderWithNAS(String localFolderPath, String nasFolderPath);

}