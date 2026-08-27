import '../entities/card.dart';
import '../repositories/card_repository.dart';
import 'card_review.dart';

class ReviewCard {
  const ReviewCard(this._cards, {this.cardReview = const CardReview()});

  final CardRepository _cards;
  final CardReview cardReview;

  Future<Card> call({
    required String userId,
    required Card card,
    required int grade,
    required DateTime now,
  }) {
    final reviewed = cardReview(card, grade, now);
    return _cards.update(reviewed, userId: userId);
  }
}
