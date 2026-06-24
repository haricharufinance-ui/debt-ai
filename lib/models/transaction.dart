enum TxnDirection { debit, credit, unknown }

class TransactionRecord {
  final String id;
  final String merchantRaw; // as extracted from the SMS
  final double amount;
  final TxnDirection direction;
  final String source; // e.g. "SMS - HDFC Bank", "UPI - Google Pay"
  final String date; // ISO yyyy-MM-dd
  String category; // AI/rule assigned, user-correctable
  bool categoryWasCorrectedByUser;
  final String rawSmsBody; // kept for debugging / re-parsing, never shown raw to a 3rd party

  TransactionRecord({
    required this.id,
    required this.merchantRaw,
    required this.amount,
    required this.direction,
    required this.source,
    required this.date,
    required this.category,
    this.categoryWasCorrectedByUser = false,
    this.rawSmsBody = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchantRaw': merchantRaw,
        'amount': amount,
        'direction': direction.name,
        'source': source,
        'date': date,
        'category': category,
        'categoryWasCorrectedByUser': categoryWasCorrectedByUser,
        'rawSmsBody': rawSmsBody,
      };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) => TransactionRecord(
        id: json['id'],
        merchantRaw: json['merchantRaw'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        direction: TxnDirection.values.firstWhere(
          (d) => d.name == json['direction'],
          orElse: () => TxnDirection.unknown,
        ),
        source: json['source'] ?? '',
        date: json['date'] ?? '',
        category: json['category'] ?? 'Other',
        categoryWasCorrectedByUser: json['categoryWasCorrectedByUser'] ?? false,
        rawSmsBody: json['rawSmsBody'] ?? '',
      );
}
