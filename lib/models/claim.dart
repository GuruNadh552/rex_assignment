import 'package:rex_assignment/models/expense_type.dart';

enum ClaimStatus {
  draft,
  submitted,
  approved,
  rejected,
}

class Claim {
  String id;
  String claimNumber;
  String employeeName;
  DateTime expenseDate;
  String purpose;
  ClaimStatus status;
  String? rejectionComments;
  List<ExpenseItem> items;

  Claim({
    required this.id,
    required this.claimNumber,
    required this.employeeName,
    required this.expenseDate,
    required this.purpose,
    required this.items,
    this.status = ClaimStatus.draft,
    this.rejectionComments,
  });

  double get totalAmount {
    return items.fold(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  bool get canSubmit =>
      status == ClaimStatus.draft;

  bool get canApprove =>
      status == ClaimStatus.submitted;

  bool get canReject =>
      status == ClaimStatus.submitted;

  bool get canEdit =>
      status == ClaimStatus.draft ||
      status == ClaimStatus.rejected;

  bool get canMoveToDraft =>
      status == ClaimStatus.rejected;

  String? validate() {
    if (employeeName.trim().isEmpty) {
      return 'Employee name is required';
    }

    if (purpose.trim().isEmpty) {
      return 'Purpose is required';
    }

    if (items.isEmpty) {
      return 'At least one expense item is required';
    }

    if (totalAmount > 50000) {
      return 'Claim amount exceeds ₹50,000';
    }

    for (final item in items) {
      if (item.amount <= 0) {
        return 'Amount must be greater than zero';
      }

      if (item.type == ExpenseType.travel &&
          item.description.trim().isEmpty) {
        return 'Travel expenses require description';
      }

      if (item.amount > 5000 &&
          item.receiptPath == null) {
        return 'Receipt required for expenses above ₹5,000';
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claimNumber': claimNumber,
      'employeeName': employeeName,
      'expenseDate': expenseDate.toIso8601String(),
      'purpose': purpose,
      'status': status.name,
      'rejectionComments': rejectionComments,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory Claim.fromJson(
    Map<String, dynamic> json,
  ) {
    return Claim(
      id: json['id'],
      claimNumber: json['claimNumber'],
      employeeName: json['employeeName'],
      expenseDate: DateTime.parse(
        json['expenseDate'],
      ),
      purpose: json['purpose'],
      status: ClaimStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      rejectionComments:
          json['rejectionComments'],
      items: (json['items'] as List)
          .map(
            (e) =>
                ExpenseItem.fromJson(e),
          )
          .toList(),
    );
  }
}