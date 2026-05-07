abstract class MockAiBase {
  static const Duration defaultDelay = Duration(milliseconds: 2500);

  Future<T> simulate<T>(T Function() builder, {Duration? delay}) async {
    await Future.delayed(delay ?? defaultDelay);
    return builder();
  }

  bool isForcedFailure(String path) {
    final lower = path.toLowerCase();
    return lower.contains('fail') || lower.contains('invalid');
  }
}
