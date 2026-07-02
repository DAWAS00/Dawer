import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/services/proof_builder.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('ProofBuilder.build', () {
    late File tempFile;
    late XFile xFile;

    setUp(() async {
      // Create a small temp file with known bytes.
      tempFile = await File(
        '${Directory.systemTemp.path}/proof_test_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ).create();
      await tempFile.writeAsBytes([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
      ]); // minimal JPEG header
      xFile = XFile(tempFile.path);
    });

    tearDown(() async {
      if (await tempFile.exists()) await tempFile.delete();
    });

    test('returns OrderProof with correct weightKg', () async {
      final proof = await ProofBuilder.build(imageFile: xFile, weightKg: 42.5);
      expect(proof.weightKg, 42.5);
    });

    test('checksum is a 64-char hex SHA256 string', () async {
      final proof = await ProofBuilder.build(imageFile: xFile, weightKg: 1.0);
      expect(proof.checksum.length, 64);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(proof.checksum), isTrue);
    });

    test('checksum is deterministic for same bytes', () async {
      final p1 = await ProofBuilder.build(imageFile: xFile, weightKg: 1.0);
      final p2 = await ProofBuilder.build(imageFile: xFile, weightKg: 1.0);
      expect(p1.checksum, p2.checksum);
    });

    test('checksum differs for different file content', () async {
      final tempFile2 = await File(
        '${Directory.systemTemp.path}/proof_test2_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ).create();
      await tempFile2.writeAsBytes([0x00, 0x01, 0x02, 0x03]);
      final xFile2 = XFile(tempFile2.path);

      final p1 = await ProofBuilder.build(imageFile: xFile, weightKg: 1.0);
      final p2 = await ProofBuilder.build(imageFile: xFile2, weightKg: 1.0);
      expect(p1.checksum, isNot(p2.checksum));

      await tempFile2.delete();
    });

    test('imagePath is set to the file path', () async {
      final proof = await ProofBuilder.build(imageFile: xFile, weightKg: 10.0);
      expect(proof.imagePath, xFile.path);
    });

    test('capturedAt is recent', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 2));
      final proof = await ProofBuilder.build(imageFile: xFile, weightKg: 5.0);
      final after = DateTime.now().add(const Duration(seconds: 2));
      expect(proof.capturedAt.isAfter(before), isTrue);
      expect(proof.capturedAt.isBefore(after), isTrue);
    });
  });

  group('ProofBuilder.upload — auth guard', () {
    test('throws when user is not authenticated', () async {
      // Supabase is not initialised in unit tests, so the call will throw
      // because Supabase.instance is not set up (or auth.currentUser == null).
      final tempFile = await File(
        '${Directory.systemTemp.path}/proof_upload_test_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ).create();
      await tempFile.writeAsBytes([0xFF]);
      final xFile = XFile(tempFile.path);

      expect(
        () => ProofBuilder.upload(
          imageFile: xFile,
          orderId: 'ORD-001',
          proofType: 'pickup',
        ),
        throwsA(anything),
      );

      await tempFile.delete();
    });
  });
}
