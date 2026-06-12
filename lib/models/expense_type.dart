enum ExpenseType {
  travel,
  meals,
  accommodation,
  other,
}

class ExpenseItem {
  String id;
  ExpenseType type;
  String description;
  double amount;
  String? receiptPath;

  ExpenseItem({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    this.receiptPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'amount': amount,
      'receiptPath': receiptPath,
    };
  }

  factory ExpenseItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExpenseItem(
      id: json['id'],
      type: ExpenseType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      receiptPath: json['receiptPath'],
    );
  }
}
