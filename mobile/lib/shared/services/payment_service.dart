import '../../core/network/api_client.dart';
import '../../core/network/storage_service.dart';
import '../models/book_model.dart';

/// Payment Service
class PaymentService {
  final ApiClient _api;
  final StorageService _storage;

  PaymentService(this._api, this._storage);

  // Create order
  Future<ApiResult<Order>> createOrder({
    String? bookId,
    String? chapterId,
    required String orderType,
    required String paymentMethod,
    String? giftReceiverId,
    String? giftMessage,
  }) async {
    try {
      final response = await _api.post('/orders', data: {
        if (bookId != null) 'bookId': bookId,
        if (chapterId != null) 'chapterId': chapterId,
        'orderType': orderType,
        'paymentMethod': paymentMethod,
        if (giftReceiverId != null) 'giftReceiverId': giftReceiverId,
        if (giftMessage != null) 'giftMessage': giftMessage,
      });

      return ApiResult.success(Order.fromJson(response.data['data'] as Map<String, dynamic>));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Pay order
  Future<ApiResult<PaymentResult>> payOrder(
    String orderId, {
    required String paymentMethod,
    String? returnUrl,
  }) async {
    try {
      final response = await _api.post('/orders/$orderId/pay', data: {
        'paymentMethod': paymentMethod,
        if (returnUrl != null) 'returnUrl': returnUrl,
      });

      return ApiResult.success(PaymentResult.fromJson(
        response.data['data'] as Map<String, dynamic>,
      ));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get order list
  Future<ApiResult<OrderList>> getOrders({
    String? status,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _api.get('/orders', queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'size': size,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      return ApiResult.success(OrderList.fromJson(data));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get order detail
  Future<ApiResult<Order>> getOrderById(String orderId) async {
    try {
      final response = await _api.get('/orders/$orderId');
      return ApiResult.success(Order.fromJson(response.data['data'] as Map<String, dynamic>));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get VIP plans
  Future<ApiResult<List<VipPlan>>> getVipPlans() async {
    try {
      final response = await _api.get('/vip/plans');
      final plans = (response.data['data'] as List)
          .map((e) => VipPlan.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(plans);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Subscribe VIP
  Future<ApiResult<Order>> subscribeVip({
    required String planId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _api.post('/vip/subscribe', data: {
        'planId': planId,
        'paymentMethod': paymentMethod,
      });
      return ApiResult.success(Order.fromJson(response.data['data'] as Map<String, dynamic>));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get VIP status
  Future<ApiResult<VipStatus>> getVipStatus() async {
    try {
      final response = await _api.get('/vip/status');
      return ApiResult.success(VipStatus.fromJson(
        response.data['data'] as Map<String, dynamic>,
      ));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Apply withdrawal
  Future<ApiResult<bool>> applyWithdrawal({
    required double amount,
    required String method,
    String? bankAccount,
    String? bankName,
    String? paypalAccount,
  }) async {
    try {
      final response = await _api.post('/withdrawals', data: {
        'amount': amount,
        'method': method,
        if (bankAccount != null) 'bankAccount': bankAccount,
        if (bankName != null) 'bankName': bankName,
        if (paypalAccount != null) 'paypalAccount': paypalAccount,
      });
      return ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get balance
  Future<ApiResult<Balance>> getBalance() async {
    try {
      final response = await _api.get('/withdrawals/balance');
      return ApiResult.success(Balance.fromJson(
        response.data['data'] as Map<String, dynamic>,
      ));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}

class Order {
  final String id;
  final String orderNo;
  final String orderType;
  final double amount;
  final String currency;
  final String paymentStatus;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNo,
    required this.orderType,
    required this.amount,
    required this.currency,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNo: json['orderNo'] as String,
      orderType: json['orderType'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'CNY',
      paymentStatus: json['paymentStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OrderList {
  final List<Order> items;
  final int total;

  OrderList({required this.items, required this.total});

  factory OrderList.fromJson(Map<String, dynamic> json) {
    return OrderList(
      items: (json['items'] as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }
}

class PaymentResult {
  final bool success;
  final String? paymentUrl;
  final Map<String, dynamic>? paymentParams;
  final String? error;

  PaymentResult({
    required this.success,
    this.paymentUrl,
    this.paymentParams,
    this.error,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'] as bool,
      paymentUrl: json['paymentUrl'] as String?,
      paymentParams: json['paymentParams'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }
}

class VipPlan {
  final String id;
  final String name;
  final String type;
  final double priceCNY;
  final double priceUSD;
  final int discount;
  final List<String> features;

  VipPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.priceCNY,
    required this.priceUSD,
    required this.discount,
    required this.features,
  });

  factory VipPlan.fromJson(Map<String, dynamic> json) {
    return VipPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      priceCNY: (json['priceCNY'] as num).toDouble(),
      priceUSD: (json['priceUSD'] as num).toDouble(),
      discount: json['discount'] as int? ?? 0,
      features: List<String>.from(json['features'] as List),
    );
  }
}

class VipStatus {
  final bool isVip;
  final String? vipType;
  final DateTime? expireAt;

  VipStatus({required this.isVip, this.vipType, this.expireAt});

  factory VipStatus.fromJson(Map<String, dynamic> json) {
    return VipStatus(
      isVip: json['isVip'] as bool,
      vipType: json['vipType'] as String?,
      expireAt: json['expireAt'] != null
          ? DateTime.parse(json['expireAt'] as String)
          : null,
    );
  }
}

class Balance {
  final double totalIncome;
  final double pendingIncome;
  final double withdrawableBalance;

  Balance({
    required this.totalIncome,
    required this.pendingIncome,
    required this.withdrawableBalance,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      pendingIncome: (json['pendingIncome'] as num).toDouble(),
      withdrawableBalance: (json['withdrawableBalance'] as num).toDouble(),
    );
  }
}
