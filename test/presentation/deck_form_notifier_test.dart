import 'package:andenken_app/domain/deck/deck_exception.dart';
import 'package:andenken_app/domain/entities/deck.dart';
import 'package:andenken_app/domain/usecases/create_deck.dart';
import 'package:andenken_app/domain/usecases/rename_deck.dart';
import 'package:andenken_app/presentation/decks/deck_form_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_deck_repository.dart';

void main() {
  late FakeDeckRepository decks;
  late DeckFormNotifier notifier;
  final now = DateTime.utc(2026, 8, 2);

  DeckFormNotifier createNotifier({String? deckId}) {
    return DeckFormNotifier(
      createDeck: CreateDeck(decks, generateId: () => 'd-new'),
      renameDeck: RenameDeck(decks),
      decks: decks,
      userId: 'u1',
      deckId: deckId,
      clock: () => now,
    );
  }

  setUp(() {
    decks = FakeDeckRepository();
  });

  tearDown(() => notifier.dispose());

  test('create com nome válido vai para success', () async {
    notifier = createNotifier();

    await notifier.submit('  Alemão A1  ');

    expect(notifier.value.status, DeckFormStatus.success);
    expect(
      (await decks.getById(userId: 'u1', deckId: 'd-new')).name,
      'Alemão A1',
    );
  });

  test('create com nome vazio vai para error e não grava', () async {
    notifier = createNotifier();

    await notifier.submit('   ');

    expect(notifier.value.status, DeckFormStatus.error);
    expect(notifier.value.error, isA<InvalidDeckNameException>());
    expect(await decks.listByUser('u1'), isEmpty);
  });

  test('rename carrega o nome e atualiza', () async {
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'u1',
        name: 'Antigo',
        createdAt: DateTime.utc(2026, 8, 1),
      ),
    );
    notifier = createNotifier(deckId: 'd1');

    await notifier.load();

    expect(notifier.value.initialName, 'Antigo');
    expect(notifier.value.status, DeckFormStatus.idle);

    await notifier.submit('Novo nome');

    expect(notifier.value.status, DeckFormStatus.success);
    expect((await decks.getById(userId: 'u1', deckId: 'd1')).name, 'Novo nome');
  });

  test('rename de deck inexistente vai para error', () async {
    notifier = createNotifier(deckId: 'missing');

    await notifier.load();

    expect(notifier.value.status, DeckFormStatus.error);
    expect(notifier.value.error, isA<DeckNotFoundException>());
  });
}
