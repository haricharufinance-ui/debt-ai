/// Known-merchant rules, same idea as the web demo's MERCHANT_MAP.
/// Unknown merchants fall back to "Other" until the user corrects them -
/// at that point the correction is remembered in AppData.merchantCategoryOverrides
/// and reused for every future transaction from that merchant.
///
/// Later: route unmatched merchants through an OpenAI call server-side
/// instead of the "Other" fallback - this function's signature doesn't
/// need to change, just what happens in the final `return` below.
class Categorizer {
  static const Map<String, String> _rules = {
    'MUTHOOT': 'Gold Loan',
    'MANAPPURAM': 'Gold Loan',
    'SWIGGY': 'Food',
    'ZOMATO': 'Food',
    'UBER': 'Travel',
    'OLA': 'Travel',
    'APOLLO': 'Medical',
    'PHARMEASY': 'Medical',
    'AMAZON': 'Shopping',
    'FLIPKART': 'Shopping',
    'NETFLIX': 'Subscriptions',
    'HOTSTAR': 'Subscriptions',
    'BESCOM': 'Utilities',
    'AIRTEL': 'Utilities',
    'JIO': 'Utilities',
  };

  static String categorize(String merchantRaw, Map<String, String> learned) {
    final upper = merchantRaw.toUpperCase();

    // 1. User corrections always win.
    for (final entry in learned.entries) {
      if (upper.contains(entry.key.toUpperCase())) return entry.value;
    }

    // 2. Built-in rule table.
    for (final entry in _rules.entries) {
      if (upper.contains(entry.key)) return entry.value;
    }

    // 3. Unknown - falls back to "Other" until the user edits it.
    return 'Other';
  }

  /// Call this whenever the user edits a transaction's category in the UI.
  static void learn(Map<String, String> learned, String merchantRaw, String newCategory) {
    learned[merchantRaw.toUpperCase().trim()] = newCategory;
  }
}
