import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

import '../models/pin.dart';
import 'firestore_service.dart';

class DownloadService {
  final FirestoreService _firestore =
      FirestoreService();

  Future<void> downloadPin(Pin pin) async {
    final url = pin.originalUrl.isNotEmpty
        ? pin.originalUrl
        : pin.imageUrl;

    if (url.isEmpty) {
      throw Exception(
        'Image URL is empty.',
      );
    }

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to download image. '
        'HTTP ${response.statusCode}',
      );
    }

    final Uint8List bytes =
        response.bodyBytes;

    // Save image to phone gallery
    await Gal.putImageBytes(
      bytes,
      album: 'Pinspire',
    );

    // Only record it after the gallery save succeeds.
    await _firestore.recordDownload(pin);
  }
}