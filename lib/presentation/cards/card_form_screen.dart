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
import '../../domain/repositories/card_repository.dart';
import '../../domain/usecases/create_card.dart';
import '../../domain/usecases/update_card.dart';
import 'card_error_message.dart';
import 'card_form_notifier.dart';

/// Create: frame Stitch "Cadastrar Múltiplos Cards (Dark)"
/// (`.../screens/d45f7acfb5534b23862c4aaaa277a28d`).
/// Sem Deck Name, Live Preview nem bottom nav (spec). Edit é 1 card.
class CardFormScreen extends StatefulWidget {
  const CardFormScreen({super.key, required this.deckId, this.cardId});

  final String deckId;
  final String? cardId;

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  CardFormNotifier? _notifier;
  final _drafts = <_DraftFields>[];
  var _filledInitial = false;
  var _didPop = false;

  bool get _isEdit => widget.cardId != null;

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
    _notifier = CardFormNotifier(
      createCard: context.read<CreateCard>(),
      updateCard: context.read<UpdateCard>(),
      cards: context.read<CardRepository>(),
      userId: user.id,
      deckId: widget.deckId,
      cardId: widget.cardId,
    );
    if (_isEdit) {
      _drafts.add(_DraftFields());
      _notifier!.load();
    } else {
      _drafts.addAll([_DraftFields(), _DraftFields()]);
    }
  }

  @override
  void dispose() {
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
    if (_drafts.length <= 1) {
      return;
    }
    setState(() {
      _drafts.removeAt(index).dispose();
    });
  }

  Future<void> _submit() {
    final notifier = _notifier!;
    if (_isEdit) {
      return notifier.submit(
        frontText: _drafts.first.front.text,
        backText: _drafts.first.back.text,
      );
    }
    return notifier.submitDrafts([
      for (final draft in _drafts)
        CardDraftInput(frontText: draft.front.text, backText: draft.back.text),
    ]);
  }

  void _discard() {
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
      title: _isEdit ? 'Editar card' : 'Novo Card',
      body: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, state, _) {
          if (state.status == CardFormStatus.success && !_didPop) {
            _didPop = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                _discard();
              }
            });
          }
          if (!_filledInitial &&
              _isEdit &&
              state.initialFront != null &&
              state.initialBack != null) {
            _filledInitial = true;
            _drafts.first.front.text = state.initialFront!;
            _drafts.first.back.text = state.initialBack!;
          }
          final loading = state.status == CardFormStatus.loading;
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
                      _isEdit ? 'Edit Card' : 'Expand Your Knowledge',
                      variant: AppTextVariant.headlineLg,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    AppText(
                      _isEdit
                          ? 'Update the front and back of this card.'
                          : 'Create a new flashcard to strengthen your memory bank. Fill in the details below to add it to your deck.',
                      variant: AppTextVariant.bodyMd,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    if (!_isEdit) ...[
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
                    ],
                    for (var i = 0; i < _drafts.length; i++) ...[
                      _CardDraftTile(
                        index: i,
                        fields: _drafts[i],
                        enabled: !loading,
                        canRemove: !_isEdit && _drafts.length > 1,
                        onRemove: () => _removeDraft(i),
                      ),
                      const SizedBox(height: AppSpacing.stackMd),
                    ],
                    if (!_isEdit) ...[
                      _AddAnotherCardButton(
                        onPressed: loading ? null : _addDraft,
                      ),
                      const SizedBox(height: AppSpacing.stackMd),
                    ],
                    if (state.error != null) ...[
                      AppText(
                        messageForCardException(state.error),
                        variant: AppTextVariant.bodyMd,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                    ],
                    if (!_isEdit)
                      TextButton.icon(
                        onPressed: loading ? null : _discard,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.onSurface,
                        ),
                        label: const Text('Discard Draft'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onSurface,
                        ),
                      ),
                    AppButton(
                      label: _isEdit ? 'Save' : 'Save All Cards',
                      prominent: !_isEdit,
                      leading: _isEdit
                          ? null
                          : const Icon(
                              Icons.add_circle,
                              size: 20,
                              color: AppColors.onSecondaryContainer,
                            ),
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
  _DraftFields();

  final front = TextEditingController();
  final back = TextEditingController();

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
