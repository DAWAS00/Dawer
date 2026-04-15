import 'package:flutter/material.dart';
import 'dawa_chatbot_service.dart';

/// Represents a single chat bubble in the Dawa support conversation.
class DawaMessage {
  final String text;
  final bool isUser;
  final List<DawaEntry> followUps;

  /// When non-null, this message was triggered by an ML Kit image result.
  final String? mlSource;

  const DawaMessage({
    required this.text,
    required this.isUser,
    this.followUps = const [],
    this.mlSource,
  });
}

/// Manages the static keyword-based support chat for the Dawer platform.
///
/// Architecture mirrors Faz3a's [SupportChatViewModel]:
///   - On creation: shows the greeting entry with follow-up chips.
///   - [handleUserMessage]: scores text input → adds user bubble → adds bot reply.
///   - [handleFollowUpTap]: quick-select a topic chip → adds both bubbles.
///   - [handleMlResult]: Google ML Kit image label → drives chatbot response.
class DawaChatViewModel extends ChangeNotifier {
  final List<DawaMessage> _messages = [];
  List<DawaMessage> get messages => List.unmodifiable(_messages);

  DawaChatViewModel() {
    final greeting = DawaChatbotService.greeting;
    _addBotMessage(greeting);
  }

  // ──────────────────────────────────────────────
  //  User-typed message
  // ──────────────────────────────────────────────

  /// Called when the user types and submits a text message.
  void handleUserMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _messages.add(DawaMessage(text: trimmed, isUser: true));
    notifyListeners();

    final entry = DawaChatbotService.match(trimmed);
    _addBotMessage(entry);
  }

  // ──────────────────────────────────────────────
  //  Follow-up chip tap
  // ──────────────────────────────────────────────

  /// Called when the user taps a follow-up chip below a bot message.
  void handleFollowUpTap(String entryId) {
    final entry = DawaChatbotService.entryById(entryId);

    // Show the first line of the entry as a user-bubble label.
    _messages.add(DawaMessage(
      text: entry.response.split('\n').first,
      isUser: true,
    ));
    notifyListeners();

    _addBotMessage(entry);
  }

  // ──────────────────────────────────────────────
  //  Google ML Kit integration
  // ──────────────────────────────────────────────

  /// Called when Google ML Kit classifies a waste-type image.
  ///
  /// [mlLabel] is the ML Kit detection label (e.g. 'plastic', 'metal').
  /// [confidencePercent] is the confidence score (0–100).
  ///
  /// Adds a user-side "scanning..." bubble then the bot's ML-driven response.
  void handleMlResult(String mlLabel, {double confidencePercent = 0.0}) {
    final confidenceText = confidencePercent > 0
        ? ' (دقة: ${confidencePercent.toStringAsFixed(0)}%)'
        : '';

    _messages.add(DawaMessage(
      text: '📸 جاري تحليل صورة النفايات...$confidenceText',
      isUser: true,
      mlSource: mlLabel,
    ));
    notifyListeners();

    final entry = DawaChatbotService.matchFromMlLabel(mlLabel);
    _addBotMessage(entry, mlSource: mlLabel);
  }

  // ──────────────────────────────────────────────
  //  Internal
  // ──────────────────────────────────────────────

  void _addBotMessage(DawaEntry entry, {String? mlSource}) {
    final followUps = entry.followUpIds
        .map(DawaChatbotService.entryById)
        .toList();

    _messages.add(DawaMessage(
      text: entry.response,
      isUser: false,
      followUps: followUps,
      mlSource: mlSource,
    ));
    notifyListeners();
  }
}
