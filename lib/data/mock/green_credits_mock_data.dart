// lib/data/mock/green_credits_mock_data.dart

import '../models/reward_transaction.dart';

/// Seed خُضَر green-credits balances + transaction history for the four mock
/// test accounts (see devPlans/test-accounts.md). Used so the rewards screens
/// have realistic data to demo without completing live orders.
///
/// Points are seeded into [AppOrderStore] the first time a user is configured
/// (when their persisted balance is still 0). Transaction history is in-memory
/// only — redemptions made during a session append to it but reset on relaunch.
class GreenCreditsMockData {
  GreenCreditsMockData._();

  static const _driverId = '11111111-1111-1111-1111-111111111111';
  static const _supplierIndividualId = '22222222-2222-2222-2222-222222222222';
  static const _supplierStoreId = '33333333-3333-3333-3333-333333333333';
  static const _recyclingCoId = '44444444-4444-4444-4444-444444444444';

  /// Seeded starting balance per user. Chosen to land each user on a
  /// different GreenLevel for visual variety:
  ///   driver           2340 → 🌳 شجرة (tree)
  ///   indiv. supplier   680 → 🌿 غرسة (sapling)
  ///   store supplier   4850 → 🌳 شجرة (tree, near max)
  ///   recycling co     5200 → 🌍 حارس الغابة (forest guardian, max)
  static const Map<String, int> seedPoints = {
    _driverId: 2340,
    _supplierIndividualId: 680,
    _supplierStoreId: 4850,
    _recyclingCoId: 5200,
  };

  /// True if [userId] has seed data available.
  static bool hasSeed(String userId) => seedPoints.containsKey(userId);

  /// Seed balance for [userId], or 0 if none.
  static int pointsFor(String userId) => seedPoints[userId] ?? 0;

  /// Seeded earned-transaction history for [userId].
  static List<RewardTransaction> transactionsFor(String userId) {
    final now = DateTime.now();
    return switch (userId) {
      _driverId => [
        RewardTransaction(
          id: 'gc-drv-1',
          type: RewardTransactionType.earned,
          points: 220,
          description: 'إكمال طلب إلكترونيات · ٣٠ كغ',
          createdAt: now.subtract(const Duration(hours: 5)),
          linkedOrderId: 'DRV-DONE-01',
        ),
        RewardTransaction(
          id: 'gc-drv-2',
          type: RewardTransactionType.bonus,
          points: 150,
          description: 'مكافأة سلسلة ٤ أسابيع',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        RewardTransaction(
          id: 'gc-drv-3',
          type: RewardTransactionType.earned,
          points: 95,
          description: 'إكمال طلب معدن · ٧٠ كغ',
          createdAt: now.subtract(const Duration(days: 4)),
          linkedOrderId: 'DRV-DONE-02',
        ),
      ],
      _supplierIndividualId => [
        RewardTransaction(
          id: 'gc-supi-1',
          type: RewardTransactionType.earned,
          points: 80,
          description: 'تسليم ورق وبلاستيك · ٣٠ كغ',
          createdAt: now.subtract(const Duration(days: 1)),
          linkedOrderId: 'SUP-IND-DONE-01',
        ),
        RewardTransaction(
          id: 'gc-supi-2',
          type: RewardTransactionType.earned,
          points: 140,
          description: 'تسليم زجاج · ٥٥ كغ',
          createdAt: now.subtract(const Duration(days: 5)),
          linkedOrderId: 'SUP-IND-DONE-02',
        ),
      ],
      _supplierStoreId => [
        RewardTransaction(
          id: 'gc-sups-1',
          type: RewardTransactionType.earned,
          points: 180,
          description: 'تسليم زيت طهي مستعمل · ٤٠ كغ',
          createdAt: now.subtract(const Duration(hours: 9)),
        ),
        RewardTransaction(
          id: 'gc-sups-2',
          type: RewardTransactionType.bonus,
          points: 300,
          description: 'مكافأة شريك ذهبي',
          createdAt: now.subtract(const Duration(days: 3)),
        ),
      ],
      _recyclingCoId => [
        RewardTransaction(
          id: 'gc-rec-1',
          type: RewardTransactionType.earned,
          points: 400,
          description: 'استلام شحنة تدوير كبيرة · ٢٠٠ كغ',
          createdAt: now.subtract(const Duration(days: 1)),
          linkedOrderId: 'REC-JOB-DONE-01',
        ),
        RewardTransaction(
          id: 'gc-rec-2',
          type: RewardTransactionType.earned,
          points: 260,
          description: 'استلام معدن وإطارات · ١٢٠ كغ',
          createdAt: now.subtract(const Duration(days: 6)),
        ),
      ],
      _ => const [],
    };
  }
}
