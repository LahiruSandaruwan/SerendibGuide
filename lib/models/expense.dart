/// Expense model for tracking trip spending
class Expense {
  final int? id;
  final String category;
  final double amount;
  final String currency;
  final String description;
  final DateTime date;

  const Expense({
    this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Expense copyWith({
    int? id,
    String? category,
    double? amount,
    String? currency,
    String? description,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
