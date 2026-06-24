const List<String> kLoanTypes = [
  'Gold Loan',
  'Personal Loan',
  'Home Loan',
  'Vehicle Loan',
  'Credit Card',
  'Friends/Family Loan',
  'Chit Fund',
];

class Liability {
  final String id;
  String type;
  String lender;
  double original;
  double outstanding;
  double rate; // annual interest %
  double emi;
  String? loanDate; // ISO yyyy-MM-dd
  String? dueDate; // ISO yyyy-MM-dd
  String status; // Active / Overdue / Closed
  String? notes;

  // Gold-loan-only extras
  double? goldWeightGrams;
  String? goldPurity;
  String? renewalDate;
  String? auctionDate;
  String? branchName;

  Liability({
    required this.id,
    required this.type,
    required this.lender,
    required this.original,
    required this.outstanding,
    required this.rate,
    required this.emi,
    this.loanDate,
    this.dueDate,
    this.status = 'Active',
    this.notes,
    this.goldWeightGrams,
    this.goldPurity,
    this.renewalDate,
    this.auctionDate,
    this.branchName,
  });

  double get percentPaidOff =>
      original <= 0 ? 0 : (((original - outstanding) / original) * 100).clamp(0, 100);

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'lender': lender,
        'original': original,
        'outstanding': outstanding,
        'rate': rate,
        'emi': emi,
        'loanDate': loanDate,
        'dueDate': dueDate,
        'status': status,
        'notes': notes,
        'goldWeightGrams': goldWeightGrams,
        'goldPurity': goldPurity,
        'renewalDate': renewalDate,
        'auctionDate': auctionDate,
        'branchName': branchName,
      };

  factory Liability.fromJson(Map<String, dynamic> json) => Liability(
        id: json['id'],
        type: json['type'],
        lender: json['lender'] ?? '',
        original: (json['original'] ?? 0).toDouble(),
        outstanding: (json['outstanding'] ?? 0).toDouble(),
        rate: (json['rate'] ?? 0).toDouble(),
        emi: (json['emi'] ?? 0).toDouble(),
        loanDate: json['loanDate'],
        dueDate: json['dueDate'],
        status: json['status'] ?? 'Active',
        notes: json['notes'],
        goldWeightGrams: json['goldWeightGrams']?.toDouble(),
        goldPurity: json['goldPurity'],
        renewalDate: json['renewalDate'],
        auctionDate: json['auctionDate'],
        branchName: json['branchName'],
      );
}
