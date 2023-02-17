import 'dart:convert';

import 'package:android_id/android_id.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final logger = Logger(printer: PrettyPrinter(lineLength: 50));

final brightnessProvider = StateProvider((_) => Brightness.dark);
final colorSchemeProvider = StateProvider((_) => Color(Colors.greenAccent.value));

final fixedKeyProvider = Provider((_) => 'A_FIXED_STRING');
final androidIDProvider = FutureProvider((_) async {
  // ! https://pub.dev/packages/android_id#important
  const androidIdPlugin = AndroidId();
  final androidId = await androidIdPlugin.getId();
  return androidId;
});
final licenseKeyProvider = FutureProvider((ref) async {
  final fixedKey = ref.watch(fixedKeyProvider);
  final id = await ref.watch(androidIDProvider.future);
  if (id == null) return null;

  final bytes = utf8.encode(fixedKey + id);
  final digest = sha512.convert(bytes);

  logger.d("Digest as hex string: $digest");

  return digest;
});
