import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../common/green_button.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../signup_view.dart';
import 'supplier_sub_type_selector.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toggle Switch
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F2),
            borderRadius: BorderRadius.circular(9999),
          ),
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.setLoginMethod(LoginMethod.email),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: viewModel.loginMethod == LoginMethod.email
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: viewModel.loginMethod == LoginMethod.email
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      'بريد إلكتروني',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: viewModel.loginMethod == LoginMethod.email
                            ? const Color(0xFF002819)
                            : const Color(0xFF717973),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.setLoginMethod(LoginMethod.phone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: viewModel.loginMethod == LoginMethod.phone
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: viewModel.loginMethod == LoginMethod.phone
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      'رقم الهاتف',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: viewModel.loginMethod == LoginMethod.phone
                            ? const Color(0xFF002819)
                            : const Color(0xFF717973),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Supplier sub-type selector — only visible when Supplier role is active
        if (viewModel.selectedRole == UserRole.supplier) ...[
          const SizedBox(height: 24),
          const SupplierSubTypeSelector(),
        ],
        const SizedBox(height: 24),
        // Input Field
        if (viewModel.loginMethod == LoginMethod.phone)
          _buildInputField(
            context: context,
            isPhone: true,
            label: 'رقم الهاتف',
            hintText: '',
            onChanged: viewModel.setPhoneNumber,
            countryCode: viewModel.selectedCountryCode,
            dialCode: viewModel.selectedDialCode,
            onCountryChanged: (code, dialCode) => viewModel.setCountry(code, dialCode),
          )
        else
          _buildInputField(
            context: context,
            isPhone: false,
            label: 'البريد الإلكتروني',
            hintText: 'example@domain.com',
            onChanged: viewModel.setEmail,
            countryCode: '',
            dialCode: '',
            onCountryChanged: (c, d) {},
          ),
        if (viewModel.error != null) ...[
          const SizedBox(height: 8),
          Text(
            viewModel.error!,
            style: GoogleFonts.cairo(
              color: AppColors.statusCancelledText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ],
        const SizedBox(height: 24),
        GreenButton(
          text: 'تسجيل الدخول',
          onPressed: () => viewModel.sendVerificationCode(),
          isLoading: viewModel.isLoading,
          borderRadius: 14,
          leadingIcon: const Icon(
            Icons.login_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            final vm = context.read<LoginViewModel>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SignUpView(
                  role: vm.selectedRole,
                  supplierType: vm.supplierType,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ليس لديك حساب؟',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: const Color(0xFF717973),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'سجّل الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06402B),
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF06402B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required bool isPhone,
    required String label,
    required String hintText,
    required ValueChanged<String> onChanged,
    required String countryCode,
    required String dialCode,
    required Function(String code, String dialCode) onCountryChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF404943),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6E9E7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (isPhone) ...[
                InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      countryListTheme: CountryListThemeData(
                        flagSize: 25,
                        backgroundColor: Colors.white,
                        textStyle: GoogleFonts.cairo(fontSize: 16, color: const Color(0xFF002819)),
                        bottomSheetHeight: 500, // Optional. Country list modal height
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        inputDecoration: InputDecoration(
                          labelText: 'بحث',
                          hintText: 'ابحث عن الدولة',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                      // Filter for Middle East countries (and some North African)
                      countryFilter: <String>['JO'],
                      onSelect: (Country country) {
                        onCountryChanged(country.countryCode, '+${country.phoneCode}');
                      },
                    );
                  },
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          countryCode,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF191C1B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dialCode,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF717973),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF717973), size: 20),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: const Color(0xFFC0C9C1).withValues(alpha: 0.3),
                ),
              ],
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  keyboardType: isPhone ? TextInputType.number : TextInputType.emailAddress,
                  inputFormatters: isPhone 
                      ? [FilteringTextInputFormatter.digitsOnly] 
                      : [],
                  textAlign: isPhone ? TextAlign.right : TextAlign.left,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: isPhone 
                        ? GoogleFonts.cairo(
                            fontSize: 18,
                            color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                            letterSpacing: 1.8,
                          )
                        : GoogleFonts.dmSans(
                            fontSize: 16,
                            color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                          ),
                    prefixIcon: isPhone 
                        ? null 
                        : const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF9099A2),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  style: isPhone 
                      ? GoogleFonts.dmSans(
                          fontSize: 18,
                          color: const Color(0xFF191C1B),
                          letterSpacing: 1.8,
                        )
                      : GoogleFonts.dmSans(
                          fontSize: 16,
                          color: const Color(0xFF191C1B),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
