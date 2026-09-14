class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final bool isIncome;
  final String note;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.paymentMethod = 'Credit Card',
    this.isIncome = false,
    this.note = '',
  });

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? paymentMethod,
    bool? isIncome,
    String? note,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isIncome: isIncome ?? this.isIncome,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isIncome': isIncome,
      'note': note,
    };
  }

  factory ExpenseModel.fromMap(Map<dynamic, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      paymentMethod: map['paymentMethod'] as String? ?? 'Credit Card',
      isIncome: map['isIncome'] as bool? ?? false,
      note: map['note'] as String? ?? '',
    );
  }
}
