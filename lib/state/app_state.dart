import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/app_data.dart';
import '../models/liability.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/sms_service.dart';
import '../services/categorizer.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;
  final SmsService smsService = SmsService();
  static const _uuid = Uuid();

  AppData data = AppData();
  bool loading = true;

  AppState(this._storage);

  Future<void> init() async {
    data = await _storage.load();
    loading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.save(data);
    notifyListeners();
  }

  /// Public wrapper for screens that mutate `data` in place (e.g. applying
  /// a SurplusOption.apply(data) callback) and then need to persist + notify.
  Future<void> save() => _persist();

  Future<void> setPhone(String phone) async {
    data.phone = phone;
    await _persist();
  }

  Future<void> saveIncome({required double salary, required double other, required int salaryDate}) async {
    data.income.salary = salary;
    data.income.other = other;
    data.income.salaryDate = salaryDate;
    await _persist();
  }

  Future<void> addLiability(Liability liability) async {
    data.liabilities.add(liability);
    await _persist();
  }

  Future<void> updateLiabilityOutstanding(String id, double newOutstanding) async {
    final l = data.liabilities.firstWhere((x) => x.id == id);
    l.outstanding = newOutstanding.clamp(0, double.infinity);
    await _persist();
  }

  Future<void> completeOnboarding() async {
    data.onboardingComplete = true;
    await _persist();
    await syncSms();
  }

  Future<void> addExtraCash(double amount) async {
    data.extraCash += amount;
    await _persist();
  }

  Future<void> setExtraCash(double amount) async {
    data.extraCash = amount;
    await _persist();
  }

  /// Pulls in real SMS from the device, parses bank/UPI alerts, dedupes
  /// against what's already stored, and starts a live listener for new ones.
  Future<int> syncSms() async {
    final granted = await smsService.requestPermissions();
    if (!granted) return 0;

    final scanned = await smsService.scanInbox();
    final existingKeys = data.transactions.map((t) => '${t.date}-${t.amount}-${t.merchantRaw}').toSet();

    int added = 0;
    for (final txn in scanned) {
      final key = '${txn.date}-${txn.amount}-${txn.merchantRaw}';
      if (existingKeys.contains(key)) continue;
      txn.category = Categorizer.categorize(txn.merchantRaw, data.merchantCategoryOverrides);
      data.transactions.add(txn);
      existingKeys.add(key);
      added++;
    }
    await _persist();

    smsService.listenForNewSms((txn) async {
      txn.category = Categorizer.categorize(txn.merchantRaw, data.merchantCategoryOverrides);
      data.transactions.add(txn);
      await _persist();
    });

    return added;
  }

  Future<void> correctTransactionCategory(String txnId, String newCategory) async {
    final txn = data.transactions.firstWhere((t) => t.id == txnId);
    txn.category = newCategory;
    txn.categoryWasCorrectedByUser = true;
    Categorizer.learn(data.merchantCategoryOverrides, txn.merchantRaw, newCategory);
    await _persist();
  }

  String newId() => _uuid.v4();

  Future<void> logout() async {
    // Local-storage logout = just clear the in-memory session marker.
    // The on-disk file is intentionally left alone so re-login restores
    // everything (this is a single-user-per-device local app for now).
    data.phone = null;
    await _persist();
  }
}
