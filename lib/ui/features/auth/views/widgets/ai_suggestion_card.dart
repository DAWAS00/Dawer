import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiSuggestionCard extends StatelessWidget {
  final bool isLoading;
  final String? marketplaceLookupPrompt;
  final String? appDiscoverySuggestion;

  const AiSuggestionCard({
    super.key,
    this.isLoading = false,
    this.marketplaceLookupPrompt,
    this.appDiscoverySuggestion,
  });

  @override
  Widget build(BuildContext context) {
    if (marketplaceLookupPrompt == null && appDiscoverySuggestion == null && !isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Light green tint
        border: Border.all(color: const Color(0xFF86EFAC)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'AI Suggestions',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: Color(0xFF166534),
                ),
              ),
            )
          else ...[
            if (marketplaceLookupPrompt != null) ...[
              Text(
                marketplaceLookupPrompt!,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF14532D),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (appDiscoverySuggestion != null) ...[
              Text(
                appDiscoverySuggestion!,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF14532D),
                  height: 1.5,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
