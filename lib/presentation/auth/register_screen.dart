import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widget/atoms/app_button.dart';
import '../../core/widget/atoms/app_text.dart';
import '../../core/widget/atoms/app_text_field.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_error_message.dart';
import 'auth_notifier.dart';

/// Layout do frame Stitch "Register" (`.../screens/453c95cf3b1a41169af1d71310160012`).
/// Confirmação de senha vem do spec (US-01); Full Name do Stitch não entra (User sem nome).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AuthNotifier? _notifier;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  var _obscurePassword = true;
  var _obscureConfirmation = true;

  AuthNotifier get _auth => _notifier!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier ??= AuthNotifier(
      signIn: context.read<SignIn>(),
      signUp: context.read<SignUp>(),
      signOut: context.read<SignOut>(),
      signInWithGoogle: context.read<SignInWithGoogle>(),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    _notifier?.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    return _auth.signUp(
      email: _email.text,
      password: _password.text,
      passwordConfirmation: _confirmation.text,
    );
  }

  Future<void> _google() => _auth.signInWithGoogle();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: _AmbientGlow())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.gutter),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight - (AppSpacing.gutter * 2),
                    ),
                    child: Align(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: ValueListenableBuilder(
                          valueListenable: _auth,
                          builder: (context, state, _) {
                            final loading = state.status == AuthStatus.loading;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _RegisterHeader(),
                                const SizedBox(height: AppSpacing.stackLg),
                                _RegisterCard(
                                  email: _email,
                                  password: _password,
                                  confirmation: _confirmation,
                                  obscurePassword: _obscurePassword,
                                  obscureConfirmation: _obscureConfirmation,
                                  loading: loading,
                                  errorText: state.error == null
                                      ? null
                                      : messageForAuthException(state.error!),
                                  onTogglePassword: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  onToggleConfirmation: () {
                                    setState(() {
                                      _obscureConfirmation =
                                          !_obscureConfirmation;
                                    });
                                  },
                                  onSubmit: loading ? null : _submit,
                                  onGoogle: loading ? null : _google,
                                ),
                                const SizedBox(height: AppSpacing.stackMd),
                                const _LoginHint(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
          center: Alignment.topCenter,
          radius: 1.1,
          colors: [
            AppColors.surfaceContainerHighest.withValues(alpha: 0.2),
            AppColors.background,
          ],
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 36, color: AppColors.secondaryContainer),
            const SizedBox(width: 8),
            Text(
              'ANDENKEN',
              style: AppTypography.headlineLgMobile.copyWith(
                color: AppColors.secondaryContainer,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackMd),
        const AppText(
          'Create Account',
          variant: AppTextVariant.headlineMd,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const AppText(
          'Begin your mastery journey today.',
          variant: AppTextVariant.bodyMd,
          color: AppColors.onSurfaceVariant,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.email,
    required this.password,
    required this.confirmation,
    required this.obscurePassword,
    required this.obscureConfirmation,
    required this.loading,
    required this.onTogglePassword,
    required this.onToggleConfirmation,
    required this.onSubmit,
    required this.onGoogle,
    this.errorText,
  });

  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirmation;
  final bool obscurePassword;
  final bool obscureConfirmation;
  final bool loading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmation;
  final VoidCallback? onSubmit;
  final VoidCallback? onGoogle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceContainerHighest),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: email,
              label: 'Email Address',
              hintText: 'john@example.com',
              fillColor: AppColors.surfaceContainerLow,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              enabled: !loading,
            ),
            const SizedBox(height: AppSpacing.stackSm),
            AppTextField(
              controller: password,
              label: 'Password',
              hintText: '••••••••',
              fillColor: AppColors.surfaceContainerLow,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !loading,
              suffix: _VisibilityToggle(
                obscure: obscurePassword,
                onPressed: loading ? null : onTogglePassword,
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            AppTextField(
              controller: confirmation,
              label: 'Confirm Password',
              hintText: '••••••••',
              fillColor: AppColors.surfaceContainerLow,
              obscureText: obscureConfirmation,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !loading,
              onSubmitted: (_) => onSubmit?.call(),
              suffix: _VisibilityToggle(
                obscure: obscureConfirmation,
                onPressed: loading ? null : onToggleConfirmation,
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: AppSpacing.stackSm),
              AppText(
                errorText!,
                variant: AppTextVariant.bodyMd,
                color: AppColors.error,
              ),
            ],
            const SizedBox(height: AppSpacing.stackMd),
            AppButton(
              label: 'Register',
              prominent: true,
              trailingIcon: Icons.arrow_forward,
              isLoading: loading,
              onPressed: onSubmit,
            ),
            const SizedBox(height: AppSpacing.stackSm),
            const _OrDivider(),
            const SizedBox(height: AppSpacing.stackSm),
            _GoogleButton(loading: loading, onPressed: onGoogle),
          ],
        ),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscure, required this.onPressed});

  final bool obscure;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.surfaceContainerHighest, height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: AppText(
            'OR',
            variant: AppTextVariant.labelSm,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.surfaceContainerHighest, height: 1),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Continue with Google',
      variant: AppButtonVariant.outlined,
      leading: loading ? null : const _GoogleMark(),
      isLoading: loading,
      onPressed: onPressed,
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleMarkPainter()),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  const _GoogleMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final text = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset((size.width - text.width) / 2, (size.height - text.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginHint extends StatelessWidget {
  const _LoginHint();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const AppText(
          'Already have an account? ',
          variant: AppTextVariant.bodyMd,
          color: AppColors.onSurfaceVariant,
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text(
            'Login',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.secondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
