import '../../../core/utils/arabic_text_utils.dart';
import 'models/dawa_entry.dart';
import 'service/dawa_chatbot_kb.dart';
import 'service/kb_constants.dart';

// Re-export DawaEntry so existing call-sites that import only
// `dawa_chatbot_service.dart` continue to compile unchanged.
export 'models/dawa_entry.dart';

/// Static keyword-based chatbot service for the Dawer (دوّر) platform.
///
///   - [match] scores user input against every entry's keyword list.
///   - [entryById] provides direct lookup for follow-up chip taps.
///   - [matchFromMlLabel] lets Google ML Kit vision results drive responses.
class DawaChatbotService {
  DawaChatbotService._();

  // ──────────────────────────────────────────────
  //  Public API
  // ──────────────────────────────────────────────

  /// Returns the best-matching entry for typed [userInput].
  static DawaEntry match(String userInput) {
    final tokens = _tokenize(userInput);
    if (tokens.isEmpty) return kDawaFallbackEntry;

    DawaEntry best = kDawaFallbackEntry;
    int bestScore = 0;
    for (final entry in kDawaKnowledgeBase) {
      final s = _score(tokens, entry);
      if (s > bestScore) {
        bestScore = s;
        best = entry;
      }
    }

    if (bestScore < kDawaMinConfidence) {
      return _buildContextualFallback(tokens);
    }
    return best;
  }

  /// Look up an entry by its [id]. Returns the fallback entry if not found.
  static DawaEntry entryById(String id) {
    return kDawaKnowledgeBase.firstWhere(
      (e) => e.id == id,
      orElse: () => kDawaFallbackEntry,
    );
  }

  /// The greeting entry shown when the chat first opens.
  static DawaEntry get greeting => entryById('greeting');

  /// Routes ML Kit labels to detailed recycling entries; falls back to keyword
  /// match for less specific labels (plastic, metal, glass…).
  static DawaEntry matchFromMlLabel(String mlLabel) {
    final normalised = mlLabel.toLowerCase().trim();
    if (normalised == 'oil') return entryById('recycle_oil');
    if (normalised == 'wood') return entryById('recycle_wood');
    final byLabel = kDawaKnowledgeBase.where((e) => e.mlLabel == normalised);
    if (byLabel.isNotEmpty) return byLabel.first;
    return match(mlLabel);
  }

  // ──────────────────────────────────────────────
  //  Internal helpers
  // ──────────────────────────────────────────────

  static List<String> _tokenize(String input) {
    return _normalise(input)
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2 && !kDawaStopWords.contains(t))
        .toList();
  }

  static DawaEntry _buildContextualFallback(List<String> tokens) {
    final related = _topMatches(tokens, n: 5, minScore: 1);
    final chipIds = related.isNotEmpty
        ? related.map((e) => e.id).toList()
        : List<String>.from(kDawaMarketplaceFallbackIds);
    return DawaEntry(
      id: 'fallback_contextual',
      keywords: const [],
      response:
          'لم أجد إجابة مباشرة لسؤالك، لكن ربما تقصد أحد هذه المواضيع:\n'
          'اضغط على أي موضوع للحصول على الإجابة الكاملة.',
      followUpIds: chipIds,
    );
  }

  /// Score [tokens] (already normalised) against one [entry].
  ///
  /// Weights:
  ///   • Full multi-word phrase match in input  → 5 × phrase length
  ///   • Exact single token == keyword          → 4
  ///   • Keyword is substring of token (≥3 ch)  → 2
  ///   • Token is substring of keyword (≥3 ch)  → 2
  static int _score(List<String> tokens, DawaEntry entry) {
    if (tokens.isEmpty) return 0;
    int total = 0;
    final inputPhrase = tokens.join(' ');

    for (final kw in entry.keywords) {
      final kwNorm = _normalise(kw);
      if (kwNorm.isEmpty) continue;
      final kwTokens = kwNorm
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .toList();

      if (kwTokens.length > 1 && inputPhrase.contains(kwNorm)) {
        total += kwTokens.length * 5;
        continue;
      }

      for (final tok in tokens) {
        if (tok.length < 2) continue;
        if (tok == kwNorm) {
          total += 4;
        } else if (kwNorm.contains(tok) && tok.length >= 3) {
          total += 2;
        } else if (tok.contains(kwNorm) && kwNorm.length >= 3) {
          total += 2;
        }
      }
    }
    return total;
  }

  /// Returns up to [n] entries with the highest scores, all >= [minScore].
  static List<DawaEntry> _topMatches(
    List<String> tokens, {
    int n = 5,
    int minScore = 1,
  }) {
    final scored = <MapEntry<DawaEntry, int>>[];
    for (final entry in kDawaKnowledgeBase) {
      final s = _score(tokens, entry);
      if (s >= minScore) scored.add(MapEntry(entry, s));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(n).map((e) => e.key).toList();
  }

  /// Normalise Arabic text: strip tashkeel/tatweel, unify alef forms,
  /// taa marbuta → ha, alef maqsoura → ya, lowercase + trim.
  static String _normalise(String input) {
    return ArabicTextUtils.normalize(input)
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
        .toLowerCase()
        .trim();
  }
}
