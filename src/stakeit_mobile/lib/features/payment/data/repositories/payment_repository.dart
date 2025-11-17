import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/services/api_client.dart';

// Provider for payment repository
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return PaymentRepository(dio);
});

class PaymentRepository {
  final Dio _dio;

  PaymentRepository(this._dio);

  /// Get or create Stripe customer
  Future<String> getOrCreateCustomer() async {
    try {
      final response = await _dio.post('${AppConfig.usersEndpoint}/stripe-customer');
      return response.data['customerId'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await _dio.get('${AppConfig.usersEndpoint}/payment-methods');
      return (response.data as List)
          .map((pm) => PaymentMethodModel.fromJson(pm))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add payment method
  Future<PaymentMethodModel> addPaymentMethod(String paymentMethodId) async {
    try {
      final response = await _dio.post(
        '${AppConfig.usersEndpoint}/payment-methods',
        data: {'paymentMethodId': paymentMethodId},
      );
      return PaymentMethodModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      await _dio.delete(
        '${AppConfig.usersEndpoint}/payment-methods/$paymentMethodId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Set default payment method
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      await _dio.put(
        '${AppConfig.usersEndpoint}/payment-methods/$paymentMethodId/default',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create setup intent for adding card
  Future<String> createSetupIntent() async {
    try {
      final response = await _dio.post('${AppConfig.usersEndpoint}/setup-intent');
      return response.data['clientSecret'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get wallet balance
  Future<WalletModel> getWallet() async {
    try {
      final response = await _dio.get('${AppConfig.usersEndpoint}/wallet');
      return WalletModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get transaction history
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConfig.usersEndpoint}/transactions',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return (response.data as List)
          .map((t) => TransactionModel.fromJson(t))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request payout
  Future<void> requestPayout(double amount) async {
    try {
      await _dio.post(
        '${AppConfig.usersEndpoint}/payout',
        data: {'amount': amount},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'];
      }
      return 'Erreur: ${e.response!.statusCode}';
    }
    return 'Une erreur est survenue';
  }
}

// Models
class PaymentMethodModel {
  final String id;
  final String type;
  final String last4;
  final String brand;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.last4,
    required this.brand,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      type: json['type'] as String,
      last4: json['last4'] as String,
      brand: json['brand'] as String,
      expMonth: json['expMonth'] as int,
      expYear: json['expYear'] as int,
      isDefault: json['isDefault'] as bool,
    );
  }

  String get cardDisplay => '•••• $last4';
  String get expiryDisplay => '${expMonth.toString().padLeft(2, '0')}/$expYear';
  bool get isExpired {
    final now = DateTime.now();
    final expiry = DateTime(expYear, expMonth);
    return now.isAfter(expiry);
  }
}

class WalletModel {
  final double availableBalance;
  final double pendingBalance;
  final double lifetimeEarnings;
  final double lifetimeSpent;
  final double lifetimeCommissionPaid; // Total commission paid to platform

  WalletModel({
    required this.availableBalance,
    required this.pendingBalance,
    required this.lifetimeEarnings,
    required this.lifetimeSpent,
    this.lifetimeCommissionPaid = 0.0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      availableBalance: (json['availableBalance'] as num).toDouble(),
      pendingBalance: (json['pendingBalance'] as num).toDouble(),
      lifetimeEarnings: (json['lifetimeEarnings'] as num).toDouble(),
      lifetimeSpent: (json['lifetimeSpent'] as num).toDouble(),
      lifetimeCommissionPaid: json['lifetimeCommissionPaid'] != null
          ? (json['lifetimeCommissionPaid'] as num).toDouble()
          : 0.0,
    );
  }

  double get totalBalance => availableBalance + pendingBalance;
  double get netProfit => lifetimeEarnings - lifetimeSpent - lifetimeCommissionPaid;
}

class TransactionModel {
  final int id;
  final String type;
  final double amount;
  final double? commissionAmount; // Commission deducted (if applicable)
  final String status;
  final String description;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.commissionAmount,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      commissionAmount: json['commissionAmount'] != null
          ? (json['commissionAmount'] as num).toDouble()
          : null,
      status: json['status'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isCredit => type == 'Credit' || type == 'Refund';
  bool get isDebit => type == 'Debit' || type == 'Charge';
  bool get hasCommission => commissionAmount != null && commissionAmount! > 0;

  // Net amount after commission
  double get netAmount => hasCommission ? amount - commissionAmount! : amount;
}
