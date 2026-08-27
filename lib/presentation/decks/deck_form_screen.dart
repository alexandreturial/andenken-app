import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/atoms/app_text_field.dart';
import '../../core/widget/templates/app_page_template.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/usecases/create_deck.dart';
import '../../domain/usecases/rename_deck.dart';
import 'deck_error_message.dart';
import 'deck_form_notifier.dart';

/// Create: frame Stitch "Cadastrar Decks (Clean)"
/// (`.../screens/8e7cffc3332a45648ccb31add5c527b9`) — só o nome do Deck.
/// Frente/verso, tags e preview ficam no Card (T055). Rename reusa o form
/// (spec: ainda sem frame).
class DeckFormScreen extends StatefulWidget {
  const DeckFormScreen({super.key, this.deckId});

  final String? deckId;

  @override
  State<DeckFormScreen> createState() => _DeckFormScreenState();
}

class _DeckFormScreenState extends State<DeckFormScreen> {
  DeckFormNotifier? _notifier;
  final _name = TextEditingController();
  var _filledInitial = false;
  var _didPop = false;

  bool get _isRename => widget.deckId != null;

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
      decks: context.read<DeckRepository>(),
      userId: user.id,
      deckId: widget.deckId,
    );
    if (_isRename) {
      _notifier!.load();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _notifier?.dispose();
    super.dispose();
  }

  Future<void> _submit() => _notifier!.submit(_name.text);

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    if (notifier == null) {
      return const SizedBox.shrink();
    }
    return AppPageTemplate(
      title: _isRename ? 'Renomear deck' : 'Novo deck',
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
          if (!_filledInitial && state.initialName != null) {
            _filledInitial = true;
            _name.text = state.initialName!;
          }
          final loading = state.status == DeckFormStatus.loading;
          return Align(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.stackMd,
                ),
                children: [
                  AppText(
                    _isRename ? 'Rename Deck' : 'Create New Deck',
                    variant: AppTextVariant.headlineLg,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  AppText(
                    _isRename
                        ? 'Update the name of this study set.'
                        : 'Build your own study set.',
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
                    textInputAction: TextInputAction.done,
                    onSubmitted: loading ? null : (_) => _submit(),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: AppSpacing.stackSm),
                    AppText(
                      messageForDeckException(state.error),
                      variant: AppTextVariant.bodyMd,
                      color: AppColors.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.gutter),
                  AppButton(
                    label: _isRename ? 'Save' : 'Save Deck',
                    trailingIcon: Icons.save_outlined,
                    isLoading: loading,
                    onPressed: loading ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
