import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  void _showPolicySheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        'هذا النص هو نص تجريبي يوضح الشروط والأحكام وسياسة الخصوصية الخاصة بالتطبيق. سيتم تحديث هذا النص لاحقاً ليعكس السياسات الحقيقية والقانونية المعتمدة.\n\n'
                        '• يلتزم المستخدم بجميع القوانين والأنظمة المعمول بها.\n'
                        '• يحق للتطبيق الاحتفاظ ببعض البيانات الأساسية لتحسين الخدمة المقدمة.\n'
                        '• نحتفظ بالحق في تعديل هذه الشروط في أي وقت مع إشعار المستخدمين.\n'
                        '• خصوصية بياناتك تهمنا، ولن نقوم بمشاركتها مع أطراف ثالثة دون موافقتك الصريحة.\n'
                        '• باستخدامك لهذا التطبيق، فإنك توافق على جميع الشروط والأحكام المذكورة هنا.\n\n' * 3,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          height: 1.8,
                          color: const Color(0xFF404943),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06402B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'حسناً، فهمت',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showPolicySheet(context, 'شروط الخدمة'),
                child: Text(
                  'شروط الخدمة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A6496),
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF2A6496),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '|',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: const Color(0xFF9099A2),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showPolicySheet(context, 'سياسة الخصوصية'),
                child: Text(
                  'سياسة الخصوصية',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A6496),
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF2A6496),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'DIGITAL INFRASTRUCTURE BY GOVERNMENT',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9099A2),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'فكرة من عقول الشباب الأردني',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9099A2),
            ),
          ),
        ],
      ),
    );
  }
}
