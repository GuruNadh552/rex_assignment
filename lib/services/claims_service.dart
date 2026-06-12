import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/claim.dart';
import '../utils/constants.dart';

abstract class ClaimsService {
  Future<List<Claim>> getClaims();

  Future<Claim?> getClaimById(
    String id,
  );

  Future<void> saveClaim(
    Claim claim,
  );

  Future<void> deleteClaim(
    String id,
  );

  Future<void> submitClaim(
    String id,
  );

  Future<void> approveClaim(
    String id,
  );

  Future<void> rejectClaim(
    String id,
    String comments,
  );

  Future<void> moveToDraft(
    String id,
  );
}

class LocalClaimsService
    implements ClaimsService {

  Future<List<Claim>> _loadClaims() async {
    final prefs =
        await SharedPreferences.getInstance();

    final jsonString =
        prefs.getString(
      Constants.storageKey,
    );

    if (jsonString == null) {
      return [];
    }

    final List decoded =
        jsonDecode(jsonString);

    return decoded
        .map(
          (e) => Claim.fromJson(e),
        )
        .toList();
  }

  Future<void> _saveClaims(
    List<Claim> claims,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      Constants.storageKey,
      jsonEncode(
        claims
            .map(
              (e) => e.toJson(),
            )
            .toList(),
      ),
    );
  }

  @override
  Future<List<Claim>> getClaims() async {
    return _loadClaims();
  }

  @override
  Future<Claim?> getClaimById(
    String id,
  ) async {
    final claims =
        await _loadClaims();

    try {
      return claims.firstWhere(
        (e) => e.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveClaim(
    Claim claim,
  ) async {
    final claims =
        await _loadClaims();

    final index =
        claims.indexWhere(
      (e) => e.id == claim.id,
    );

    if (index == -1) {
      claims.add(claim);
    } else {
      claims[index] = claim;
    }

    await _saveClaims(claims);
  }

  @override
  Future<void> deleteClaim(
    String id,
  ) async {
    final claims =
        await _loadClaims();

    claims.removeWhere(
      (e) => e.id == id,
    );

    await _saveClaims(claims);
  }

  @override
  Future<void> submitClaim(
    String id,
  ) async {
    final claims =
        await _loadClaims();

    final claim =
        claims.firstWhere(
      (e) => e.id == id,
    );

    if (!claim.canSubmit) {
      return;
    }

    claim.status =
        ClaimStatus.submitted;

    await _saveClaims(claims);
  }

  @override
  Future<void> approveClaim(
    String id,
  ) async {
    final claims =
        await _loadClaims();

    final claim =
        claims.firstWhere(
      (e) => e.id == id,
    );

    if (!claim.canApprove) {
      return;
    }

    claim.status =
        ClaimStatus.approved;

    await _saveClaims(claims);
  }

  @override
  Future<void> rejectClaim(
    String id,
    String comments,
  ) async {
    final claims =
        await _loadClaims();

    final claim =
        claims.firstWhere(
      (e) => e.id == id,
    );

    if (!claim.canReject) {
      return;
    }

    claim.status =
        ClaimStatus.rejected;

    claim.rejectionComments =
        comments;

    await _saveClaims(claims);
  }

  @override
  Future<void> moveToDraft(
    String id,
  ) async {
    final claims =
        await _loadClaims();

    final claim =
        claims.firstWhere(
      (e) => e.id == id,
    );

    if (!claim.canMoveToDraft) {
      return;
    }

    claim.status =
        ClaimStatus.draft;

    await _saveClaims(claims);
  }
}