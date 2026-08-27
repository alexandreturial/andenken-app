import 'package:andenken_app/domain/card/card_exception.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/usecases/create_card.dart';
import 'package:andenken_app/domain/usecases/update_card.dart';
import 'package:andenken_app/presentation/cards/card_form_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_card_repository.dart';

void main() {
  late FakeCardRepository cards;
  late CardFormNotifier notifier;
  final now = DateTime.utc(2026, 8, 2);

  CardFormNotifier createNotifier({String? cardId}) {
    var nextId = 0;
    return CardFormNotifier(
      createCard: CreateCard(cards, generateId: () => 'c-${nextId++}'),
      updateCard: UpdateCard(cards),
      cards: cards,
      userId: 'u1',
      deckId: 'd1',
      cardId: cardId,
      clock: () => now,
    );
  }

  setUp(() {
    cards = FakeCardRepository();
  });

  tearDown(() => notifier.dispose());

  test('submitDrafts grava vários cards e vai para success', () async {
    notifier = createNotifier();

    await notifier.submitDrafts(const [
      CardDraftInput(frontText: '  Hallo  ', backText: '  Olá  '),
      CardDraftInput(frontText: 'Danke', backText: 'Obrigado'),
    ]);

    expect(notifier.value.status, CardFormStatus.success);
    expect(
      (await cards.listByDeck(
        userId: 'u1',
        deckId: 'd1',
      )).map((card) => card.frontText),
      ['Hallo', 'Danke'],
    );
  });

  test('submitDrafts ignora linhas em branco', () async {
    notifier = createNotifier();

    await notifier.submitDrafts(const [
      CardDraftInput(frontText: 'Hallo', backText: 'Olá'),
      CardDraftInput(frontText: '  ', backText: ''),
    ]);

    expect(notifier.value.status, CardFormStatus.success);
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd1'), hasLength(1));
  });

  test('submitDrafts com frente vazia vai para error e não grava', () async {
    notifier = createNotifier();

    await notifier.submitDrafts(const [
      CardDraftInput(frontText: '   ', backText: 'Olá'),
    ]);

    expect(notifier.value.status, CardFormStatus.error);
    expect(notifier.value.error, isA<InvalidCardTextException>());
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd1'), isEmpty);
  });

  test('edit carrega frente/verso e atualiza sem resetar SM-2', () async {
    final createdAt = DateTime.utc(2026, 8, 1);
    await cards.create(
      Card(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Antigo',
        backText: 'Old',
        repetitions: 3,
        intervalDays: 6,
        easeFactor: 2.6,
        nextReviewAt: DateTime.utc(2026, 8, 10),
        lastReviewedAt: DateTime.utc(2026, 8, 4),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      userId: 'u1',
    );
    notifier = createNotifier(cardId: 'c1');

    await notifier.load();

    expect(notifier.value.initialFront, 'Antigo');
    expect(notifier.value.initialBack, 'Old');
    expect(notifier.value.status, CardFormStatus.idle);

    await notifier.submit(frontText: 'Hallo', backText: 'Olá');

    expect(notifier.value.status, CardFormStatus.success);
    final updated = await cards.getById(
      userId: 'u1',
      deckId: 'd1',
      cardId: 'c1',
    );
    expect(updated.frontText, 'Hallo');
    expect(updated.backText, 'Olá');
    expect(updated.repetitions, 3);
    expect(updated.easeFactor, 2.6);
  });

  test('edit de card inexistente vai para error', () async {
    notifier = createNotifier(cardId: 'missing');

    await notifier.load();

    expect(notifier.value.status, CardFormStatus.error);
    expect(notifier.value.error, isA<CardNotFoundException>());
  });
}
