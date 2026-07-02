import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../data/services/mock_ai_service.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../common/green_button.dart';

// ════════════════════════════════════════════════════════════════════════════════
// Shared onboarding widgets — used by all single-page sign-up flows:
//   RecyclingCoOnboardingView, IndividualSupplierOnboardingView, StoreOnboardingView
// ════════════════════════════════════════════════════════════════════════════════

// ── OnboardingHeaderBanner ────────────────────────────────────────────────────

class OnboardingHeaderBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const OnboardingHeaderBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            Color.lerp(accentColor, Colors.black, 0.14)!,
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 3),
                Text(subtitle,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── OnboardingSectionCard ─────────────────────────────────────────────────────

class OnboardingSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final bool accentIcon;
  final Widget child;

  const OnboardingSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
    this.accentIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        accentIcon ? const Color(0xFF7C3AED) : const Color(0xFF06402B);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF002819))),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: const Color(0xFF717973))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── OnboardingInputField ──────────────────────────────────────────────────────

class OnboardingInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? error;
  final bool isRequired;
  final TextInputType keyboardType;
  final TextDirection? textDirection;
  final ValueChanged<String> onChanged;

  const OnboardingInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.error,
    this.isRequired = true,
    this.keyboardType = TextInputType.text,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF404943))),
            if (isRequired)
              const Text(' *',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color:
                error != null ? Colors.red.shade50 : const Color(0xFFE6E9E7),
            borderRadius: BorderRadius.circular(10),
            border: error != null
                ? Border.all(color: Colors.red.shade300)
                : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: textDirection == TextDirection.ltr
                ? TextAlign.left
                : TextAlign.start,
            textDirection: textDirection,
            onChanged: onChanged,
            style: GoogleFonts.cairo(
                fontSize: 14, color: const Color(0xFF191C1B)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 3),
          Text(error!,
              textAlign: TextAlign.start,
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}

// ── OnboardingPasswordField ───────────────────────────────────────────────────

class OnboardingPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? error;
  final ValueChanged<String> onChanged;

  const OnboardingPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.error,
  });

  @override
  State<OnboardingPasswordField> createState() =>
      _OnboardingPasswordFieldState();
}

class _OnboardingPasswordFieldState extends State<OnboardingPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(widget.label,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF404943))),
            const Text(' *',
                style: TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: widget.error != null
                ? Colors.red.shade50
                : const Color(0xFFE6E9E7),
            borderRadius: BorderRadius.circular(10),
            border: widget.error != null
                ? Border.all(color: Colors.red.shade300)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscure,
                  textAlign: TextAlign.start,
                  onChanged: widget.onChanged,
                  style: GoogleFonts.cairo(
                      fontSize: 14, color: const Color(0xFF191C1B)),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 3),
          Text(widget.error!,
              textAlign: TextAlign.start,
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}

// ── OnboardingLocationTile ────────────────────────────────────────────────────

class OnboardingLocationTile extends StatelessWidget {
  final double? lat;
  final double? lng;
  const OnboardingLocationTile({super.key, this.lat, this.lng});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasCoords = lat != null && lng != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasCoords
            ? const Color(0xFF06402B).withValues(alpha: 0.06)
            : const Color(0xFFE6E9E7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasCoords
              ? const Color(0xFF06402B).withValues(alpha: 0.4)
              : const Color(0xFFC0C9C1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasCoords
                  ? Icons.location_on_rounded
                  : Icons.add_location_alt_rounded,
              size: 18,
              color: const Color(0xFF06402B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCoords
                      ? '${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}'
                      : l10n.signupLocationSelectPrompt,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: hasCoords
                          ? const Color(0xFF06402B)
                          : const Color(0xFF404943)),
                ),
                Text(l10n.signupLocationOpenMap,
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: const Color(0xFF717973))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasCoords ? l10n.signupLocationChange : l10n.signupLocationSelect,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF06402B)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OnboardingShimmerBox ──────────────────────────────────────────────────────

class OnboardingShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  const OnboardingShimmerBox(
      {super.key, required this.width, required this.height});

  @override
  State<OnboardingShimmerBox> createState() => _OnboardingShimmerBoxState();
}

class _OnboardingShimmerBoxState extends State<OnboardingShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.grey.shade300.withValues(alpha: _anim.value),
        ),
      ),
    );
  }
}

// ── OnboardingCategoriesSection ───────────────────────────────────────────────

class OnboardingCategoriesSection extends StatelessWidget {
  final List<String> categories;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const OnboardingCategoriesSection({
    super.key,
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              l10n.onboardingCategoriesSuggested,
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819)),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.onboardingCategoriesSelected(selected.length),
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: const Color(0xFF06402B),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          l10n.onboardingCategoriesNote,
          textAlign: TextAlign.start,
          style: GoogleFonts.cairo(
              fontSize: 11, color: const Color(0xFF717973)),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E9E7)),
          ),
          child: Column(
            children: List.generate(categories.length, (i) {
              final cat = categories[i];
              final isSelected = selected.contains(cat);
              final isLast = i == categories.length - 1;
              return Column(
                children: [
                  InkWell(
                    onTap: () => onToggle(cat),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => onToggle(cat),
                            activeColor: const Color(0xFF06402B),
                            side: const BorderSide(
                                color: Color(0xFFC0C9C1), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF002819)
                                    : const Color(0xFF404943),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        indent: 14,
                        endIndent: 14,
                        color: Color(0xFFEEF1EE)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── OnboardingHighlightsSection ───────────────────────────────────────────────

class OnboardingHighlightsSection extends StatelessWidget {
  final List<String> highlights;
  const OnboardingHighlightsSection({super.key, required this.highlights});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.onboardingHighlightsTitle,
          style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819)),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.onboardingHighlightsSubtitle,
          textAlign: TextAlign.start,
          style: GoogleFonts.cairo(
              fontSize: 11, color: const Color(0xFF717973)),
        ),
        const SizedBox(height: 10),
        ...List.generate(highlights.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF06402B)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    highlights[i],
                    textAlign: TextAlign.start,
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: const Color(0xFF191C1B)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── OnboardingAiSuggestionsPanel ──────────────────────────────────────────────

class OnboardingAiSuggestionsPanel extends StatelessWidget {
  final TextEditingController taglineCtrl;
  final bool isAiLoading;
  final BrandProfile? brandProfile;
  final List<String> allCategories;
  final Set<String> selectedCategories;
  final ValueChanged<String> onTaglineChanged;
  final VoidCallback? onGenerate;
  final ValueChanged<String> onToggleCategory;

  const OnboardingAiSuggestionsPanel({
    super.key,
    required this.taglineCtrl,
    required this.isAiLoading,
    required this.brandProfile,
    required this.allCategories,
    required this.selectedCategories,
    required this.onTaglineChanged,
    required this.onToggleCategory,
    this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingSectionCard(
      title: l10n.onboardingAiPanelTitle,
      icon: Icons.auto_awesome_rounded,
      subtitle: l10n.onboardingAiPanelSubtitle,
      accentIcon: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.18)),
            ),
            child: Text(
              l10n.onboardingAiPanelContext,
              textAlign: TextAlign.start,
              style: GoogleFonts.cairo(
                  fontSize: 12, color: const Color(0xFF5B21B6)),
            ),
          ),
          const SizedBox(height: 14),

          // Tagline
          OnboardingInputField(
            controller: taglineCtrl,
            label: l10n.onboardingTaglineLabel,
            hint: l10n.onboardingTaglineHint,
            isRequired: false,
            onChanged: onTaglineChanged,
          ),
          const SizedBox(height: 14),

          // Generate button
          GreenButton(
            text: isAiLoading ? l10n.onboardingAiGenerating : l10n.onboardingAiGenerateButton,
            height: 50,
            borderRadius: 12,
            isLoading: isAiLoading,
            leadingIcon: isAiLoading
                ? null
                : const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 16),
            onPressed: onGenerate,
          ),

          // Shimmer loading
          if (isAiLoading) ...[
            const SizedBox(height: 16),
            const OnboardingShimmerBox(width: double.infinity, height: 13),
            const SizedBox(height: 7),
            const OnboardingShimmerBox(width: double.infinity, height: 13),
            const SizedBox(height: 7),
            const OnboardingShimmerBox(width: 180, height: 13),
            const SizedBox(height: 12),
            const OnboardingShimmerBox(width: double.infinity, height: 13),
            const SizedBox(height: 7),
            const OnboardingShimmerBox(width: 220, height: 13),
          ],

          // Results
          if (brandProfile != null && !isAiLoading) ...[
            const SizedBox(height: 20),
            OnboardingCategoriesSection(
              categories: allCategories,
              selected: selectedCategories,
              onToggle: onToggleCategory,
            ),
            const SizedBox(height: 20),
            OnboardingHighlightsSection(
                highlights: brandProfile!.companyHighlights),
          ],
        ],
      ),
    );
  }
}
