-- Screen 5 document verification: adds the one genuinely-missing column.
-- vehicle_type / has_chemical_permit already exist (20260522_vehicle_type.sql).
-- verification_status enum intentionally deferred — see
-- docs/design/partner-signup-verification-research-plan.md Section 6.1 and
-- the Phase-2 implementation plan; is_verified (boolean, already present)
-- remains the single source of truth until an admin-review dashboard exists
-- to consume a richer state machine.
--
-- No RLS changes needed: profiles_update_own (00001_initial_schema.sql) is a
-- generic owner-scoped policy covering all columns, and the user-documents
-- storage bucket's owner-write policy is folder-prefix-based
-- ({userId}/<filename>), not column/filename-specific — so a new
-- business_license.<ext> object under the same folder is already covered.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS commercial_reg_path TEXT;

COMMENT ON COLUMN public.profiles.commercial_reg_path IS
  'Storage object path (private user-documents bucket) for business license /
   commercial registration, uploaded on Screen 5 for store-business suppliers
   and recycling companies. NULL until submitted.';
