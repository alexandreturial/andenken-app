import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_card.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/molecules/confirm_delete_dialog.dart';
import '../../core/widget/templates/app_page_template.dart';
import '../../domain/entities/card.dart' as domain;
import '../../domain/entities/deck.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/usecases/delete_card.dart';
import '../../domain/usecases/delete_deck.dart';
import '../../domain/usecases/list_cards.dart';
import '../cards/card_error_message.dart';
import 'deck_detail_notifier.dart';

/// Aproxima o frame Stitch "Visualização de Card"
/// (`spec.md` §7.1). Empty state ainda sem frame (T057).
class DeckDetailScreen extends StatefulWidget {
  const DeckDetailScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  DeckDetailNotifier? _notifier;
  var _didLeave = false;

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
    _notifier = DeckDetailNotifier(
      decks: context.read<DeckRepository>(),
      listCards: context.read<ListCards>(),
      deleteCard: context.read<DeleteCard>(),
      deleteDeck: context.read<DeleteDeck>(),
      userId: user.id,
      deckId: widget.deckId,
    )..load();
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  Future<void> _openNewCard() async {
    await context.push('/decks/${widget.deckId}/cards/new');
    if (mounted) {
      await _notifier?.load();
    }
  }

  Future<void> _openEditCard(domain.Card card) async {
    await context.push('/decks/${widget.deckId}/cards/${card.id}/edit');
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

  Future<void> _confirmDeleteCard(domain.Card card) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Apagar card?',
      message: 'Este card será removido. Esta ação não pode ser desfeita.',
      confirmLabel: 'Apagar card',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _notifier?.deleteCard(card.id);
  }

  Future<void> _confirmDeleteDeck(Deck deck) async {
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
    await _notifier?.deleteDeck();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    if (notifier == null) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, state, _) {
        if (state.status == DeckDetailStatus.deleted && !_didLeave) {
          _didLeave = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/decks');
            }
          });
        }
        final deck = state.deck;
        return AppPageTemplate(
          title: deck?.name ?? 'Deck',
          actions: [
            if (deck != null)
              PopupMenuButton<String>(
                tooltip: 'Ações do deck',
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'rename') {
                    _openRename(deck);
                  } else if (value == 'delete') {
                    _confirmDeleteDeck(deck);
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
          floatingActionButton:
              state.status == DeckDetailStatus.data ||
                  state.status == DeckDetailStatus.empty
              ? FloatingActionButton(
                  tooltip: 'Create New Card',
                  onPressed: _openNewCard,
                  child: const Icon(Icons.add),
                )
              : null,
          body: _DeckDetailBody(
            state: state,
            onRetry: notifier.load,
            onAdd: _openNewCard,
            onStudy: () => context.push('/decks/${widget.deckId}/study'),
            onEditCard: _openEditCard,
            onDeleteCard: _confirmDeleteCard,
          ),
        );
      },
    );
  }
}

class _DeckDetailBody extends StatelessWidget {
  const _DeckDetailBody({
    required this.state,
    required this.onRetry,
    required this.onAdd,
    required this.onStudy,
    required this.onEditCard,
    required this.onDeleteCard,
  });

  final DeckDetailViewState state;
  final Future<void> Function() onRetry;
  final VoidCallback onAdd;
  final VoidCallback onStudy;
  final ValueChanged<domain.Card> onEditCard;
  final ValueChanged<domain.Card> onDeleteCard;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case DeckDetailStatus.loading:
      case DeckDetailStatus.deleted:
        return const Center(child: CircularProgressIndicator());
      case DeckDetailStatus.error:
        return _ErrorState(error: state.error, onRetry: onRetry);
      case DeckDetailStatus.empty:
        return _EmptyState(onAdd: onAdd);
      case DeckDetailStatus.data:
        return _CardList(
          cards: state.cards,
          onStudy: onStudy,
          onEdit: onEditCard,
          onDelete: onDeleteCard,
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

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
              'Nenhum card neste deck',
              variant: AppTextVariant.headlineMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.stackSm),
            const AppText(
              'Adicione o primeiro card para começar a estudar.',
              variant: AppTextVariant.bodyMd,
              color: AppColors.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.stackMd),
            AppButton(label: 'Adicionar card', onPressed: onAdd),
            const SizedBox(height: AppSpacing.gutter),
            const AppButton(label: 'Estudar', onPressed: null),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object? error;
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
              messageForDetailError(error),
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

class _CardList extends StatelessWidget {
  const _CardList({
    required this.cards,
    required this.onStudy,
    required this.onEdit,
    required this.onDelete,
  });

  final List<domain.Card> cards;
  final VoidCallback onStudy;
  final ValueChanged<domain.Card> onEdit;
  final ValueChanged<domain.Card> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.stackMd),
        AppButton(
          label: 'Estudar',
          trailingIcon: Icons.school_outlined,
          onPressed: onStudy,
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: cards.length,
            separatorBuilder: (context, _) =>
                const SizedBox(height: AppSpacing.gutter),
            itemBuilder: (context, index) {
              final card = cards[index];
              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.stackMd),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onEdit(card),
                        child: AppText(
                          card.frontText,
                          variant: AppTextVariant.headlineMd,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Ações do card',
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit(card);
                        } else if (value == 'delete') {
                          onDelete(card);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Apagar'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
