import 'package:another_telephony/telephony.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/categorizer.dart';

/// Real device SMS scraper for bank/UPI debit & credit alerts.
///
/// NOTE ON THE PACKAGE: `another_telephony` is a community-maintained fork
/// of the old `telephony` plugin (Android-only, which matches the
/// "Android-first" requirement). Method names below follow that package's
/// public API as of writing - after `flutter pub get`, check the package's
/// pub.dev page for the exact current signatures if your installed version
/// has renamed anything; the parsing/categorization logic underneath is
/// independent of that and won't need to change.
class SmsService {
  final Telephony _telephony = Telephony.instance;
  static const _uuid = Uuid();

  Future<bool> requestPermissions() async {
    final granted = await _telephony.requestPhoneAndSmsPermissions;
    return granted ?? false;
  }

  /// One-time scan of the existing SMS inbox, parsed into TransactionRecords.
  /// Run this right after onboarding (and optionally as a manual "Sync now").
  Future<List<TransactionRecord>> scanInbox({int limit = 300}) async {
    final messages = await _telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    final results = <TransactionRecord>[];
    for (final msg in messages.take(limit)) {
      final parsed = parseBankSms(
        sender: msg.address ?? '',
        body: msg.body ?? '',
        timestampMs: msg.date,
      );
      if (parsed != null) results.add(parsed);
    }
    return results;
  }

  /// Call once at app startup (e.g. in main()) to keep catching new SMS
  /// while the app is alive. For true background capture while the app is
  /// closed, register `onBackgroundMessage` with a top-level function per
  /// the package's background-isolate setup instructions.
  void listenForNewSms(void Function(TransactionRecord txn) onTransaction) {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final parsed = parseBankSms(
          sender: message.address ?? '',
          body: message.body ?? '',
          timestampMs: message.date,
        );
        if (parsed != null) onTransaction(parsed);
      },
      listenInBackground: false,
    );
  }

  /// Heuristic parser for typical Indian bank / UPI debit & credit SMS.
  /// Bank SMS formats vary a lot - this covers the common patterns
  /// (debited/credited/spent/sent + Rs./INR + "to"/"at"/"VPA" merchant tag).
  /// Treat this as a starting point: add bank-specific regexes here as you
  /// run into real-world messages it misses.
  static TransactionRecord? parseBankSms({
    required String sender,
    required String body,
    int? timestampMs,
  }) {
    if (body.isEmpty) return null;

    final amountMatch = RegExp(
      r'(?:Rs\.?|INR)\s?([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(body);
    if (amountMatch == null) return null;

    final amount = double.tryParse(amountMatch.group(1)!.replaceAll(',', ''));
    if (amount == null || amount <= 0) return null;

    final lower = body.toLowerCase();
    TxnDirection direction;
    if (lower.contains('debited') || lower.contains('spent') || lower.contains('sent') || lower.contains('paid')) {
      direction = TxnDirection.debit;
    } else if (lower.contains('credited') || lower.contains('received')) {
      direction = TxnDirection.credit;
    } else {
      // Not a recognizable transaction alert (could be OTP, promo, etc.)
      return null;
    }

    // Merchant / payee extraction: look after common connector words.
    String merchant = sender;
    final merchantMatch = RegExp(
      r'(?:to|at|from|VPA)\s+([A-Za-z0-9 .@_&-]{3,40})',
      caseSensitive: false,
    ).firstMatch(body);
    if (merchantMatch != null) {
      merchant = merchantMatch.group(1)!.trim().split(RegExp(r'\s{2,}|\.\s'))[0];
    }

    final date = timestampMs != null
        ? DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(timestampMs))
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    return TransactionRecord(
      id: _uuid.v4(),
      merchantRaw: merchant,
      amount: amount,
      direction: direction,
      source: 'SMS - $sender',
      date: date,
      category: Categorizer.categorize(merchant, const {}),
      rawSmsBody: body,
    );
  }
}
