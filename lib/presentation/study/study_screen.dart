import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/molecules/andenken_app_bar.dart';
import '../../core/widget/molecules/app_bottom_nav.dart';
import '../../domain/entities/card.dart' as domain;
import '../../domain/entities/deck.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/study/pick_study_deck.dart';
import '../../domain/usecases/list_decks.dart';
import '../../domain/usecases/list_due_cards.dart';
import '../../domain/usecases/list_cards.dart';
import '../../domain/usecases/persist_study_day.dart';
import '../../domain/usecases/review_card.dart';
import '../../domain/study/deck_mastery.dart';
import '../cards/card_error_message.dart';
import 'study_choice.dart';
import 'study_notifier.dart';

/// Frame Stitch "Visualização de Card"
/// (`.../screens/ebc67888eb24422cba69955b9bbeb31f`).
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  StudyNotifier? _notifier;
  Deck? _deck;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_notifier != null) {
      return;
    }
    final user = context.read<AuthRepository>().currentUser;
    if (user == null) {
      return;
    }
    _notifier = StudyNotifier(
      listDueCards: context.read<ListDueCards>(),
      reviewCard: context.read<ReviewCard>(),
      persistStudyDay: context.read<PersistStudyDay>(),
      userId: user.id,
      deckId: widget.deckId,
    )..load();
    context
        .read<DeckRepository>()
        .getById(userId: user.id, deckId: widget.deckId)
        .then((deck) {
          if (mounted) {
            setState(() => _deck = deck);
          }
        });
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  Future<void> _openStudyTab() async {
    final user = context.read<AuthRepository>().currentUser;
    if (user == null) {
      return;
    }
    final decks = await context.read<ListDecks>()(userId: user.id);
    final due = <String, int>{};
    final now = DateTime.now();
    for (final deck in decks) {
      final cards = await context.read<ListCards>()(
        userId: user.id,
        deckId: deck.id,
      );
      due[deck.id] = DeckMastery.fromCards(cards, now).dueCount;
    }
    final picked = pickStudyDeck(decks, due);
    if (!mounted || picked == null) {
      context.go('/decks');
      return;
    }
    if (picked.id == widget.deckId) {
      return;
    }
    context.go('/decks/${picked.id}/study');
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    if (notifier == null) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AndenkenAppBar(),
      bottomNavigationBar: AppBottomNav(
        active: AppBottomNavTab.study,
        onDecks: () => context.go('/decks'),
        onStudy: _openStudyTab,
        onCreate: () => context.go('/decks/new'),
      ),
      body: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, state, _) {
          return Align(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                ),
                child: SizedBox.expand(
                  child: _StudyBody(
                    state: state,
                    deckName: _deck?.name ?? 'Deck',
                    onReveal: notifier.reveal,
                    onGrade: notifier.grade,
                    onRetry: notifier.load,
                    onLeave: () => context.go('/decks'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StudyBody extends StatelessWidget {
  const _StudyBody({
    required this.state,
    required this.deckName,
    required this.onReveal,
    required this.onGrade,
    required this.onRetry,
    required this.onLeave,
  });

  final StudyViewState state;
  final String deckName;
  final VoidCallback onReveal;
  final Future<void> Function(int grade) onGrade;
  final Future<void> Function() onRetry;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    switch (state.phase) {
      case StudyPhase.loading:
        return const Center(child: CircularProgressIndicator());
      case StudyPhase.error:
        return _MessageState(
          title: 'Não foi possível carregar o estudo',
          body: messageForCardException(state.error),
          actionLabel: 'Tentar de novo',
          onAction: onRetry,
        );
      case StudyPhase.empty:
        return _MessageState(
          title: 'Nada para revisar hoje',
          body: 'Volte mais tarde ou adicione cards neste deck.',
          actionLabel: 'Voltar ao deck',
          onAction: onLeave,
        );
      case StudyPhase.done:
        final count = state.reviewedCount;
        return _MessageState(
          title: 'Sessão concluída',
          body: count == 1 ? '1 card revisado.' : '$count cards revisados.',
          actionLabel: 'Voltar ao deck',
          onAction: onLeave,
        );
      case StudyPhase.front:
      case StudyPhase.back:
        return _StudySession(
          state: state,
          deckName: deckName,
          onReveal: onReveal,
          onGrade: onGrade,
        );
    }
  }
}

class _StudySession extends StatelessWidget {
  const _StudySession({
    required this.state,
    required this.deckName,
    required this.onReveal,
    required this.onGrade,
  });

  final StudyViewState state;
  final String deckName;
  final VoidCallback onReveal;
  final Future<void> Function(int grade) onGrade;

  @override
  Widget build(BuildContext context) {
    final card = state.current;
    if (card == null) {
      return const SizedBox.shrink();
    }
    final showingBack = state.phase == StudyPhase.back;
    final total = state.sessionSize == 0 ? 1 : state.sessionSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.stackMd),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'CURRENT DECK',
                    variant: AppTextVariant.labelSm,
                    color: AppColors.onSurfaceVariant,
                  ),
                  AppText(deckName, variant: AppTextVariant.headlineMd),
                ],
              ),
            ),
            AppText(
              '${state.completedCount} / ${state.sessionSize} CARDS',
              variant: AppTextVariant.labelSm,
              color: AppColors.secondaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: state.completedCount / total,
            minHeight: 4,
            backgroundColor: AppColors.surfaceContainerHighest,
            color: AppColors.secondaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Expanded(
          child: _FlashCard(card: card, showingBack: showingBack),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        if (!showingBack)
          AppButton(
            label: 'FLIP CARD',
            leading: const Icon(
              Icons.sync,
              size: 20,
              color: AppColors.onSecondary,
            ),
            prominent: true,
            onPressed: onReveal,
          )
        else
          _ChoicePad(onGrade: onGrade),
        const SizedBox(height: AppSpacing.stackMd),
      ],
    );
  }
}

class _FlashCard extends StatelessWidget {
  const _FlashCard({required this.card, required this.showingBack});

  final domain.Card card;
  final bool showingBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (card.lastReviewedAt == null)
            const Positioned(top: 16, left: 16, child: _NewBadge()),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      card.frontText,
                      variant: AppTextVariant.headlineLg,
                      textAlign: TextAlign.center,
                    ),
                    if (showingBack) ...[
                      const SizedBox(height: AppSpacing.stackMd),
                      AppText(
                        card.backText,
                        variant: AppTextVariant.bodyLg,
                        color: AppColors.onSurfaceVariant,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const AppText(
        'New Card',
        variant: AppTextVariant.labelSm,
        color: AppColors.secondaryContainer,
      ),
    );
  }
}

class _ChoicePad extends StatelessWidget {
  const _ChoicePad({required this.onGrade});

  final Future<void> Function(int grade) onGrade;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.gutter,
      mainAxisSpacing: AppSpacing.gutter,
      childAspectRatio: 2.2,
      children: [
        for (final choice in StudyChoice.values)
          _ChoiceTile(
            choice: choice,
            onPressed: () => onGrade(choice.sm2Grade),
          ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.choice, required this.onPressed});

  final StudyChoice choice;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fail = choice == StudyChoice.forgotten;
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        key: Key('study-choice-${choice.name}'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: fail ? AppColors.errorContainer : AppColors.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AppText(
              choice.label,
              variant: AppTextVariant.bodyMd,
              color: fail ? AppColors.error : AppColors.secondaryContainer,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        AppText(
          title,
          variant: AppTextVariant.headlineMd,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.stackSm),
        AppText(
          body,
          variant: AppTextVariant.bodyMd,
          color: AppColors.onSurfaceVariant,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.stackMd),
        AppButton(label: actionLabel, onPressed: onAction),
        const Spacer(),
      ],
    );
  }
}
