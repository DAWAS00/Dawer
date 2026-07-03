import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/data/models/signup_request.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/domain/failures/app_failure.dart';
import 'package:dwaar/domain/repositories/i_auth_repository.dart';
import 'package:dwaar/domain/services/i_ai_simulation_service.dart';
import 'package:dwaar/domain/services/i_signup_orchestrator.dart';
import 'package:dwaar/ui/features/auth/controllers/signup_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test double
// ─────────────────────────────────────────────────────────────────────────────

class _FakeSignupOrchestrator implements ISignupOrchestrator {
  AppResult<VerificationResult> nextVerificationResult = const Success(
    VerificationResult(
      isVerified: true,
      statusMessage: 'signupDocsStatusApproved',
    ),
  );
  AppResult<String> nextUploadResult = const Success('user-1/identity.jpg');

  bool? lastIsBusinessDocument;
  int runVerificationCheckCallCount = 0;
  int uploadIdentityDocumentCallCount = 0;
  int uploadBusinessLicenseCallCount = 0;

  @override
  Future<AppResult<AuthSession>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
  }) async => throw UnimplementedError('not exercised in these tests');

  @override
  Future<AppResult<void>> updateProfile(SignUpRequest request) async =>
      throw UnimplementedError('not exercised in these tests');

  @override
  Future<AppResult<String>> uploadIdentityDocument(File document) async {
    uploadIdentityDocumentCallCount++;
    return nextUploadResult;
  }

  @override
  Future<AppResult<String>> uploadBusinessLicense(File document) async {
    uploadBusinessLicenseCallCount++;
    return nextUploadResult;
  }

  @override
  Future<AppResult<VerificationResult>> runVerificationCheck({
    required File document,
    required bool isBusinessDocument,
  }) async {
    runVerificationCheckCallCount++;
    lastIsBusinessDocument = isBusinessDocument;
    return nextVerificationResult;
  }
}

void main() {
  late _FakeSignupOrchestrator orchestrator;
  late SignupController controller;

  setUp(() {
    orchestrator = _FakeSignupOrchestrator();
    controller = SignupController(
      orchestrator: orchestrator,
      phone: '+9627xxxxxxx',
    );
  });

  group('requiresBusinessDocument', () {
    test('is false for a driver', () {
      controller.updateRole(UserRole.driver);
      expect(controller.requiresBusinessDocument, isFalse);
    });

    test('is false for an individual supplier', () {
      controller.updateRole(UserRole.supplier, SupplierType.individual);
      expect(controller.requiresBusinessDocument, isFalse);
    });

    test('is true for a store-business supplier', () {
      controller.updateRole(UserRole.supplier, SupplierType.storeBusiness);
      expect(controller.requiresBusinessDocument, isTrue);
    });

    test('is true for a recycling company', () {
      controller.updateRole(UserRole.recyclingCo);
      expect(controller.requiresBusinessDocument, isTrue);
    });
  });

  group('runDocumentCheck', () {
    test(
      'passes isBusinessDocument through from the role/supplierType',
      () async {
        controller.updateRole(UserRole.recyclingCo);
        await controller.runDocumentCheck(File('license.jpg'));

        expect(orchestrator.runVerificationCheckCallCount, 1);
        expect(orchestrator.lastIsBusinessDocument, isTrue);
      },
    );

    test('stores the verification result and clears isVerifying', () async {
      controller.updateRole(UserRole.driver);
      orchestrator.nextVerificationResult = const Success(
        VerificationResult(
          isVerified: false,
          statusMessage: 'signupDocsStatusRejected',
        ),
      );

      final result = await controller.runDocumentCheck(File('id.jpg'));

      expect(result?.statusMessage, 'signupDocsStatusRejected');
      expect(
        controller.documentVerification?.statusMessage,
        'signupDocsStatusRejected',
      );
      expect(controller.isVerifying, isFalse);
    });

    test('surfaces an orchestrator failure without throwing', () async {
      controller.updateRole(UserRole.driver);
      orchestrator.nextVerificationResult = const Failure(
        AuthFailure(message: 'session expired'),
      );

      final result = await controller.runDocumentCheck(File('id.jpg'));

      expect(result, isNull);
      expect(controller.error, 'session expired');
      expect(controller.isVerifying, isFalse);
    });
  });

  group('submitDocuments (ID upload)', () {
    test('uploads the identity document and marks documentsUploaded', () async {
      controller.updateRole(UserRole.driver);
      controller.identityDocument = File('id.jpg');

      final path = await controller.submitDocuments();

      expect(orchestrator.uploadIdentityDocumentCallCount, 1);
      expect(orchestrator.uploadBusinessLicenseCallCount, 0);
      expect(path, 'user-1/identity.jpg');
      expect(controller.documentsUploaded, isTrue);
    });

    test('returns null and sets an error when no file was captured', () async {
      final path = await controller.submitDocuments();
      expect(path, isNull);
      expect(controller.error, isNotNull);
      expect(orchestrator.uploadIdentityDocumentCallCount, 0);
    });
  });

  group('submitBusinessLicense', () {
    test(
      'uploads the business license and marks businessLicenseUploaded',
      () async {
        controller.updateRole(UserRole.recyclingCo);
        controller.businessLicenseDocument = File('license.jpg');

        final path = await controller.submitBusinessLicense();

        expect(orchestrator.uploadBusinessLicenseCallCount, 1);
        expect(orchestrator.uploadIdentityDocumentCallCount, 0);
        expect(path, 'user-1/identity.jpg');
        expect(controller.businessLicenseUploaded, isTrue);
      },
    );
  });
}
