import 'dart:io';

import '../../core/result/result.dart';
import '../../data/models/signup_request.dart';
import '../repositories/i_auth_repository.dart';
import 'i_ai_simulation_service.dart' show VerificationResult;

/// Orchestrates the multi-step signup flow: creating the account, uploading
/// media, and writing the uploaded URLs/paths back to the profile row.
///
/// This is the single place that fixes the historical "uploaded but never
/// persisted" bug — [signUp] inserts the profile row AND writes the photo/doc
/// URLs back in one coordinated operation. See `docs/signup-redesign-plan.md`.
abstract interface class ISignupOrchestrator {
  /// Creates the account (profile row) + uploads the profile photo (if any).
  ///
  /// Inserts a minimum-viable `profiles` row via [IAuthRepository.signUp], then
  /// uploads [profilePhoto] (when present) and writes the returned public URL
  /// back to `profiles.profile_photo_url`. Returns the authenticated session.
  Future<AppResult<AuthSession>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
  });

  /// Progressively updates the profile row with role-specific details (vehicle
  /// info, address/location, categories). Called from Screen 4 after the user
  /// is already in the app. No-op fields are skipped.
  Future<AppResult<void>> updateProfile(SignUpRequest request);

  /// Uploads an identity document (ID/license) to private storage and writes
  /// the returned object path back to `profiles.identity_doc_path`. Called from
  /// Screen 5 (documents). Sets `is_verified = false` (pending review).
  Future<AppResult<String>> uploadIdentityDocument(File document);

  /// Uploads a business license / commercial registration document to
  /// private storage and writes the returned object path back to
  /// `profiles.commercial_reg_path`. Called from Screen 5 for store-business
  /// suppliers and recycling companies. Does NOT touch `is_verified` — the
  /// AI check is a separate step ([runVerificationCheck]).
  Future<AppResult<String>> uploadBusinessLicense(File document);

  /// Runs the AI verification check against [document] and writes the
  /// result to `profiles.is_verified`. [isBusinessDocument] selects the
  /// identity-doc vs. business-license prompt.
  ///
  /// Never returns [Failure] — an AI-side error (network, parse) resolves to
  /// a [VerificationResult] with `isVerified: false` (pending review), never
  /// blocking Screen 5's continue/skip path and never silently auto-approving.
  /// The returned [VerificationResult.statusMessage] is what lets Screen 5
  /// distinguish an AI-flagged rejection (show "needs retake") from a
  /// technical hiccup or an AI pass still awaiting human review (both show
  /// as "pending").
  Future<AppResult<VerificationResult>> runVerificationCheck({
    required File document,
    required bool isBusinessDocument,
  });
}
