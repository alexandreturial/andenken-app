import 'card_exception.dart';

const maxFrontTextLength = 500;
const maxBackTextLength = 2000;

String normalizeFrontText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > maxFrontTextLength) {
    throw const InvalidCardTextException();
  }
  return trimmed;
}

String normalizeBackText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > maxBackTextLength) {
    throw const InvalidCardTextException();
  }
  return trimmed;
}
