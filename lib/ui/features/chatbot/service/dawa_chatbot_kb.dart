import '../models/dawa_entry.dart';
import 'kb/general_auth_kb.dart';
import 'kb/marketplace_jobs_kb.dart';
import 'kb/marketplace_meta_kb.dart';
import 'kb/marketplace_overview_kb.dart';
import 'kb/ml_kit_kb.dart';
import 'kb/order_pricing_company_kb.dart';
import 'kb/scan_recycle_kb.dart';
import 'kb/supplier_driver_kb.dart';
import 'kb/support_general_kb.dart';

/// All knowledge-base entries for the Dawa chatbot, aggregated from each
/// per-domain partial. Order is preserved to keep `firstWhere` lookups stable.
final List<DawaEntry> kDawaKnowledgeBase = <DawaEntry>[
  ...kGeneralAuthEntries,
  ...kSupplierDriverEntries,
  ...kOrderPricingCompanyEntries,
  ...kMarketplaceOverviewEntries,
  ...kMarketplaceJobsEntries,
  ...kMarketplaceMetaEntries,
  ...kScanRecycleEntries,
  ...kMlKitEntries,
  ...kSupportGeneralEntries,
];
