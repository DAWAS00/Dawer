import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/verification_viewmodel.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../../home/home_router.dart';

class VerificationView extends StatelessWidget {
  final String destination;
  final bool isEmail;
  final UserRole role;
  final SupplierType supplierType;
  final String userName;

  const VerificationView({
    super.key,
    required this.destination,
    required this.isEmail,
    this.role = UserRole.driver,
    this.supplierType = SupplierType.individual,
    this.userName = '',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerificationViewModel(
        destination: destination,
        isEmail: isEmail,
      ),
      child: _VerificationScreen(
        destination: destination,
        isEmail: isEmail,
        role: role,
        supplierType: supplierType,
        userName: userName,
      ),
    );
  }
}

class _VerificationScreen extends StatefulWidget {
  final String destination;
  final bool isEmail;
  final UserRole role;
  final SupplierType supplierType;
  final String userName;

  const _VerificationScreen({
    required this.destination,
    required this.isEmail,
    required this.role,
    required this.supplierType,
    required this.userName,
  });

  @override
  State<_VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<_VerificationScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = [];
    for (int i = 0; i < 6; i++) {
      final int idx = i;
      _focusNodes.add(
        FocusNode(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                _controllers[idx].text.isEmpty &&
                idx > 0) {
              _controllers[idx - 1].clear();
              context.read<VerificationViewModel>().setDigit(idx - 1, '');
              _focusNodes[idx - 1].requestFocus();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
        ),
      );
      _focusNodes[i].addListener(_onFocusChange); // ignore: curly_braces_in_flow_control_structures
    }
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.removeListener(_onFocusChange);
      f.dispose();
    }
    super.dispose();
  }

  void _handleDigitChanged(int index, String value, VerificationViewModel vm) {
    if (value.isNotEmpty) {
      vm.setDigit(index, value);
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      vm.setDigit(index, '');
    }
  }

  void _clearAll() {
    for (int i = 0; i < 6; i++) {
      _controllers[i].clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VerificationViewModel>();

    if (viewModel.verified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeRouter(
              role: widget.role,
              supplierType: widget.supplierType,
              userName: widget.userName.isNotEmpty
                  ? widget.userName
                  : widget.destination,
            ),
          ),
          (route) => false,
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          children: [
            _buildHero(),
            const SizedBox(height: 40),
            _buildOTPCard(context, viewModel),
            const SizedBox(height: 24),
            _buildSecurityCard(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF06402B).withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Color(0xFF06402B),
            ),
          ),
        ),
      ),
      title: Text(
        context.l10n.verificationTitle,
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF06402B),
          letterSpacing: -0.45,
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFC3EAC4),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          child: Icon(
            widget.isEmail ? Icons.email_outlined : Icons.phone_android_rounded,
            size: 28,
            color: const Color(0xFF06402B),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.destination,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF002819),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.verificationCodeSent,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: const Color(0xFF717973),
            letterSpacing: 0.35,
          ),
        ),
      ],
    );
  }

  Widget _buildOTPCard(
    BuildContext context,
    VerificationViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label row
          Text(
            context.l10n.verificationEnterCode,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 28),

          // 6 OTP boxes
          Row(
            children: List.generate(6, (i) {
              final isFocused = _focusNodes[i].hasFocus;
              return Expanded(
                child: Container(
                  height: 52,
                  margin: EdgeInsets.only(left: i < 5 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isFocused ? Colors.white : const Color(0xFFE1E3E1),
                    borderRadius: BorderRadius.circular(12),
                    border: isFocused
                        ? Border.all(
                            color: const Color(0xFF06402B),
                            width: 2,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) =>
                        _handleDigitChanged(i, v, viewModel),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),

          // Timer / Resend row
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: viewModel.canResend
                      ? const Color(0xFF06402B)
                      : const Color(0xFF717973),
                ),
                const SizedBox(width: 8),
                if (!viewModel.canResend) ...[
                  Text(
                    context.l10n.verificationResendAfter,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF717973),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    viewModel.timerDisplay,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                ] else
                  GestureDetector(
                    onTap: () {
                      viewModel.resendCode();
                      _clearAll();
                    },
                    child: Text(
                      context.l10n.verificationResend,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF06402B),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF06402B),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Error
          if (viewModel.error != null) ...[
            const SizedBox(height: 12),
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 28),

          // Verify button
          GreenButton(
            text: context.l10n.verificationButton,
            onPressed: () => context.read<VerificationViewModel>().verify(),
            isLoading: viewModel.isLoading,
            height: 58,
            borderRadius: 16,
            trailingIcon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD4EBAB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.l10n.verificationSecureTitle,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF182700),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.verificationSecureSubtitle,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF182700).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.security_rounded,
              color: Color(0xFF06402B),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 12,
                    color: Color(0xFF191C1B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.verificationSecureFooter,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF191C1B),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF002819),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
