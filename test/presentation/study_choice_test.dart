import 'package:andenken_app/presentation/study/study_choice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudyChoice mapper (RN-U01, RN-U02)', () {
    test('quatro opções na ordem do spec', () {
      expect(StudyChoice.values, [
        StudyChoice.forgotten,
        StudyChoice.hard,
        StudyChoice.remembered,
        StudyChoice.known,
      ]);
    });

    test('rótulos em pt-BR', () {
      expect(StudyChoice.forgotten.label, 'Não lembro');
      expect(StudyChoice.hard.label, 'Lembrei com dificuldade');
      expect(StudyChoice.remembered.label, 'Lembrei');
      expect(StudyChoice.known.label, 'Conheço');
    });

    test('mapeia para grade SM-2 0, 4, 5, 5', () {
      expect(StudyChoice.forgotten.sm2Grade, 0);
      expect(StudyChoice.hard.sm2Grade, 4);
      expect(StudyChoice.remembered.sm2Grade, 5);
      expect(StudyChoice.known.sm2Grade, 5);
    });

    test('Lembrei e Conheço são o mesmo grade 5', () {
      expect(StudyChoice.remembered.sm2Grade, StudyChoice.known.sm2Grade);
      expect(StudyChoice.remembered.sm2Grade, 5);
    });
  });
}
