
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pin.dart';

class PexelsService {
  static const String endpoint =
      'https://pinspire-pexels-api.ekkaa3118.workers.dev/search';

  Future<List<Pin>> search(
    String query, {
    int page = 1,
    int perPage = 30,
  }) async {
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'query': query,
        'page': '$page',
        'per_page': '$perPage',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Image service error (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid image service response.');
    }

    final photos = decoded['photos'];

    if (photos is! List) {
      throw Exception('No photos returned.');
    }

    return photos
        .whereType<Map<String, dynamic>>()
        .map(
          (photo) => Pin(
            id: '${photo['id'] ?? ''}',
            imageUrl:
                photo['imageUrl'] as String? ?? '',
            originalUrl:
                photo['originalUrl'] as String? ??
                    photo['imageUrl'] as String? ??
                    '',
            photographer:
                photo['photographer'] as String? ??
                    'Pexels creator',
            category: query,
          ),
        )
        .toList();
  }
}