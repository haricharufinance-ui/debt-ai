import '../models/app_data.dart';
import 'calculations.dart';

/// Fully offline, rule-based coach - mirrors the web demo's aiReply().
/// Swap later: replace the body of `reply()` with an OpenAI call that's
/// given the user's real liabilities/income via function-calling. The
/// call site (the chat screen) doesn't need to change.
class AiCoach {
  static String reply(AppData d, String question) {
    if (d.liabilities.isEmpty) {
      return "You haven't added any liabilities yet — add one from Home and I'll personalize this.";
    }

    final lower = question.toLowerCase();
    final top = Calculations.highestInterestLiability(d)!;
    final smallest = Calculations.smallestBalanceLiability(d)!;

    final priceMatch = RegExp(r'(\d[\d,]*)').firstMatch(question);

    if (lower.contains('buy') || lower.contains('purchase') || priceMatch != null) {
      final price = priceMatch != null
          ? double.tryParse(priceMatch.group(1)!.replaceAll(',', '')) ?? 5000
          : 5000;
      final emi = top.emi == 0 ? 5000 : top.emi;
      final months = (price / emi).round().clamp(1, 999);
      return 'That ₹${price.round()} purchase would delay your ${top.type} closure by about '
          '$months month${months > 1 ? 's' : ''}. If it\'s not essential this month, I\'d skip it.';
    }

    if (lower.contains('which loan') && lower.contains('pay')) {
      return 'Pay your ${top.type} (${top.lender}) first — it\'s at ${top.rate}%, your highest interest rate.';
    }

    if (lower.contains('close first') || lower.contains('close')) {
      return 'Close your ${smallest.type} (${smallest.lender}) first — it\'s your smallest balance at '
          '₹${smallest.outstanding.round()} and frees up ₹${smallest.emi.round()}/month fastest.';
    }

    if (lower.contains('how much can i spend') || lower.contains('safe')) {
      final safe = Calculations.safeToSpend(d).round();
      return 'You can safely spend about ₹$safe today without affecting any upcoming EMI.';
    }

    if (lower.contains('bonus') || lower.contains('extra') || lower.contains('gift') || lower.contains('refund')) {
      return 'Go to Home → "Add a surplus payment" and I\'ll split it across your ${top.type}, '
          'an emergency fund, and some spending money.';
    }

    if (lower.contains('interest')) {
      final extra = (top.outstanding * 0.05).clamp(0, 5000);
      final monthlySave = (top.outstanding * (top.rate / 100 / 12)).round();
      return 'If you pay ₹${extra.round()} extra on your ${top.type} this month, '
          'you\'d save roughly ₹$monthlySave in interest.';
    }

    final totalDebt = Calculations.totalDebt(d).round();
    return 'Based on your ₹$totalDebt total debt, I\'d focus on your ${top.type} next — '
        'it\'s your highest-interest loan at ${top.rate}%.';
  }
}
