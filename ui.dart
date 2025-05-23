import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const BackupApp());
}

class BackupApp extends StatelessWidget {
  const BackupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BackupHomePage(),
    );
  }
}

class BackupHomePage extends StatefulWidget {
  const BackupHomePage({super.key});

  @override
  State<BackupHomePage> createState() => _BackupHomePageState();
}

class _BackupHomePageState extends State<BackupHomePage> {
  String statusMessage = '';
  bool isBackingUp = false;
  String? targetDirectory;

  Future<void> startBackup() async {
    setState(() {
      isBackingUp = true;
      statusMessage = '';
    });

    String sourcePath = Directory.current.path + '/source';

    final result = await FilePicker.platform.getDirectoryPath();

    if (result == null) {
      setState(() {
        isBackingUp = false;
        statusMessage = 'ups da ist was schief gelaufen';
      });
      return;
    }

    targetDirectory = result;

    try {
      final src = Directory(sourcePath);
      final dest = Directory(targetDirectory!);

      if (!await src.exists()) throw Exception("Source doesn't exist");
      if (!await dest.exists()) await dest.create(recursive: true);

      await for (var entity in src.list(recursive: true)) {
        final relativePath = entity.path.substring(src.path.length);
        final newPath = dest.path + relativePath;

        if (entity is File) {
          await File(entity.path).copy(newPath);
        } else if (entity is Directory) {
          await Directory(newPath).create(recursive: true);
        }
      }

      setState(() {
        isBackingUp = false;
        statusMessage = 'Backup erfolgreich';
      });
    } catch (e) {
      setState(() {
        isBackingUp = false;
        statusMessage = 'ups da ist was schief gelaufen';
      });
    }
  }

  Widget _buildStickFigure({required bool happy}) {
    return Text(
      happy ? '  O\n /|\n / \\' : '  O\n /|\\\n / \\',
      style: TextStyle(fontFamily: 'Courier', fontSize: 20),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStickFigureWithPickaxe() {
    return Text(
      '  O  \\\n /|===>
 / \\\\n
[HACKING STEINE]',
      style: TextStyle(fontFamily: 'Courier', fontSize: 20),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Visuelles Backup Tool')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isBackingUp && statusMessage.isEmpty)
              Column(children: [
                _buildStickFigure(happy: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: startBackup,
                  child: const Text('Jetzt Backup machen'),
                ),
              ]),
            if (isBackingUp) ...[
              _buildStickFigureWithPickaxe(),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
            if (!isBackingUp && statusMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                statusMessage,
                style: TextStyle(
                    color: statusMessage.contains('erfolgreich')
                        ? Colors.green
                        : Colors.red,
                    fontSize: 24),
              ),
              const SizedBox(height: 20),
              _buildStickFigure(happy: statusMessage.contains('erfolgreich')),
            ]
          ],
        ),
      ),
    );
  }
}
// This is a simple Flutter app that allows the user to select a target directory
// for backing up files from a source directory. It uses the file_picker package