import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/deck/deck_exception.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/deck_repository.dart';
import '../dto/deck_dto.dart';

class FirestoreDeckRepository implements DeckRepository {
  FirestoreDeckRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<DeckDto> _collection(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('decks')
        .withConverter<DeckDto>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            if (data == null) {
              throw const DeckNotFoundException();
            }
            return DeckDto.fromMap(data);
          },
          toFirestore: (dto, _) => dto.toMap(),
        );
  }

  @override
  Future<List<Deck>> listByUser(String userId) {
    return _run(() async {
      final snapshot = await _collection(userId).orderBy('createdAt').get();
      return snapshot.docs
          .map((doc) => doc.data().toDomain(id: doc.id, userId: userId))
          .toList(growable: false);
    });
  }

  @override
  Future<Deck> getById({required String userId, required String deckId}) {
    return _run(() async {
      final snapshot = await _collection(userId).doc(deckId).get();
      final dto = snapshot.data();
      if (!snapshot.exists || dto == null) {
        throw const DeckNotFoundException();
      }
      return dto.toDomain(id: snapshot.id, userId: userId);
    });
  }

  @override
  Future<Deck> create(Deck deck) {
    return _run(() async {
      await _collection(deck.userId).doc(deck.id).set(DeckDto.fromDeck(deck));
      return deck;
    });
  }

  @override
  Future<Deck> rename({
    required String userId,
    required String deckId,
    required String name,
    required DateTime updatedAt,
  }) {
    return _run(() async {
      await _collection(userId).doc(deckId).update({
        'name': name,
        'updatedAt': Timestamp.fromDate(updatedAt),
      });
      return getById(userId: userId, deckId: deckId);
    });
  }

  @override
  Future<void> delete({required String userId, required String deckId}) {
    return _run(() => _collection(userId).doc(deckId).delete());
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DeckException {
      rethrow;
    } on FirebaseException catch (error) {
      if (error.code == 'not-found') {
        throw const DeckNotFoundException();
      }
      throw const DeckNetworkException();
    } catch (_) {
      throw const DeckNetworkException();
    }
  }
}
