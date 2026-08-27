import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/entities/deck.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_card_repository.dart';
import '../../fakes/fake_deck_repository.dart';

void main() {
  group('FakeAuthRepository', () {
    test('signUp autentica e watchCurrentUser emite o User', () async {
      final auth = FakeAuthRepository();

      final user = await auth.signUp(email: 'a@b.com', password: 'secret');

      expect(user.email, 'a@b.com');
      expect(await auth.watchCurrentUser().first, same(user));
    });

    test('signOut emite null', () async {
      final auth = FakeAuthRepository();
      await auth.signUp(email: 'a@b.com', password: 'secret');
      await auth.signOut();

      expect(await auth.watchCurrentUser().first, isNull);
    });
  });

  group('FakeDeckRepository + FakeCardRepository', () {
    final createdAt = DateTime.utc(2026, 8, 1);

    test('lista só decks do userId', () async {
      final decks = FakeDeckRepository();
      await decks.create(
        Deck(id: 'd1', userId: 'u1', name: 'A', createdAt: createdAt),
      );
      await decks.create(
        Deck(id: 'd2', userId: 'u2', name: 'B', createdAt: createdAt),
      );

      final listed = await decks.listByUser('u1');
      expect(listed, hasLength(1));
      expect(listed.single.id, 'd1');
    });

    test(
      'apagar deck não remove cards — cascade é do use-case (plan §6.2)',
      () async {
        final cards = FakeCardRepository();
        final decks = FakeDeckRepository();
        await decks.create(
          Deck(id: 'd1', userId: 'u1', name: 'A', createdAt: createdAt),
        );
        await cards.create(
          Card.newCard(
            id: 'c1',
            deckId: 'd1',
            frontText: 'a',
            backText: 'b',
            createdAt: createdAt,
          ),
          userId: 'u1',
        );

        await decks.delete(userId: 'u1', deckId: 'd1');

        expect(await decks.listByUser('u1'), isEmpty);
        expect(
          await cards.listByDeck(userId: 'u1', deckId: 'd1'),
          hasLength(1),
        );
      },
    );
  });
}
