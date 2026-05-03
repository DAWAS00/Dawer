import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/restaurant_signup_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/ai_shimmer_loader.dart';

class RestaurantStepAiIdentity extends StatelessWidget {
  const RestaurantStepAiIdentity({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantSignupViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Brand Identity & AI',
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Describe your restaurant in one line. Our AI will help craft a compelling story and recommend search categories.',
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: vm.data.tagline,
          onChanged: vm.updateTagline,
          decoration: InputDecoration(
            labelText: 'Describe your restaurant in one line',
            hintText: 'e.g., Authentic Italian pasta made from scratch',
            errorText: vm.errors['tagline'],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: vm.isLoadingAi ? null : vm.generateAiProfileWithRecommendations,
          icon: vm.isLoadingAi
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.auto_awesome),
          label: Text('Generate Profile & Categories'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        if (vm.isLoadingAi) ...[
          const AiShimmerLoader(height: 120),
          const SizedBox(height: 16),
          const AiShimmerLoader(height: 50),
        ] else if (vm.data.aiGeneratedContent != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI-Generated Story (Editable)',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: vm.data.aiGeneratedContent,
                  onChanged: vm.updateAiContent,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (vm.errors.containsKey('aiGeneratedContent'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      vm.errors['aiGeneratedContent']!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recommended Categories',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vm.recommendedCategories.map((category) {
              final isSelected = vm.data.selectedCategories.contains(category);
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => vm.toggleCategory(category),
                selectedColor: Colors.blue.shade100,
              );
            }).toList(),
          ),
          if (vm.errors.containsKey('selectedCategories'))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                vm.errors['selectedCategories']!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ],
    );
  }
}
