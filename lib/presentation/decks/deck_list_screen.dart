import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/molecules/andenken_app_bar.dart';
import '../../core/widget/molecules/app_bottom_nav.dart';
import '../../core/widget/molecules/confirm_delete_dialog.dart';
import '../../domain/deck/deck_exception.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/study_stats_repository.dart';
import '../../domain/study/deck_mastery.dart';
import '../../domain/study/pick_study_deck.dart';
import '../../domain/study/study_stats.dart';
import '../../domain/usecases/delete_deck.dart';
import '../../domain/usecases/list_cards.dart';
import '../../domain/usecases/list_decks.dart';
import 'deck_error_message.dart';
import 'deck_list_notifier.dart';

const _deckIcons = <IconData>[
  Icons.school,
  Icons.flight_takeoff,
  Icons.menu_book,
  Icons.work,
  Icons.restaurant,
  Icons.commute,
];

/// Frame Stitch "Lista de Decks" (`.../screens/ffce7272f94244d2ae0940cd0baae1bd`).
class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  DeckListNotifier? _notifier;

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
    _notifier = DeckListNotifier(
      listDecks: context.read<ListDecks>(),
      deleteDeck: context.read<DeleteDeck>(),
      listCards: context.read<ListCards>(),
      studyStats: context.read<StudyStatsRepository>(),
      userId: user.id,
    )..load();
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  Future<void> _openNewDeck() async {
    await context.push('/decks/new');
    if (mounted) {
      await _notifier?.load();
    }
  }

  Future<void> _openRename(Deck deck) async {
    await context.push('/decks/${deck.id}/edit');
    if (mounted) {
      await _notifier?.load();
    }
  }

  Future<void> _openEdit(Deck deck) async {
    await context.push('/decks/${deck.id}');
    if (mounted) {
      await _notifier?.load();
    }
  }

  Future<void> _openStudy(Deck deck) async {
    await context.push('/decks/${deck.id}/study');
    if (mounted) {
      await _notifier?.load();
    }
  }

  void _openStudyTab() {
    final state = _notifier?.value;
    if (state == null) {
      return;
    }
    final deck = pickStudyDeck(state.decks, state.dueCountByDeckId);
    if (deck == null) {
      return;
    }
    _openStudy(deck);
  }

  Future<void> _confirmDelete(Deck deck) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Apagar deck?',
      message:
          'O deck e todos os cards serão removidos. Esta ação não pode ser desfeita.',
      confirmLabel: 'Apagar deck',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _notifier?.deleteDeck(deck.id);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AndenkenAppBar(),
      bottomNavigationBar: AppBottomNav(
        active: AppBottomNavTab.decks,
        onDecks: () {},
        onStudy: _openStudyTab,
        onCreate: _openNewDeck,
      ),
      body: notifier == null
          ? const SizedBox.shrink()
          : ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, state, _) {
                return _DeckListBody(
                  state: state,
                  onRetry: notifier.load,
                  onCreate: _openNewDeck,
                  onStudy: _openStudy,
                  onEdit: _openEdit,
                  onRename: _openRename,
                  onDelete: _confirmDelete,
                );
              },
            ),
    );
  }
}

class _DeckListBody extends StatelessWidget {
  const _DeckListBody({
    required this.state,
    required this.onRetry,
    required this.onCreate,
    required this.onStudy,
    required this.onEdit,
    required this.onRename,
    required this.onDelete,
  });

  final DeckListViewState state;
  final Future<void> Function() onRetry;
  final VoidCallback onCreate;
  final ValueChanged<Deck> onStudy;
  final ValueChanged<Deck> onEdit;
  final ValueChanged<Deck> onRename;
  final ValueChanged<Deck> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.containerMargin,
        AppSpacing.stackMd,
        AppSpacing.containerMargin,
        AppSpacing.stackLg,
      ),
      children: [
        const AppText('Your Decks', variant: AppTextVariant.headlineMd),
        const SizedBox(height: AppSpacing.base),
        const AppText(
          'Continue your high-performance study sessions.',
          variant: AppTextVariant.bodyMd,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Tooltip(
          message: 'Create New Deck',
          child: AppButton(
            key: const Key('create-new-deck'),
            label: 'New Deck',
            leading: const Icon(
              Icons.add,
              color: AppColors.onPrimary,
              size: 20,
            ),
            variant: AppButtonVariant.destructive,
            onPressed: onCreate,
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        switch (state.status) {
          DeckListStatus.loading => const Padding(
            padding: EdgeInsets.all(AppSpacing.stackLg),
            child: Center(child: CircularProgressIndicator()),
          ),
          DeckListStatus.error => _ErrorState(
            error: state.error,
            onRetry: onRetry,
          ),
          DeckListStatus.empty => _EmptyState(onCreate: onCreate),
          DeckListStatus.data => _DeckGrid(
            decks: state.decks,
            masteryByDeckId: state.masteryByDeckId,
            onStudy: onStudy,
            onEdit: onEdit,
            onRename: onRename,
            onDelete: onDelete,
            onCreate: onCreate,
          ),
        },
        const SizedBox(height: AppSpacing.stackLg),
        _StreakCard(stats: state.studyStats),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackLg),
      child: Column(
        children: [
          Icon(
            Icons.style_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          const AppText(
            'Lista de decks vazia',
            variant: AppTextVariant.headlineMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.stackSm),
          AppButton(label: 'Criar deck', onPressed: onCreate),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final DeckException? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          messageForDeckException(error),
          variant: AppTextVariant.bodyMd,
          color: AppColors.error,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.stackMd),
        AppButton(
          label: 'Tentar de novo',
          onPressed: () {
            onRetry();
          },
        ),
      ],
    );
  }
}

class _DeckGrid extends StatelessWidget {
  const _DeckGrid({
    required this.decks,
    required this.masteryByDeckId,
    required this.onStudy,
    required this.onEdit,
    required this.onRename,
    required this.onDelete,
    required this.onCreate,
  });

  final List<Deck> decks;
  final Map<String, DeckMastery> masteryByDeckId;
  final ValueChanged<Deck> onStudy;
  final ValueChanged<Deck> onEdit;
  final ValueChanged<Deck> onRename;
  final ValueChanged<Deck> onDelete;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < decks.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.gutter),
          _DeckTile(
            deck: decks[i],
            mastery:
                masteryByDeckId[decks[i].id] ??
                const DeckMastery(total: 0, dueCount: 0, percent: 0),
            icon: _deckIcons[i % _deckIcons.length],
            onStudy: () => onStudy(decks[i]),
            onEdit: () => onEdit(decks[i]),
            onRename: () => onRename(decks[i]),
            onDelete: () => onDelete(decks[i]),
          ),
        ],
        const SizedBox(height: AppSpacing.gutter),
        _CreateDeckTile(onCreate: onCreate),
      ],
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.deck,
    required this.mastery,
    required this.icon,
    required this.onStudy,
    required this.onEdit,
    required this.onRename,
    required this.onDelete,
  });

  final Deck deck;
  final DeckMastery mastery;
  final IconData icon;
  final VoidCallback onStudy;
  final VoidCallback onEdit;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceContainerLow,
      child: InkWell(
        onTap: onStudy,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppText(
                      deck.name,
                      variant: AppTextVariant.headlineMd,
                      color: AppColors.secondaryContainer,
                    ),
                  ),
                  Icon(icon, color: AppColors.secondaryContainer),
                  PopupMenuButton<String>(
                    tooltip: 'Ações do deck',
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'rename') {
                        onRename();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem<String>(
                        value: 'rename',
                        child: Text('Renomear'),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Apagar'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              AppText(
                mastery.total == 1 ? '1 Card' : '${mastery.total} Cards',
                variant: AppTextVariant.labelSm,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.stackMd),
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      'Mastery: ${mastery.percent}%',
                      variant: AppTextVariant.labelSm,
                    ),
                  ),
                  AppText(
                    '${mastery.dueCount} cards left',
                    variant: AppTextVariant.labelSm,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: mastery.percent / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  color: AppColors.secondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateDeckTile extends StatelessWidget {
  const _CreateDeckTile({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCreate,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          constraints: const BoxConstraints(minHeight: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.outlineVariant,
              style: BorderStyle.solid,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle, color: AppColors.onSurfaceVariant),
              SizedBox(height: 8),
              AppText(
                'Create New Deck',
                variant: AppTextVariant.labelSm,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.stats});

  final StudyStats? stats;

  @override
  Widget build(BuildContext context) {
    final streak = stats?.currentStreak ?? 0;
    final week = StudyStreakWeek.fromStats(stats, DateTime.now());
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final body = streak == 0
        ? 'Start a session to begin your streak. Discipline is the bridge between goals and accomplishment.'
        : "You've studied for $streak days straight. Discipline is the bridge between goals and accomplishment.";
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Daily Streak',
            variant: AppTextVariant.headlineMd,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.stackSm),
          AppText(
            body,
            variant: AppTextVariant.bodyMd,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: week.filledMondayToSunday[i]
                            ? AppColors.secondaryContainer
                            : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: AppText(
                          labels[i],
                          variant: AppTextVariant.labelSm,
                          color: week.filledMondayToSunday[i]
                              ? AppColors.onSecondary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
