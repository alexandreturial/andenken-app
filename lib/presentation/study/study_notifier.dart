import 'package:flutter/foundation.dart';

import '../../domain/card/card_exception.dart';
import '../../domain/entities/card.dart';
import '../../domain/usecases/list_due_cards.dart';
import '../../domain/usecases/review_card.dart';

enum StudyPhase { loading, empty, front, back, done, error }

class StudyViewState {
  const StudyViewState({
    this.phase = StudyPhase.loading,
    this.current,
    this.remainingCount = 0,
    this.reviewedCount = 0,
    this.sessionSize = 0,
    this.completedCount = 0,
    this.error,
  });

  final StudyPhase phase;
  final Card? current;
  final int remainingCount;
  final int reviewedCount;
  final int sessionSize;
  final int completedCount;
  final CardException? error;
}

class StudyNotifier extends ValueNotifier<StudyViewState> {
  StudyNotifier({
    required ListDueCards listDueCards,
    required ReviewCard reviewCard,
    required String userId,
    required String deckId,
    DateTime Function()? clock,
  }) : _listDueCards = listDueCards,
       _reviewCard = reviewCard,
       _userId = userId,
       _deckId = deckId,
       _clock = clock ?? DateTime.now,
       super(const StudyViewState());

  final ListDueCards _listDueCards;
  final ReviewCard _reviewCard;
  final String _userId;
  final String _deckId;
  final DateTime Function() _clock;

  final _queue = <Card>[];
  final _reviewedIds = <String>{};
  var _sessionSize = 0;
  var _completedCount = 0;

  StudyViewState _present({
    required StudyPhase phase,
    Card? current,
    CardException? error,
  }) {
    return StudyViewState(
      phase: phase,
      current: current,
      remainingCount: _queue.length,
      reviewedCount: _reviewedIds.length,
      sessionSize: _sessionSize,
      completedCount: _completedCount,
      error: error,
    );
  }

  Future<void> load() async {
    value = const StudyViewState();
    _queue.clear();
    _reviewedIds.clear();
    _sessionSize = 0;
    _completedCount = 0;
    try {
      _queue.addAll(
        await _listDueCards(userId: _userId, deckId: _deckId, now: _clock()),
      );
      _sessionSize = _queue.length;
      if (_queue.isEmpty) {
        value = _present(phase: StudyPhase.empty);
        return;
      }
      value = _present(phase: StudyPhase.front, current: _queue.first);
    } on CardException catch (error) {
      value = _present(phase: StudyPhase.error, error: error);
    } catch (_) {
      value = _present(
        phase: StudyPhase.error,
        error: const CardNetworkException(),
      );
    }
  }

  void reveal() {
    if (value.phase != StudyPhase.front || value.current == null) {
      return;
    }
    value = _present(phase: StudyPhase.back, current: value.current);
  }

  Future<void> grade(int gradeValue) async {
    if (value.phase != StudyPhase.back || _queue.isEmpty) {
      return;
    }
    final current = _queue.first;
    try {
      final updated = await _reviewCard(
        userId: _userId,
        card: current,
        grade: gradeValue,
        now: _clock(),
      );
      _queue.removeAt(0);
      _reviewedIds.add(current.id);
      if (gradeValue < 4) {
        _queue.add(updated);
      } else {
        _completedCount++;
      }
      if (_queue.isEmpty) {
        value = _present(phase: StudyPhase.done);
        return;
      }
      value = _present(phase: StudyPhase.front, current: _queue.first);
    } on CardException catch (error) {
      value = _present(phase: StudyPhase.error, current: current, error: error);
    } catch (_) {
      value = _present(
        phase: StudyPhase.error,
        current: current,
        error: const CardNetworkException(),
      );
    }
  }
}
