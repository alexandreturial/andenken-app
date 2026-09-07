import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_card.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/atoms/app_text_field.dart';
import '../../core/widget/templates/app_page_template.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/usecases/create_card.dart';
import '../../domain/usecases/create_deck.dart';
import '../../domain/usecases/list_cards.dart';
import '../../domain/usecases/rename_deck.dart';
import '../../domain/usecases/update_card.dart';
import '../cards/card_error_message.dart';
import 'deck_form_notifier.dart';

/// Create/edit: frame Stitch "Cadastrar Decks e Cards".
/// Nome obrigatório; tiles de card opcionais (RN-F01). Sem Live Preview,
/// tags, imagens nem bottom nav (DIFF).
class DeckFormScreen extends StatefulWidget {
  const DeckFormScreen({super.key, this.deckId});

  final String? deckId;

  @override
  State<DeckFormScreen> createState() => _DeckFormScreenState();
}

class _DeckFormScreenState extends State<DeckFormScreen> {
  DeckFormNotifier? _notifier;
  final _name = TextEditingController();
  final _drafts = <_DraftFields>[];
  var _filledInitial = false;
  var _didPop = false;

  bool get _isEdit => widget.deckId != null;

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
    _notifier = DeckFormNotifier(
      createDeck: context.read<CreateDeck>(),
      renameDeck: context.read<RenameDeck>(),
      createCard: context.read<CreateCard>(),
      updateCard: context.read<UpdateCard>(),
      listCards: context.read<ListCards>(),
      decks: context.read<DeckRepository>(),
      userId: user.id,
      deckId: widget.deckId,
    );
    if (_isEdit) {
      _notifier!.load();
    } else {
      _drafts.add(_DraftFields());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final draft in _drafts) {
      draft.dispose();
    }
    _notifier?.dispose();
    super.dispose();
  }

  void _addDraft() {
    setState(() => _drafts.add(_DraftFields()));
  }

  void _removeDraft(int index) {
    final draft = _drafts[index];
    if (draft.cardId != null) {
      return;
    }
    setState(() {
      _drafts.removeAt(index).dispose();
    });
  }

  Future<void> _submit() {
    return _notifier!.submit(
      _name.text,
      drafts: [
        for (final draft in _drafts)
          CardDraftInput(
            cardId: draft.cardId,
            frontText: draft.front.text,
            backText: draft.back.text,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    if (notifier == null) {
      return const SizedBox.shrink();
    }
    return AppPageTemplate(
      title: _isEdit ? 'Editar deck' : 'Novo deck',
      body: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, state, _) {
          if (state.status == DeckFormStatus.success && !_didPop) {
            _didPop = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.pop();
              }
            });
          }
          if (!_filledInitial && _isEdit && state.initialName != null) {
            _filledInitial = true;
            _name.text = state.initialName!;
            final cards = state.initialCards;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              setState(() {
                for (final card in cards) {
                  _drafts.add(
                    _DraftFields(
                      cardId: card.cardId,
                      front: TextEditingController(text: card.frontText),
                      back: TextEditingController(text: card.backText),
                    ),
                  );
                }
                if (cards.isEmpty) {
                  _drafts.add(_DraftFields());
                }
              });
            });
          }
          final loading = state.status == DeckFormStatus.loading;
          return Align(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.stackMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  AppText(
                    _isEdit ? 'Edit Deck' : 'Create New Deck',
                    variant: AppTextVariant.headlineLg,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  AppText(
                    _isEdit
                        ? 'Update the name and cards of this study set.'
                        : 'Build your own study set. Cards are optional.',
                    variant: AppTextVariant.bodyMd,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  AppTextField(
                    controller: _name,
                    label: 'Deck Name',
                    hintText: 'e.g., German B1 Verbs',
                    prefixIcon: Icons.folder_open,
                    enabled: !loading,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Row(
                    children: [
                      const Expanded(
                        child: AppText(
                          'Cards',
                          variant: AppTextVariant.headlineMd,
                        ),
                      ),
                      AppText(
                        '${_drafts.length} Cards Added',
                        variant: AppTextVariant.labelSm,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  for (var i = 0; i < _drafts.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.stackMd),
                    _CardDraftTile(
                      index: i,
                      fields: _drafts[i],
                      enabled: !loading,
                      canRemove: _drafts[i].cardId == null,
                      onRemove: () => _removeDraft(i),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.stackMd),
                  _AddAnotherCardButton(onPressed: loading ? null : _addDraft),
                  if (state.error != null) ...[
                    const SizedBox(height: AppSpacing.stackSm),
                    AppText(
                      messageForDetailError(state.error),
                      variant: AppTextVariant.bodyMd,
                      color: AppColors.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.gutter),
                  AppButton(
                    label: _isEdit ? 'Save' : 'Save Deck',
                    trailingIcon: Icons.save_outlined,
                    isLoading: loading,
                    onPressed: loading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
        },
      ),
    );
  }
}

class _DraftFields {
  _DraftFields({
    this.cardId,
    TextEditingController? front,
    TextEditingController? back,
  }) : front = front ?? TextEditingController(),
       back = back ?? TextEditingController();

  final String? cardId;
  final TextEditingController front;
  final TextEditingController back;

  void dispose() {
    front.dispose();
    back.dispose();
  }
}

class _CardDraftTile extends StatelessWidget {
  const _CardDraftTile({
    required this.index,
    required this.fields,
    required this.enabled,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final _DraftFields fields;
  final bool enabled;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  'CARD ${index + 1}',
                  variant: AppTextVariant.labelSm,
                  color: AppColors.gold,
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: 'Remove card',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.primary,
                ),
            ],
          ),
          AppTextField(
            controller: fields.front,
            label: 'FRONT',
            hintText: 'Enter question...',
            enabled: enabled,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.stackMd),
          AppTextField(
            controller: fields.back,
            label: 'BACK',
            hintText: 'Enter answer...',
            enabled: enabled,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

class _AddAnotherCardButton extends StatelessWidget {
  const _AddAnotherCardButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedRoundedPainter(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                AppText(
                  'ADD ANOTHER CARD',
                  variant: AppTextVariant.labelSm,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedPainter extends CustomPainter {
  const _DashedRoundedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 6.0;
    const gap = 4.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppRadius.button),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
