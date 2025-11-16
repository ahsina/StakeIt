import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/payment_repository.dart';

// Provider for payment methods
final paymentMethodsProvider = FutureProvider<List<PaymentMethodModel>>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getPaymentMethods();
});

// Provider for wallet
final walletProvider = FutureProvider<WalletModel>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getWallet();
});

// Provider for transactions
final transactionsProvider = FutureProvider.family<List<TransactionModel>, int>(
  (ref, page) async {
    final repository = ref.watch(paymentRepositoryProvider);
    return repository.getTransactions(page: page);
  },
);

// State notifier for payment operations
class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;

  PaymentNotifier(this._repository) : super(PaymentState.initial());

  Future<void> addPaymentMethod(String paymentMethodId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addPaymentMethod(paymentMethodId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> removePaymentMethod(String paymentMethodId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.removePaymentMethod(paymentMethodId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.setDefaultPaymentMethod(paymentMethodId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<String> createSetupIntent() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final clientSecret = await _repository.createSetupIntent();
      state = state.copyWith(isLoading: false);
      return clientSecret;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> requestPayout(double amount) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.requestPayout(amount);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository);
});

// State class
class PaymentState {
  final bool isLoading;
  final String? error;

  PaymentState({
    required this.isLoading,
    this.error,
  });

  factory PaymentState.initial() => PaymentState(isLoading: false);

  PaymentState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
