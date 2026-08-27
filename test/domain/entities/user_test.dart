import 'package:andenken_app/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime.utc(2026, 5, 12, 13, 33, 25);

  test('guarda id, email e createdAt', () {
    final user = User(
      id: 'uid-abc',
      email: 'alex@example.com',
      createdAt: createdAt,
    );

    expect(user.id, 'uid-abc');
    expect(user.email, 'alex@example.com');
    expect(user.createdAt, createdAt);
  });

  test('copyWith altera só os campos passados', () {
    final user = User(
      id: 'uid-abc',
      email: 'alex@example.com',
      createdAt: createdAt,
    );

    final renamed = user.copyWith(email: 'novo@example.com');

    expect(renamed.id, user.id);
    expect(renamed.createdAt, user.createdAt);
    expect(renamed.email, 'novo@example.com');
  });
}
