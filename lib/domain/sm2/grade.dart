/// Nota da revisão (algoritmo §3). Inteiro em `[0, 5]`.
class Grade {
  static const int min = 0;
  static const int max = 5;
  static const int passThreshold = 3;

  factory Grade(int value) {
    if (value < min || value > max) {
      throw ArgumentError.value(value, 'grade', 'deve estar em [$min, $max]');
    }
    return Grade._(value);
  }

  const Grade._(this.value);

  final int value;

  bool get isSuccess => value >= passThreshold;
}
