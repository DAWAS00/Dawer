import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/repositories/mock_auth_repository.dart';
import 'package:dwaar/domain/chat/entities/chat_message.dart';
import 'package:dwaar/domain/chat/repositories/i_chat_repository.dart';
import 'package:dwaar/domain/repositories/i_auth_repository.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/ui/features/chat/views/chat_view.dart';
import 'package:dwaar/ui/features/chat/widgets/chat_bubble.dart';
import 'package:dwaar/ui/features/chat/widgets/chat_input_bar.dart';

// ── Fake repo ─────────────────────────────────────────────────────────────────

class _FakeChatRepository implements IChatRepository {
  final StreamController<List<ChatMessage>> _ctrl =
      StreamController<List<ChatMessage>>.broadcast();

  final List<ChatMessage> initialMessages;
  final List<String> sentContents = [];

  _FakeChatRepository({this.initialMessages = const []});

  void emitMessages(List<ChatMessage> msgs) => _ctrl.add(msgs);

  @override
  Stream<List<ChatMessage>> watchMessages(String orderId) {
    Future.microtask(() => _ctrl.add(initialMessages));
    return _ctrl.stream;
  }

  @override
  Future<AppResult<void>> sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String content,
  }) async {
    sentContents.add(content);
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markRead(String orderId, String userId) async =>
      const Success(null);

  @override
  Future<AppResult<void>> sendImage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required File image,
    String? caption,
  }) async => const Success(null);

  @override
  Future<AppResult<void>> sendLocation({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required double lat,
    required double lng,
    String? label,
  }) async => const Success(null);

  @override
  Future<int> unreadCount(String orderId, String userId) async => 0;

  @override
  Future<void> broadcastTyping(String orderId, String senderId) async {}

  @override
  Stream<void> watchTyping(String orderId, String excludeUserId) =>
      const Stream.empty();

  void dispose() => _ctrl.close();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

ChatMessage _msg({
  required String id,
  required String senderId,
  String content = 'رسالة اختبار',
  bool isMine = false,
}) =>
    ChatMessage(
      id: id,
      roomId: 'ORD-TEST',
      senderId: senderId,
      senderName: isMine ? 'مستخدم' : 'سائق',
      senderRole: isMine ? UserRole.supplier : UserRole.driver,
      content: content,
      sentAt: DateTime.now(),
    );

Future<void> _pumpChatView(
  WidgetTester tester, {
  required _FakeChatRepository repo,
  String orderId = 'ORD-TEST',
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<IChatRepository>.value(value: repo),
        Provider<IAuthRepository>(create: (_) => MockAuthRepository()),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar'), Locale('en')],
        home: ChatView(orderId: orderId),
      ),
    ),
  );

  // Let stream microtask + locale settle
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ChatView – structure', () {
    testWidgets('renders ChatInputBar', (tester) async {
      final repo = _FakeChatRepository();
      addTearDown(repo.dispose);

      await _pumpChatView(tester, repo: repo);
      expect(find.byType(ChatInputBar), findsOneWidget);
    });

    testWidgets('shows frontend-only amber banner', (tester) async {
      final repo = _FakeChatRepository();
      addTearDown(repo.dispose);

      await _pumpChatView(tester, repo: repo);
      // Banner uses AppColors.amberContainer — we verify its icon is present
      expect(find.byIcon(Icons.construction_rounded), findsOneWidget);
    });

    testWidgets('shows app bar with order ID', (tester) async {
      final repo = _FakeChatRepository();
      addTearDown(repo.dispose);

      await _pumpChatView(tester, repo: repo, orderId: 'ORD-S01');
      expect(find.text('#ORD-S01'), findsOneWidget);
    });
  });

  group('ChatView – empty state', () {
    testWidgets('shows empty state icon when no messages', (tester) async {
      final repo = _FakeChatRepository(initialMessages: []);
      addTearDown(repo.dispose);

      await _pumpChatView(tester, repo: repo);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    });
  });

  group('ChatView – message list', () {
    testWidgets('renders a ChatBubble for each message', (tester) async {
      final msgs = [
        _msg(id: 'm1', senderId: 'other-user'),
        _msg(id: 'm2', senderId: 'mock-user-01', isMine: true),
      ];
      final repo = _FakeChatRepository(initialMessages: msgs);
      addTearDown(repo.dispose);

      await _pumpChatView(tester, repo: repo);
      expect(find.byType(ChatBubble), findsNWidgets(2));
    });

    testWidgets('message content is visible in the bubble', (tester) async {
      final msgs = [_msg(id: 'm1', senderId: 'other', content: 'رسالة مرئية')];
      final repo = _FakeChatRepository(initialMessages: msgs);
      addTearDown(repo.dispose);

      await _pumpChatView(tester, repo: repo);
      expect(find.text('رسالة مرئية'), findsOneWidget);
    });
  });

  group('ChatBubble – alignment', () {
    testWidgets('isMine=true aligns to the left (RTL leading)', (tester) async {
      final msg = _msg(id: 'm1', senderId: 'mock-user-01', isMine: true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(message: msg, isMine: true),
          ),
        ),
      );
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('isMine=false aligns to the right (RTL trailing)', (tester) async {
      final msg = _msg(id: 'm1', senderId: 'other-user');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(message: msg, isMine: false),
          ),
        ),
      );
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });
  });

  group('ChatInputBar – send', () {
    testWidgets('calls onSend with typed text', (tester) async {
      String? captured;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar'), Locale('en')],
          home: Scaffold(
            body: ChatInputBar(onSend: (t) => captured = t),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'مرحباً');
      await tester.pump();

      // Tap send button
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(captured, 'مرحباً');
    });

    testWidgets('input field clears after send', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar'), Locale('en')],
          home: Scaffold(
            body: ChatInputBar(onSend: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'رسالة');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, isEmpty);
    });
  });
}
