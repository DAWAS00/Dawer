import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../data/services/gemini_service.dart';

/// Wraps a Gemini ChatSession for the Dawa support chatbot.
/// The session (and therefore conversation history) is kept alive for the
/// lifetime of the DawaChatViewModel and reset when it is disposed.
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

  ChatSession? _session;

  Future<String> sendMessage(String text) async {
    _session ??= GeminiService.instance
        .model(systemInstruction: Content.system(_systemPrompt))
        .startChat();

    final response = await _session!.sendMessage(Content.text(text));
    return response.text?.trim() ??
        'عذراً، لم أتمكن من معالجة طلبك. حاول مرة أخرى.';
  }

  void resetSession() {
    _session = null;
  }
}
