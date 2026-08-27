import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_card.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/templates/app_page_template.dart';
import '../../domain/entities/card.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/list_due_cards.dart';
import '../../domain/usecases/review_card.dart';
import '../cards/card_error_message.dart';
import 'study_grade_labels.dart';
import 'study_notifier.dart';

/// Frame Stitch "Estudo de Cards (Clean)"
/// (`.../screens/482d87635e234fc69320c6f194781900`).
/// Dark tokens. Sem bottom nav, tags, categoria nem intervalos SM-2.
/// Spec: 6 notas 0–5 e “Mostrar resposta”.
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  StudyNotifier? _notifier;

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
      userId: user.id,
      deckId: widget.deckId,
    )..load();
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/decks/${widget.deckId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    if (notifier == null) {
      return const SizedBox.shrink();
    }
    return AppPageTemplate(
      title: 'Estudo',
      leading: IconButton(
        tooltip: 'Fechar sessão',
        onPressed: _leave,
        icon: const Icon(Icons.close),
      ),
      body: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, state, _) {
          return Align(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _StudyBody(
                state: state,
                onReveal: notifier.reveal,
                onGrade: notifier.grade,
                onRetry: notifier.load,
                onLeave: _leave,
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
    required this.onReveal,
    required this.onGrade,
    required this.onRetry,
    required this.onLeave,
  });

  final StudyViewState state;
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
          onReveal: onReveal,
          onGrade: onGrade,
        );
    }
  }
}

class _StudySession extends StatelessWidget {
  const _StudySession({
    required this.state,
    required this.onReveal,
    required this.onGrade,
  });

  final StudyViewState state;
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
          children: [
            const Expanded(
              child: AppText(
                'Daily Session',
                variant: AppTextVariant.labelSm,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            AppText(
              '${state.completedCount} / ${state.sessionSize}',
              variant: AppTextVariant.labelSm,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackSm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: state.completedCount / total,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHighest,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Expanded(
          child: _FlashCard(card: card, showingBack: showingBack),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        if (!showingBack)
          AppButton(
            label: 'Mostrar resposta',
            leading: const Icon(
              Icons.flip,
              size: 20,
              color: AppColors.onSecondaryContainer,
            ),
            prominent: true,
            onPressed: onReveal,
          )
        else
          _GradePad(onGrade: onGrade),
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
    return AppCard(
      child: Center(
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
    );
  }
}

class _GradePad extends StatelessWidget {
  const _GradePad({required this.onGrade});

  final Future<void> Function(int grade) onGrade;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: AppSpacing.stackSm),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: AppSpacing.stackSm),
                Expanded(
                  child: _GradeButton(
                    grade: row * 3 + col,
                    onPressed: () => onGrade(row * 3 + col),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({required this.grade, required this.onPressed});

  final int grade;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fail = grade < 3;
    return Semantics(
      button: true,
      label: 'Nota $grade',
      child: Material(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: InkWell(
          key: Key('grade-$grade'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.stackSm,
              horizontal: 4,
            ),
            child: Column(
              children: [
                AppText(
                  '$grade',
                  variant: AppTextVariant.headlineMd,
                  color: fail ? AppColors.primary : AppColors.gold,
                ),
                const SizedBox(height: 4),
                AppText(
                  labelForGrade(grade),
                  variant: AppTextVariant.labelSm,
                  color: AppColors.onSurfaceVariant,
                  textAlign: TextAlign.center,
                ),
              ],
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
