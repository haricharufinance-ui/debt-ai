import 'income.dart';
import 'liability.dart';
import 'transaction.dart';

/// The single root object that gets serialized to the local JSON file.
/// When you move to a database/backend later, this shape becomes your
/// API response/request body almost unchanged - so keep it normalized.
class AppData {
  String? phone;
  bool onboardingComplete;
  IncomeProfile income;
  List<Liability> liabilities;
  List<TransactionRecord> transactions;
  double extraCash; // one-off buffer + surplus money not yet allocated to debt
  Map<String, String> merchantCategoryOverrides; // learned corrections, merchant -> category

  AppData({
    this.phone,
    this.onboardingComplete = false,
    IncomeProfile? income,
    List<Liability>? liabilities,
    List<TransactionRecord>? transactions,
    this.extraCash = 0,
    Map<String, String>? merchantCategoryOverrides,
  })  : income = income ?? IncomeProfile(),
        liabilities = liabilities ?? [],
        transactions = transactions ?? [],
        merchantCategoryOverrides = merchantCategoryOverrides ?? {};

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'onboardingComplete': onboardingComplete,
        'income': income.toJson(),
        'liabilities': liabilities.map((l) => l.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'extraCash': extraCash,
        'merchantCategoryOverrides': merchantCategoryOverrides,
      };

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        phone: json['phone'],
        onboardingComplete: json['onboardingComplete'] ?? false,
        income: IncomeProfile.fromJson(json['income'] ?? {}),
        liabilities: ((json['liabilities'] ?? []) as List)
            .map((e) => Liability.fromJson(e))
            .toList(),
        transactions: ((json['transactions'] ?? []) as List)
            .map((e) => TransactionRecord.fromJson(e))
            .toList(),
        extraCash: (json['extraCash'] ?? 0).toDouble(),
        merchantCategoryOverrides:
            Map<String, String>.from(json['merchantCategoryOverrides'] ?? {}),
      );
}
