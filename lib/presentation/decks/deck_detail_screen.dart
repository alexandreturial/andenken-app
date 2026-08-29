import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_card.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/molecules/confirm_delete_dialog.dart';
import '../../domain/entities/card.dart' as domain;
import '../../domain/entities/deck.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/usecases/delete_card.dart';
import '../../domain/usecases/delete_deck.dart';
import '../../domain/usecases/list_cards.dart';
import '../cards/card_error_message.dart';
import 'deck_detail_notifier.dart';

/// Detalhe do deck (US-04): lista de cards, criar/editar/apagar.
/// O frame Visualização de Card é a `StudyScreen` (005).
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

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/decks');
    }
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
        final showFab =
            state.status == DeckDetailStatus.data ||
            state.status == DeckDetailStatus.empty;
        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: showFab
              ? FloatingActionButton(
                  tooltip: 'Create New Card',
                  onPressed: _openNewCard,
                  child: const Icon(Icons.add),
                )
              : null,
          body: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(child: _AmbientGlow()),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailHeader(
                      onBack: _leave,
                      deck: deck,
                      onRename: deck == null ? null : () => _openRename(deck),
                      onDelete: deck == null
                          ? null
                          : () => _confirmDeleteDeck(deck),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.containerMargin,
                        ),
                        child: _DeckDetailBody(
                          state: state,
                          onRetry: notifier.load,
                          onAdd: _openNewCard,
                          onStudy: () =>
                              context.push('/decks/${widget.deckId}/study'),
                          onEditCard: _openEditCard,
                          onDeleteCard: _confirmDeleteCard,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.8,
          colors: [
            AppColors.secondaryContainer.withValues(alpha: 0.08),
            AppColors.background,
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.onBack,
    required this.deck,
    required this.onRename,
    required this.onDelete,
  });

  final VoidCallback onBack;
  final Deck? deck;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        0,
      ),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Voltar',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              ),
            ),
            Text(
              'ANDENKEN',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.secondaryContainer,
                letterSpacing: -0.5,
              ),
            ),
            if (deck != null)
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  tooltip: 'Ações do deck',
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'rename') {
                      onRename?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => const [
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
              ),
          ],
        ),
      ),
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DeckMeta(deck: state.deck, cardCount: 0),
            Expanded(child: _EmptyState(onAdd: onAdd)),
          ],
        );
      case DeckDetailStatus.data:
        return _CardList(
          deck: state.deck,
          cards: state.cards,
          onStudy: onStudy,
          onEdit: onEditCard,
          onDelete: onDeleteCard,
        );
    }
  }
}

class _DeckMeta extends StatelessWidget {
  const _DeckMeta({required this.deck, required this.cardCount});

  final Deck? deck;
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final countLabel = cardCount == 1 ? '1 CARD' : '$cardCount CARDS';
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.stackMd),
      child: Row(
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
                const SizedBox(height: 4),
                AppText(
                  deck?.name ?? 'Deck',
                  variant: AppTextVariant.headlineMd,
                ),
              ],
            ),
          ),
          AppText(
            countLabel,
            variant: AppTextVariant.labelSm,
            color: AppColors.secondaryContainer,
          ),
        ],
      ),
    );
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
    required this.deck,
    required this.cards,
    required this.onStudy,
    required this.onEdit,
    required this.onDelete,
  });

  final Deck? deck;
  final List<domain.Card> cards;
  final VoidCallback onStudy;
  final ValueChanged<domain.Card> onEdit;
  final ValueChanged<domain.Card> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DeckMeta(deck: deck, cardCount: cards.length),
        const SizedBox(height: AppSpacing.stackMd),
        AppButton(
          label: 'Estudar',
          trailingIcon: Icons.play_arrow,
          prominent: true,
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
                onTap: () => onEdit(card),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        card.frontText,
                        variant: AppTextVariant.headlineMd,
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
