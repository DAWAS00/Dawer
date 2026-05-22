part of '../new_pickup_request_view.dart';

extension _ModeSelectorExt on _NewPickupRequestViewState {
  Widget _buildModeSelector() {
    final isMarket = _mode == _OrderMode.marketplace;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMarket
              ? const Color(0xFF1E40AF).withValues(alpha: 0.4)
              : const Color(0xFFE6E9E7),
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Switch.adaptive(
            value: isMarket,
            onChanged: (v) => _updateState(
              () => _mode = v ? _OrderMode.marketplace : _OrderMode.pickup,
            ),
            activeTrackColor: const Color(0xFF1E40AF),
            activeThumbColor: Colors.white,
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'مشاركة في السوق',
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819)),
              ),
              Text(
                'نشر الطلب في السوق للمشترين',
                style: GoogleFonts.cairo(
                    fontSize: 11, color: const Color(0xFF9CA3AF)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.storefront_rounded,
            size: 22,
            color: isMarket
                ? const Color(0xFF1E40AF)
                : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }
}
