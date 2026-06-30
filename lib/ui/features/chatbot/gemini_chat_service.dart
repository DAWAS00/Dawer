import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../data/services/gemini_service.dart';

/// Wraps a Gemini ChatSession for the Dawa support chatbot.
/// The session accumulates conversation history for the process lifetime
/// and can be explicitly reset via [resetSession].
class GeminiChatService {
  GeminiChatService._();
  static final GeminiChatService instance = GeminiChatService._();

  static const _systemPrompt =
      'أنت "داوة" — مساعد ذكي مدمج في تطبيق "دوّر" لتدوير النفايات في الأردن.\n\n'
      'معلومات عن المنصة:\n'
      '- دوّر تربط ثلاثة أطراف: الموردون (أفراد/متاجر/مطاعم يريدون التخلص '
      'من النفايات القابلة للتدوير)، السائقون (يستلمون الطلبات وينقلون النفايات)، '
      'وشركات التدوير (تنشر وظائف تجميع وتشتري المواد).\n'
      '- أنواع النفايات: ورق وكرتون، بلاستيك، معادن، زجاج، إلكترونيات، عضوي، '
      'نسيج، خشب، مطاط، زيوت، بطاريات، أثاث، إطارات، مواد بناء.\n'
      '- الميزات الرئيسية: طلبات الاستلام، وظائف التجميع، السوق (marketplace)، '
      'المكافآت والأرباح، تتبع السائق مباشرة.\n'
      '- المنصة تعمل في الأردن وتدعم العربية والإنجليزية.\n\n'
      'قواعد:\n'
      '- رد دائماً بالعربية بصرف النظر عن لغة السؤال.\n'
      '- كن مختصراً ومفيداً (جملتان إلى ثلاث في الغالب).\n'
      '- إذا لم يكن السؤال متعلقاً بدوّر أو التدوير، وجّه المستخدم بلطف.\n'
      '- لا تخترع أسعاراً أو معلومات تقنية غير مذكورة أعلاه.';

  // Cached once — the system instruction never changes between sessions.
  static final _systemContent = Content.system(_systemPrompt);

  GenerativeModel? _model;
  ChatSession? _session;

  static const _timeout = Duration(seconds: 30);

  Future<String> sendMessage(String text) async {
    if (!GeminiService.instance.isInitialized) {
      throw StateError('Gemini AI not available');
    }
    _model ??= GeminiService.instance.model(systemInstruction: _systemContent);
    _session ??= _model!.startChat();

    try {
      final response = await _session!
          .sendMessage(Content.text(text))
          .timeout(_timeout);
      return response.text?.trim() ??
          'عذراً، لم أتمكن من معالجة طلبك. حاول مرة أخرى.';
    } on TimeoutException {
      return 'استغرق الرد وقتاً طويلاً. يرجى المحاولة مرة أخرى.';
    }
  }

  /// Clears accumulated conversation history. Call only when the user
  /// explicitly starts a new conversation.
  void resetSession() {
    _session = null;
    debugPrint('[GeminiChatService] Session reset.');
  }
}
