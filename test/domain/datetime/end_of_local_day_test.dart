import 'package:andenken_app/domain/datetime/end_of_local_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retorna 23:59:59.999 do mesmo dia civil local', () {
    final noon = DateTime(2026, 8, 25, 12, 0, 0);

    final end = endOfLocalDay(noon);

    expect(end.year, 2026);
    expect(end.month, 8);
    expect(end.day, 25);
    expect(end.hour, 23);
    expect(end.minute, 59);
    expect(end.second, 59);
    expect(end.millisecond, 999);
    expect(end.isUtc, isFalse);
  });

  test('instante UTC usa o calendário local do dispositivo', () {
    final utc = DateTime.utc(2026, 8, 25, 3, 0, 0);

    final end = endOfLocalDay(utc);
    final local = utc.toLocal();

    expect(end.year, local.year);
    expect(end.month, local.month);
    expect(end.day, local.day);
    expect(end.hour, 23);
    expect(end.minute, 59);
    expect(end.second, 59);
    expect(end.millisecond, 999);
  });
}
