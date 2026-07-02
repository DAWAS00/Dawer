import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/repositories/i_auth_repository.dart';
import '../../../../../l10n/l10n.dart';
import '../../../auth/views/login_view.dart';

/// Shared logout confirmation dialog used by every role profile tab.
///
/// Previously this exact dialog was copy-pasted into the driver, supplier and
/// recycling profile tabs. Centralising it means the sign-out behaviour and
/// copy live in one place.
void showLogoutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        ctx.l10n.logout,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
      ),
      content: Text(
        ctx.l10n.logoutConfirm,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            ctx.l10n.cancel,
            style: GoogleFonts.cairo(color: const Color(0xFF717973)),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final nav = Navigator.of(context);
            await context.read<IAuthRepository>().signOut();
            nav.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginView()),
              (route) => false,
            );
          },
          child: Text(
            ctx.l10n.logoutExit,
            style: GoogleFonts.cairo(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
