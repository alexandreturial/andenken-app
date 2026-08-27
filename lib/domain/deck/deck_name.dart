import 'deck_exception.dart';

const maxDeckNameLength = 80;

String normalizeDeckName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed.length > maxDeckNameLength) {
    throw const InvalidDeckNameException();
  }
  return trimmed;
}
