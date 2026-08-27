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

/// Layout do frame Stitch "Login" (`projects/.../screens/043af8ab37a64a67a4a1f26e064ff3fb`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthNotifier? _notifier;
  final _email = TextEditingController();
  final _password = TextEditingController();

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
    _notifier?.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    return _auth.signIn(email: _email.text, password: _password.text);
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
                        constraints: const BoxConstraints(maxWidth: 384),
                        child: ValueListenableBuilder(
                          valueListenable: _auth,
                          builder: (context, state, _) {
                            final loading = state.status == AuthStatus.loading;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _LoginHeader(),
                                const SizedBox(height: AppSpacing.stackMd),
                                _LoginCard(
                                  email: _email,
                                  password: _password,
                                  loading: loading,
                                  errorText: state.error == null
                                      ? null
                                      : messageForAuthException(state.error!),
                                  onSubmit: loading ? null : _submit,
                                  onGoogle: loading ? null : _google,
                                ),
                                const SizedBox(height: AppSpacing.gutter),
                                const _RegisterHint(),
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
          radius: 0.75,
          colors: [
            AppColors.secondaryContainer.withValues(alpha: 0.08),
            AppColors.background,
          ],
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'ANDENKEN',
          textAlign: TextAlign.center,
          style: AppTypography.headlineLgMobile.copyWith(
            color: AppColors.secondaryContainer,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        const AppText(
          'Welcome Back',
          variant: AppTextVariant.headlineMd,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.email,
    required this.password,
    required this.loading,
    required this.onSubmit,
    required this.onGoogle,
    this.errorText,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool loading;
  final VoidCallback? onSubmit;
  final VoidCallback? onGoogle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
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
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: email,
              label: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              enabled: !loading,
            ),
            const SizedBox(height: AppSpacing.stackSm + 8),
            const _PasswordLabelRow(),
            const SizedBox(height: 4),
            AppTextField(
              controller: password,
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enabled: !loading,
              onSubmitted: (_) => onSubmit?.call(),
            ),
            if (errorText != null) ...[
              const SizedBox(height: AppSpacing.stackSm),
              AppText(
                errorText!,
                variant: AppTextVariant.bodyMd,
                color: AppColors.error,
              ),
            ],
            const SizedBox(height: AppSpacing.gutter),
            AppButton(
              label: 'LOGIN',
              uppercase: true,
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

class _PasswordLabelRow extends StatelessWidget {
  const _PasswordLabelRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              'Password',
              variant: AppTextVariant.labelSm,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          // Reset de senha existe no frame Stitch; fora da v1 (spec).
          AppText(
            'Forgot?',
            variant: AppTextVariant.labelSm,
            color: AppColors.secondaryContainer,
          ),
        ],
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

class _RegisterHint extends StatelessWidget {
  const _RegisterHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.gutter),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const AppText(
            "Don't have an account? ",
            variant: AppTextVariant.bodyMd,
            color: AppColors.onSurfaceVariant,
          ),
          GestureDetector(
            onTap: () => context.go('/register'),
            child: Text(
              'Register',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.secondaryContainer,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondaryContainer.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
