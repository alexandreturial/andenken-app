import 'package:andenken_app/domain/card/card_exception.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/usecases/list_due_cards.dart';
import 'package:andenken_app/domain/usecases/review_card.dart';
import 'package:andenken_app/presentation/study/study_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_card_repository.dart';

void main() {
  late FakeCardRepository cards;
  late StudyNotifier notifier;
  final now = DateTime.utc(2026, 8, 27, 10);

  StudyNotifier createNotifier() {
    return StudyNotifier(
      listDueCards: ListDueCards(cards),
      reviewCard: ReviewCard(cards),
      userId: 'u1',
      deckId: 'd1',
      clock: () => now,
    );
  }

  Future<void> seed({
    required String id,
    required DateTime nextReviewAt,
    DateTime? createdAt,
    String frontText = '',
  }) {
    final created = createdAt ?? nextReviewAt;
    return cards.create(
      Card(
        id: id,
        deckId: 'd1',
        frontText: frontText.isEmpty ? id : frontText,
        backText: 'verso-$id',
        nextReviewAt: nextReviewAt,
        createdAt: created,
        updatedAt: created,
      ),
      userId: 'u1',
    );
  }

  setUp(() {
    cards = FakeCardRepository();
    notifier = createNotifier();
  });

  tearDown(() => notifier.dispose());

  test('começa em loading', () {
    expect(notifier.value.phase, StudyPhase.loading);
    expect(notifier.value.current, isNull);
  });

  test('sem due vai para empty (RN-S10)', () async {
    await seed(id: 'later', nextReviewAt: DateTime.utc(2026, 8, 29));

    await notifier.load();

    expect(notifier.value.phase, StudyPhase.empty);
    expect(notifier.value.current, isNull);
    expect(notifier.value.reviewedCount, 0);
  });

  test('com due vai para front no primeiro da fila (RN-S02)', () async {
    await seed(
      id: 'second',
      nextReviewAt: DateTime.utc(2026, 8, 27, 9),
      createdAt: DateTime.utc(2026, 8, 10),
      frontText: 'Danke',
    );
    await seed(
      id: 'first',
      nextReviewAt: DateTime.utc(2026, 8, 27, 9),
      createdAt: DateTime.utc(2026, 8, 2),
      frontText: 'Hallo',
    );

    await notifier.load();

    expect(notifier.value.phase, StudyPhase.front);
    expect(notifier.value.current?.id, 'first');
    expect(notifier.value.current?.frontText, 'Hallo');
    expect(notifier.value.remainingCount, 2);
  });

  test('reveal passa de front para back', () async {
    await seed(
      id: 'c1',
      nextReviewAt: DateTime.utc(2026, 8, 1),
      frontText: 'Hallo',
    );
    await notifier.load();

    notifier.reveal();

    expect(notifier.value.phase, StudyPhase.back);
    expect(notifier.value.current?.frontText, 'Hallo');
    expect(notifier.value.current?.backText, 'verso-c1');
  });

  test('grade >= 4 persiste, não reenfileira e vai ao próximo', () async {
    await seed(
      id: 'c1',
      nextReviewAt: DateTime.utc(2026, 8, 1),
      createdAt: DateTime.utc(2026, 8, 1),
    );
    await seed(
      id: 'c2',
      nextReviewAt: DateTime.utc(2026, 8, 2),
      createdAt: DateTime.utc(2026, 8, 2),
    );
    await notifier.load();
    notifier.reveal();

    await notifier.grade(5);

    expect(notifier.value.phase, StudyPhase.front);
    expect(notifier.value.current?.id, 'c2');
    expect(notifier.value.remainingCount, 1);
    expect(notifier.value.reviewedCount, 1);
    final stored = await cards.getById(
      userId: 'u1',
      deckId: 'd1',
      cardId: 'c1',
    );
    expect(stored.repetitions, 1);
    expect(stored.lastReviewedAt, now);
  });

  test('grade < 4 reenfileira o card atualizado (RN-S08)', () async {
    await seed(
      id: 'c1',
      nextReviewAt: DateTime.utc(2026, 8, 1),
      createdAt: DateTime.utc(2026, 8, 1),
    );
    await seed(
      id: 'c2',
      nextReviewAt: DateTime.utc(2026, 8, 2),
      createdAt: DateTime.utc(2026, 8, 2),
    );
    await notifier.load();
    notifier.reveal();

    await notifier.grade(3);

    expect(notifier.value.phase, StudyPhase.front);
    expect(notifier.value.current?.id, 'c2');
    expect(notifier.value.remainingCount, 2);
    notifier.reveal();
    await notifier.grade(5);

    expect(notifier.value.phase, StudyPhase.front);
    expect(notifier.value.current?.id, 'c1');
    expect(notifier.value.current?.repetitions, 1);
  });

  test('último card com grade >= 4 vai para done', () async {
    await seed(id: 'c1', nextReviewAt: DateTime.utc(2026, 8, 1));
    await notifier.load();
    notifier.reveal();

    await notifier.grade(4);

    expect(notifier.value.phase, StudyPhase.done);
    expect(notifier.value.current, isNull);
    expect(notifier.value.reviewedCount, 1);
    expect(notifier.value.remainingCount, 0);
  });

  test('mesmo card com grade < 4 volta à fila até grade >= 4', () async {
    await seed(id: 'c1', nextReviewAt: DateTime.utc(2026, 8, 1));
    await notifier.load();
    notifier.reveal();
    await notifier.grade(2);

    expect(notifier.value.phase, StudyPhase.front);
    expect(notifier.value.current?.id, 'c1');
    expect(notifier.value.current?.repetitions, 0);
    expect(notifier.value.reviewedCount, 1);

    notifier.reveal();
    await notifier.grade(5);

    expect(notifier.value.phase, StudyPhase.done);
    expect(notifier.value.reviewedCount, 1);
  });

  test('falha de rede no load vai para error', () async {
    cards.forcedListError = const CardNetworkException();

    await notifier.load();

    expect(notifier.value.phase, StudyPhase.error);
    expect(notifier.value.error, isA<CardNetworkException>());
  });
}
