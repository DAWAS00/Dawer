import '../models/dawa_entry.dart';

/// Minimum score required to accept an entry as a confident answer.
const int kDawaMinConfidence = 3;

/// Common Arabic + English words that carry no domain meaning.
const Set<String> kDawaStopWords = {
  'في', 'من', 'على', 'عن', 'إلى', 'الى', 'ان', 'أن',
  'هل', 'كيف', 'ما', 'ماذا', 'لماذا', 'متى',
  'هذا', 'هذه', 'ذلك', 'تلك', 'هو', 'هي', 'هم',
  'و', 'أو', 'او', 'لكن', 'لا', 'لم', 'لن', 'قد',
  'يمكن', 'اريد', 'أريد', 'ابغى', 'ابي', 'أبي',
  'the', 'a', 'an', 'is', 'in', 'on', 'at', 'to',
  'of', 'for', 'and', 'or', 'how', 'what', 'where',
};

/// Default chips shown when the bot has no confident match.
/// Deliberately marketplace-first so the chatbot steers users
/// toward the core marketplace workflow.
const List<String> kDawaMarketplaceFallbackIds = [
  'marketplace',
  'market_listings',
  'market_collection_jobs',
  'market_roles',
  'market_search',
];

/// Final fallback when scoring yields nothing and there are no related entries.
const DawaEntry kDawaFallbackEntry = DawaEntry(
  id: 'fallback',
  keywords: [],
  response:
      'عذراً، لم أستطع فهم سؤالك.\n'
      'إليك أبرز مواضيع السوق — اضغط لتصفح أي منها:',
  followUpIds: [
    'marketplace',
    'market_listings',
    'market_collection_jobs',
    'market_accept_job',
    'market_search',
  ],
);
