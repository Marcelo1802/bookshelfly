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

  final normalizedUri = uri.scheme.isEmpty ? uri.replace(scheme: 'https') : uri;
  final proxyUri = Uri(
    path: '/gutenberg${normalizedUri.path}',
    queryParameters: normalizedUri.hasQuery ? normalizedUri.queryParameters : null,
  );

  return proxyUri.toString();
}
