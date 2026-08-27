import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/card/card_exception.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../dto/card_dto.dart';

class FirestoreCardRepository implements CardRepository {
  FirestoreCardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<CardDto> _collection(String userId, String deckId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('decks')
        .doc(deckId)
        .collection('cards')
        .withConverter<CardDto>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            if (data == null) {
              throw const CardNotFoundException();
            }
            return CardDto.fromMap(data);
          },
          toFirestore: (dto, _) => dto.toMap(),
        );
  }

  @override
  Future<List<Card>> listByDeck({
    required String userId,
    required String deckId,
  }) {
    return _run(() async {
      final snapshot = await _collection(
        userId,
        deckId,
      ).orderBy('createdAt').get();
      return snapshot.docs
          .map((doc) => doc.data().toDomain(id: doc.id, deckId: deckId))
          .toList(growable: false);
    });
  }

  @override
  Future<List<Card>> listDueByDeck({
    required String userId,
    required String deckId,
    required DateTime until,
  }) {
    return _run(() async {
      final snapshot = await _collection(userId, deckId)
          .where('nextReviewAt', isLessThanOrEqualTo: Timestamp.fromDate(until))
          .orderBy('nextReviewAt')
          .get();
      return snapshot.docs
          .map((doc) => doc.data().toDomain(id: doc.id, deckId: deckId))
          .toList(growable: false);
    });
  }

  @override
  Future<Card> getById({
    required String userId,
    required String deckId,
    required String cardId,
  }) {
    return _run(() async {
      final snapshot = await _collection(userId, deckId).doc(cardId).get();
      final dto = snapshot.data();
      if (!snapshot.exists || dto == null) {
        throw const CardNotFoundException();
      }
      return dto.toDomain(id: snapshot.id, deckId: deckId);
    });
  }

  @override
  Future<Card> create(Card card, {required String userId}) {
    return _run(() async {
      await _collection(
        userId,
        card.deckId,
      ).doc(card.id).set(CardDto.fromCard(card));
      return card;
    });
  }

  @override
  Future<Card> update(Card card, {required String userId}) {
    return _run(() async {
      await _collection(
        userId,
        card.deckId,
      ).doc(card.id).set(CardDto.fromCard(card));
      return card;
    });
  }

  @override
  Future<void> delete({
    required String userId,
    required String deckId,
    required String cardId,
  }) {
    return _run(() => _collection(userId, deckId).doc(cardId).delete());
  }

  @override
  Future<void> deleteByDeck({required String userId, required String deckId}) {
    return _run(() async {
      final snapshot = await _collection(userId, deckId).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CardException {
      rethrow;
    } on FirebaseException catch (error) {
      if (error.code == 'not-found') {
        throw const CardNotFoundException();
      }
      throw const CardNetworkException();
    } catch (_) {
      throw const CardNetworkException();
    }
  }
}
