import 'package:flutter/material.dart';

import 'package:rex_assignment/models/claim.dart';
import 'package:rex_assignment/services/claims_service.dart';

enum SortOption {
  newest,
  oldest,
  amountHigh,
  amountLow,
}

class ClaimsProvider extends ChangeNotifier {
  final ClaimsService service;

  ClaimsProvider(this.service);

  bool isLoading = false;

  String searchQuery = '';

  ClaimStatus? selectedStatus;

  SortOption selectedSort = SortOption.newest;

  List<Claim> _claims = [];

  List<Claim> get claims => _claims;

  Future<void> loadClaims() async {
    isLoading = true;

    notifyListeners();

    _claims = await service.getClaims();

    _sortClaims();

    isLoading = false;

    notifyListeners();
  }

  void _sortClaims() {
    switch (selectedSort) {
      case SortOption.newest:
        _claims.sort(
          (a, b) => b.expenseDate.compareTo(
            a.expenseDate,
          ),
        );
        break;

      case SortOption.oldest:
        _claims.sort(
          (a, b) => a.expenseDate.compareTo(
            b.expenseDate,
          ),
        );
        break;

      case SortOption.amountHigh:
        _claims.sort(
          (a, b) => b.totalAmount.compareTo(
            a.totalAmount,
          ),
        );
        break;

      case SortOption.amountLow:
        _claims.sort(
          (a, b) => a.totalAmount.compareTo(
            b.totalAmount,
          ),
        );
        break;
    }
  }

  List<Claim> get filteredClaims {
    final query = searchQuery.toLowerCase();

    return _claims.where(
      (claim) {
        final searchMatch = claim.claimNumber.toLowerCase().contains(query) ||
            claim.employeeName.toLowerCase().contains(query) ||
            claim.purpose.toLowerCase().contains(query);

        final statusMatch =
            selectedStatus == null || claim.status == selectedStatus;

        return searchMatch && statusMatch;
      },
    ).toList();
  }

  List<Claim> get managerClaims {
    return filteredClaims
        .where(
          (e) => e.status == ClaimStatus.submitted,
        )
        .toList();
  }

  void updateSearch(
    String value,
  ) {
    searchQuery = value;
    notifyListeners();
  }

  void updateStatus(
    ClaimStatus? status,
  ) {
    selectedStatus = status;
    notifyListeners();
  }

  void updateSort(
    SortOption option,
  ) {
    selectedSort = option;
    _sortClaims();
    notifyListeners();
  }

  Future<void> saveClaim(
    Claim claim,
  ) async {
    await service.saveClaim(claim);
    await loadClaims();
  }

  Future<void> deleteClaim(
    String id,
  ) async {
    await service.deleteClaim(id);
    await loadClaims();
  }

  Future<void> submitClaim(
    String id,
  ) async {
    await service.submitClaim(id);
    await loadClaims();
  }

  Future<void> approveClaim(
    String id,
  ) async {
    await service.approveClaim(id);
    await loadClaims();
  }

  Future<void> rejectClaim(
    String id,
    String comments,
  ) async {
    await service.rejectClaim(
      id,
      comments,
    );
    await loadClaims();
  }

  Future<void> moveToDraft(
    String id,
  ) async {
    await service.moveToDraft(id);
    await loadClaims();
  }

  void clearFilters() {
    searchQuery = '';
    selectedStatus = null;
    notifyListeners();
  }

  int get draftCount => _claims
      .where(
        (e) => e.status == ClaimStatus.draft,
      )
      .length;

  int get submittedCount => _claims
      .where(
        (e) => e.status == ClaimStatus.submitted,
      )
      .length;

  int get approvedCount => _claims
      .where(
        (e) => e.status == ClaimStatus.approved,
      )
      .length;

  int get rejectedCount => _claims
      .where(
        (e) => e.status == ClaimStatus.rejected,
      )
      .length;
}
