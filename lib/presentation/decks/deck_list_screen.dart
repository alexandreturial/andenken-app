import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_card.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/molecules/confirm_delete_dialog.dart';
import '../../core/widget/templates/app_page_template.dart';
import '../../domain/deck/deck_exception.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/delete_deck.dart';
import '../../domain/usecases/list_decks.dart';
import '../../domain/usecases/list_due_cards.dart';
import '../../domain/usecases/sign_out.dart';
import 'deck_error_message.dart';
import 'deck_list_notifier.dart';

/// Layout do frame Stitch "Lista de Decks (Clean)"
/// (`.../screens/8bd6aff9cc3f47f689384e06196f578c`).
/// Sem bento/mastery/streak/bottom nav (fora do spec). Badge due (T067).
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
      listDueCards: context.read<ListDueCards>(),
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

  Future<void> _openDeck(Deck deck) async {
    await context.push('/decks/${deck.id}');
    if (mounted) {
      await _notifier?.load();
    }
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
    return AppPageTemplate(
      title: 'Andenken',
      leading: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.gutter),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryContainer,
          child: Icon(
            Icons.person,
            size: 18,
            color: AppColors.onPrimaryContainer,
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Settings',
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.onSurfaceVariant,
          ),
          onSelected: (value) async {
            if (value == 'logout') {
              await context.read<SignOut>()();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
          ],
        ),
      ],
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create New Deck',
        onPressed: _openNewDeck,
        child: const Icon(Icons.add),
      ),
      body: notifier == null
          ? const SizedBox.shrink()
          : ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, state, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.stackMd),
                    const AppText(
                      'My Decks',
                      variant: AppTextVariant.headlineLg,
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Expanded(
                      child: _DeckListBody(
                        state: state,
                        onRetry: notifier.load,
                        onCreate: _openNewDeck,
                        onOpen: _openDeck,
                        onRename: _openRename,
                        onDelete: _confirmDelete,
                      ),
                    ),
                  ],
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
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final DeckListViewState state;
  final Future<void> Function() onRetry;
  final VoidCallback onCreate;
  final ValueChanged<Deck> onOpen;
  final ValueChanged<Deck> onRename;
  final ValueChanged<Deck> onDelete;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case DeckListStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case DeckListStatus.error:
        return _ErrorState(error: state.error, onRetry: onRetry);
      case DeckListStatus.empty:
        return _EmptyState(onCreate: onCreate);
      case DeckListStatus.data:
        return _DeckCards(
          decks: state.decks,
          dueCountByDeckId: state.dueCountByDeckId,
          onOpen: onOpen,
          onRename: onRename,
          onDelete: onDelete,
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const AppText(
              'Crie o primeiro deck para começar a estudar.',
              variant: AppTextVariant.bodyMd,
              color: AppColors.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.stackMd),
            AppButton(label: 'Criar deck', onPressed: onCreate),
          ],
        ),
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
        ),
      ),
    );
  }
}

class _DeckCards extends StatelessWidget {
  const _DeckCards({
    required this.decks,
    required this.dueCountByDeckId,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final List<Deck> decks;
  final Map<String, int> dueCountByDeckId;
  final ValueChanged<Deck> onOpen;
  final ValueChanged<Deck> onRename;
  final ValueChanged<Deck> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: decks.length,
      separatorBuilder: (context, _) =>
          const SizedBox(height: AppSpacing.gutter),
      itemBuilder: (context, index) {
        final deck = decks[index];
        final due = dueCountByDeckId[deck.id] ?? 0;
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.stackMd),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onOpen(deck),
                  child: AppText(deck.name, variant: AppTextVariant.headlineMd),
                ),
              ),
              const SizedBox(width: AppSpacing.gutter),
              GestureDetector(
                onTap: () => onOpen(deck),
                child: _DueBadge(count: due),
              ),
              PopupMenuButton<String>(
                tooltip: 'Ações do deck',
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'rename') {
                    onRename(deck);
                  } else if (value == 'delete') {
                    onDelete(deck);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'rename',
                    child: Text('Renomear'),
                  ),
                  PopupMenuItem<String>(value: 'delete', child: Text('Apagar')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
      ),
      child: AppText(
        '$count due',
        variant: AppTextVariant.labelSm,
        color: AppColors.gold,
      ),
    );
  }
}
