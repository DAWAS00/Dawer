import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dwaar/domain/services/i_ai_simulation_service.dart';
import 'package:dwaar/ui/features/auth/views/widgets/document_ai_scan_section.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

DocumentAiScanSection _buildSection({
  required Future<VerificationResult> Function(File) onAnalyze,
  ValueChanged<File?>? onFileChanged,
  Key? key,
}) {
  return DocumentAiScanSection(
    key: key,
    idlePrompt: 'Tap to capture',
    idleHint: 'Make sure it is clear',
    analyzingPhrases: const ['Checking name...', 'Checking ID...'],
    pendingTitle: 'Received',
    pendingSubtitle: 'Under review',
    rejectedTitle: 'Unclear, try again',
    rescanTooltip: 'Rescan',
    retryLabel: 'Retry',
    cameraLabel: 'Camera',
    galleryLabel: 'Gallery',
    onAnalyze: onAnalyze,
    onFileChanged: onFileChanged,
  );
}

void main() {
  group('DocumentAiScanSection', () {
    testWidgets('starts in the idle state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _buildSection(
            onAnalyze: (_) async => const VerificationResult(
              isVerified: true,
              statusMessage: 'signupDocsStatusApproved',
            ),
          ),
        ),
      );

      expect(find.text('Tap to capture'), findsOneWidget);
      expect(find.text('Make sure it is clear'), findsOneWidget);
    });

    testWidgets('shows the analyzing animation while onAnalyze is pending', (
      tester,
    ) async {
      final completer = Completer<VerificationResult>();
      final key = GlobalKey<DocumentAiScanSectionState>();

      await tester.pumpWidget(
        _wrap(_buildSection(key: key, onAnalyze: (_) => completer.future)),
      );

      key.currentState!.debugAnalyze(File('doc.jpg'));
      await tester.pump();
      // Let the AnimatedSwitcher crossfade (300ms) finish so the idle tile
      // is fully gone, not just fading out alongside the analyzing tile.
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Checking name...'), findsOneWidget);
      expect(find.text('Tap to capture'), findsNothing);

      completer.complete(
        const VerificationResult(
          isVerified: true,
          statusMessage: 'signupDocsStatusApproved',
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets(
      'shows the pending badge when the AI check approves the document',
      (tester) async {
        final key = GlobalKey<DocumentAiScanSectionState>();
        File? changedTo;

        await tester.pumpWidget(
          _wrap(
            _buildSection(
              key: key,
              onFileChanged: (f) => changedTo = f,
              onAnalyze: (_) async => const VerificationResult(
                isVerified: true,
                statusMessage: 'signupDocsStatusApproved',
              ),
            ),
          ),
        );

        final file = File('doc.jpg');
        key.currentState!.debugAnalyze(file);
        await tester.pumpAndSettle();

        expect(find.text('Received'), findsOneWidget);
        expect(find.text('Under review'), findsOneWidget);
        expect(changedTo, file);
      },
    );

    testWidgets(
      'shows the pending badge (not a rejection) when the AI check merely '
      'fails to reach a verdict',
      (tester) async {
        final key = GlobalKey<DocumentAiScanSectionState>();

        await tester.pumpWidget(
          _wrap(
            _buildSection(
              key: key,
              onAnalyze: (_) async => const VerificationResult(
                isVerified: false,
                statusMessage: 'signupDocsStatusPending',
              ),
            ),
          ),
        );

        key.currentState!.debugAnalyze(File('doc.jpg'));
        await tester.pumpAndSettle();

        expect(find.text('Received'), findsOneWidget);
        expect(find.text('Unclear, try again'), findsNothing);
      },
    );

    testWidgets(
      'shows the rejected state with a retry action when the AI flags the document',
      (tester) async {
        final key = GlobalKey<DocumentAiScanSectionState>();

        await tester.pumpWidget(
          _wrap(
            _buildSection(
              key: key,
              onAnalyze: (_) async => const VerificationResult(
                isVerified: false,
                statusMessage: 'signupDocsStatusRejected',
              ),
            ),
          ),
        );

        key.currentState!.debugAnalyze(File('doc.jpg'));
        await tester.pumpAndSettle();

        expect(find.text('Unclear, try again'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Received'), findsNothing);
      },
    );

    testWidgets('reset() returns the widget to idle and clears the file', (
      tester,
    ) async {
      final key = GlobalKey<DocumentAiScanSectionState>();
      File? lastChanged = File('placeholder');

      await tester.pumpWidget(
        _wrap(
          _buildSection(
            key: key,
            onFileChanged: (f) => lastChanged = f,
            onAnalyze: (_) async => const VerificationResult(
              isVerified: true,
              statusMessage: 'signupDocsStatusApproved',
            ),
          ),
        ),
      );

      key.currentState!.debugAnalyze(File('doc.jpg'));
      await tester.pumpAndSettle();
      expect(find.text('Received'), findsOneWidget);

      key.currentState!.reset();
      await tester.pumpAndSettle();

      expect(find.text('Tap to capture'), findsOneWidget);
      expect(lastChanged, isNull);
    });
  });
}
