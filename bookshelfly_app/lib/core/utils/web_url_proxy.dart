import 'package:flutter/foundation.dart';

String proxiedWebUrl(String url) {
  if (!kIsWeb || url.isEmpty) {
    return url;
  }

  final uri = Uri.tryParse(url);
  if (uri == null) {
    return url;
  }

  final host = uri.host.toLowerCase();
  final needsProxy = host.contains('gutenberg.org');

  if (!needsProxy) {
    return url;
  }

  final normalizedUri = _normalizeGutenbergUri(
    uri.scheme.isEmpty ? uri.replace(scheme: 'https') : uri,
  );
  final proxyUri = Uri(
    path: '/gutenberg${normalizedUri.path}',
    queryParameters: normalizedUri.hasQuery ? normalizedUri.queryParameters : null,
  );

  return proxyUri.toString();
}

Uri _normalizeGutenbergUri(Uri uri) {
  final path = uri.path;

  final plainTextMatch = RegExp(r'^/ebooks/(\d+)\.txt\.utf-8$').firstMatch(path);
  if (plainTextMatch != null) {
    final bookId = plainTextMatch.group(1)!;
    return uri.replace(path: '/cache/epub/$bookId/pg$bookId.txt');
  }

  final htmlImagesMatch = RegExp(r'^/ebooks/(\d+)\.html\.images$').firstMatch(path);
  if (htmlImagesMatch != null) {
    final bookId = htmlImagesMatch.group(1)!;
    return uri.replace(path: '/cache/epub/$bookId/pg$bookId-images.html');
  }

  return uri;
}
