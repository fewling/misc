import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misc/providers.dart';
import 'package:permission_handler/permission_handler.dart';

import 'color_picker_sheet.dart';

void main(List<String> args) {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brightnessProvider);
    final colorSeed = ref.watch(colorSchemeProvider);

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorSchemeSeed: colorSeed,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final brightnessNotifier = ref.watch(brightnessProvider.notifier);
    final colorSeedNotifier = ref.watch(colorSchemeProvider.notifier);

    final androidID = ref.watch(androidIDProvider);
    final licenseKey = ref.watch(licenseKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Testing App')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.dark_mode_outlined, color: colorScheme.primary),
            title: const Text('Dark Mode'),
            onTap: () => brightnessNotifier.state =
                brightness == Brightness.light ? Brightness.dark : Brightness.light,
            trailing: Switch(
              value: brightness == Brightness.dark,
              onChanged: (_) => brightnessNotifier.state =
                  brightness == Brightness.light ? Brightness.dark : Brightness.light,
            ),
          ),
          ListTile(
            leading: Icon(Icons.color_lens_outlined, color: colorScheme.primary),
            title: const Text('Color Scheme'),
            trailing: SizedBox(
              width: 20,
              height: 20,
              child: ColoredBox(color: colorScheme.primary),
            ),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => DraggableScrollableSheet(
                expand: false,
                builder: (context, scrollController) => ColorPickerSheet(
                  scrollController,
                  onColorSelected: (colorCode) => colorSeedNotifier.state = Color(colorCode),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          androidID.when(
            data: (data) => ListTile(
              title: const Text('Android ID'),
              subtitle: Text(data ?? 'null'),
            ),
            error: (error, stackTrace) => Text('$error\n$stackTrace'),
            loading: () => const CircularProgressIndicator(),
          ),
          licenseKey.when(
            data: (data) => ListTile(
              title: const Text('Android ID'),
              subtitle: Text(data.toString()),
            ),
            error: (error, stackTrace) => Text('$error\n$stackTrace'),
            loading: () => const CircularProgressIndicator(),
          ),
          ElevatedButton(
            onPressed: () async {
              // final downloadsPath = await AndroidPathProvider.downloadsPath;
              // final docPath = await AndroidPathProvider.documentsPath;

              // logger.d(downloadsPath);
              // logger.d(docPath);

              bool isGranted = await Permission.storage.request().isGranted;
              isGranted = await Permission.manageExternalStorage.request().isGranted;
              if (!isGranted) return;

              final myDir = Directory('/storage/emulated/0/test folder');
              final f = File('${myDir.path}/key.txt');

              final exists = await f.exists();
              logger.d('exists: $exists');
              if (!exists) return;

              f.readAsString().then((value) => logger.d('file content: $value'));
            },
            child: const Text('Find File'),
          ),
        ],
      ),
    );
  }
}
