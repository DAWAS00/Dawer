/// A single knowledge-base entry the Dawa chatbot can return.
class DawaEntry {
  final String id;
  final List<String> keywords;
  final String response;
  final List<String> followUpIds;

  /// Optional ML Kit metadata — if this entry was triggered by an image
  /// analysis result, this field carries the detected label (e.g. 'plastic').
  final String? mlLabel;

  const DawaEntry({
    required this.id,
    required this.keywords,
    required this.response,
    this.followUpIds = const [],
    this.mlLabel,
  });
}
