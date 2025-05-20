import 'dart:io';

class BackupSystem {
  final String sourceDir;
  final String backupDir;

  BackupSystem({required this.sourceDir, required this.backupDir});

  Future<void> runBackup() async {
    final src = Directory(sourceDir);
    final dest = Directory(backupDir);

    if (!await src.exists()) {
      print('Source directory does not exist.');
      return;
    }
    if (!await dest.exists()) {
      await dest.create(recursive: true);
    }

    await _copyDirectory(src, dest);
    print('Backup completed.');
  }

  Future<void> _copyDirectory(Directory src, Directory dest) async {
    await for (var entity in src.list(recursive: true)) {
      final relativePath = entity.path.substring(src.path.length);
      final newPath = dest.path + relativePath;

      if (entity is File) {
        await File(entity.path).copy(newPath);
      } else if (entity is Directory) {
        await Directory(newPath).create(recursive: true);
      }
    }
  }
}

void main() async {
  // Example usage:
  final backupSystem = BackupSystem(
    sourceDir: 'C:/Users/SPQR/Documents/source_folder',
    backupDir: 'C:/Users/SPQR/Documents/backup_folder',
  );

  await backupSystem.runBackup();
}