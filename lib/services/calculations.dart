import '../models/app_data.dart';
import '../models/liability.dart';
import '../models/transaction.dart';

/// All debt-math lives here and nowhere else, so dashboard, liability
/// detail, and the AI coach always agree with each other.
class Calculations {
  static double totalDebt(AppData d) =>
      d.liabilities.fold(0.0, (sum, l) => sum + l.outstanding);

  static double upcomingEmiTotal(AppData d) =>
      d.liabilities.fold(0.0, (sum, l) => sum + l.emi);

  /// Spending this cycle that ISN'T already counted inside EMI totals.
  /// Loan-category transactions are excluded to avoid double-subtracting
  /// the same rupee from cash (see the same fix applied in the web demo).
  static double nonEmiSpendThisCycle(AppData d) {
    return d.transactions
        .where((t) => t.direction == TxnDirection.debit && !kLoanTypes.contains(t.category))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Available cash = income - EMIs due - everything else already spent,
  /// plus any uncommitted buffer/surplus. Single source of truth.
  static double availableCash(AppData d) {
    final income = d.income.total;
    final emi = upcomingEmiTotal(d);
    final spent = nonEmiSpendThisCycle(d);
    final cash = income - emi - spent + d.extraCash;
    return cash < 0 ? 0 : cash;
  }

  /// Always derived from, and capped by, availableCash - so it can never
  /// claim more is "safe" than what's actually there.
  static double safeToSpend(AppData d) {
    final cash = availableCash(d);
    final safe = cash * 0.4;
    return safe > cash ? cash : (safe < 0 ? 0 : safe);
  }

  static int healthScore(AppData d) {
    final income = d.income.total == 0 ? 1 : d.income.total;
    final emiRatio = upcomingEmiTotal(d) / income;
    final score = (100 - emiRatio * 140).round();
    return score.clamp(5, 95);
  }

  static Liability? highestInterestLiability(AppData d) {
    if (d.liabilities.isEmpty) return null;
    final sorted = [...d.liabilities]..sort((a, b) => b.rate.compareTo(a.rate));
    return sorted.first;
  }

  static Liability? smallestBalanceLiability(AppData d) {
    if (d.liabilities.isEmpty) return null;
    final sorted = [...d.liabilities]..sort((a, b) => a.outstanding.compareTo(b.outstanding));
    return sorted.first;
  }

  static String topAiSuggestion(AppData d) {
    final top = highestInterestLiability(d);
    if (top == null) return 'Add a liability to get your first recommendation.';
    final extra = (top.outstanding * 0.05).clamp(0, 5000);
    return 'Pay ₹${extra.round()} extra toward your ${top.type} (${top.lender}) — '
        "it carries your highest interest rate at ${top.rate}%.";
  }

  /// Three surplus-allocation options, same logic as the web demo.
  static List<SurplusOption> surplusOptions(AppData d, double amount) {
    final top = highestInterestLiability(d);
    final smallest = smallestBalanceLiability(d);
    if (top == null || smallest == null || amount <= 0) return [];

    final debtPortion = (amount * 0.66).round();
    final fundPortion = (amount * 0.2).round();
    final spendPortion = (amount * 0.14).round();

    return [
      SurplusOption(
        id: 'split',
        title: 'Split it three ways',
        description:
            '₹$debtPortion → highest-interest loan, ₹$fundPortion → emergency fund, ₹$spendPortion → spending.',
        apply: (data) {
          top.outstanding = (top.outstanding - debtPortion).clamp(0, double.infinity);
          data.extraCash += fundPortion + spendPortion;
        },
      ),
      SurplusOption(
        id: 'highest',
        title: 'Pay your highest-interest loan',
        description:
            'Put all ₹${amount.round()} toward your ${top.type} (${top.rate}% interest) — saves the most over time.',
        apply: (data) {
          top.outstanding = (top.outstanding - amount).clamp(0, double.infinity);
        },
      ),
      SurplusOption(
        id: 'smallest',
        title: 'Close your smallest loan',
        description: smallest.outstanding <= amount
            ? 'Fully closes your ${smallest.type} and frees up ₹${smallest.emi.round()}/month.'
            : 'Knocks ₹${amount.round()} off your ${smallest.type} - not quite enough to close it yet.',
        apply: (data) {
          smallest.outstanding = (smallest.outstanding - amount).clamp(0, double.infinity);
        },
      ),
    ];
  }
}

class SurplusOption {
  final String id;
  final String title;
  final String description;
  final void Function(AppData data) apply;

  SurplusOption({
    required this.id,
    required this.title,
    required this.description,
    required this.apply,
  });
}
