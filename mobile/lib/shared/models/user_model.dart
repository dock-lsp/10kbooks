import 'package:equatable/equatable.dart';

/// User model
class User extends Equatable {
  final String id;
  final String? phone;
  final String? email;
  final String nickname;
  final String? avatar;
  final String? bio;
  final String? realName;
  final String? idCardType;
  final String? idCardNumber;
  final String realAuthStatus;
  final DateTime? realAuthAt;
  final String vipStatus;
  final DateTime? vipExpireAt;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    this.phone,
    this.email,
    required this.nickname,
    this.avatar,
    this.bio,
    this.realName,
    this.idCardType,
    this.idCardNumber,
    this.realAuthStatus = 'none',
    this.realAuthAt,
    this.vipStatus = 'none',
    this.vipExpireAt,
    this.language = 'zh-CN',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isVip => vipStatus != 'none';
  bool get isRealAuth => realAuthStatus == 'approved';

  User copyWith({
    String? id,
    String? phone,
    String? email,
    String? nickname,
    String? avatar,
    String? bio,
    String? realName,
    String? idCardType,
    String? idCardNumber,
    String? realAuthStatus,
    DateTime? realAuthAt,
    String? vipStatus,
    DateTime? vipExpireAt,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      realName: realName ?? this.realName,
      idCardType: idCardType ?? this.idCardType,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      realAuthStatus: realAuthStatus ?? this.realAuthStatus,
      realAuthAt: realAuthAt ?? this.realAuthAt,
      vipStatus: vipStatus ?? this.vipStatus,
      vipExpireAt: vipExpireAt ?? this.vipExpireAt,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      realName: json['realName'] as String?,
      idCardType: json['idCardType'] as String?,
      idCardNumber: json['idCardNumber'] as String?,
      realAuthStatus: json['realAuthStatus'] as String? ?? 'none',
      realAuthAt: json['realAuthAt'] != null
          ? DateTime.parse(json['realAuthAt'] as String)
          : null,
      vipStatus: json['vipStatus'] as String? ?? 'none',
      vipExpireAt: json['vipExpireAt'] != null
          ? DateTime.parse(json['vipExpireAt'] as String)
          : null,
      language: json['language'] as String? ?? 'zh-CN',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'nickname': nickname,
      'avatar': avatar,
      'bio': bio,
      'realName': realName,
      'idCardType': idCardType,
      'idCardNumber': idCardNumber,
      'realAuthStatus': realAuthStatus,
      'realAuthAt': realAuthAt?.toIso8601String(),
      'vipStatus': vipStatus,
      'vipExpireAt': vipExpireAt?.toIso8601String(),
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        email,
        nickname,
        avatar,
        bio,
        realName,
        idCardType,
        idCardNumber,
        realAuthStatus,
        realAuthAt,
        vipStatus,
        vipExpireAt,
        language,
        createdAt,
        updatedAt,
      ];
}

/// Author model
class Author extends Equatable {
  final String id;
  final String userId;
  final User? user;
  final String penName;
  final String authorLevel;
  final int totalBooks;
  final int totalWords;
  final int totalFans;
  final double totalIncome;
  final double pendingIncome;
  final double withdrawableBalance;
  final String? bankAccount;
  final String? bankName;
  final String? paypalAccount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Author({
    required this.id,
    required this.userId,
    this.user,
    required this.penName,
    this.authorLevel = 'normal',
    this.totalBooks = 0,
    this.totalWords = 0,
    this.totalFans = 0,
    this.totalIncome = 0,
    this.pendingIncome = 0,
    this.withdrawableBalance = 0,
    this.bankAccount,
    this.bankName,
    this.paypalAccount,
    required this.createdAt,
    required this.updatedAt,
  });

  Author copyWith({
    String? id,
    String? userId,
    User? user,
    String? penName,
    String? authorLevel,
    int? totalBooks,
    int? totalWords,
    int? totalFans,
    double? totalIncome,
    double? pendingIncome,
    double? withdrawableBalance,
    String? bankAccount,
    String? bankName,
    String? paypalAccount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Author(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      penName: penName ?? this.penName,
      authorLevel: authorLevel ?? this.authorLevel,
      totalBooks: totalBooks ?? this.totalBooks,
      totalWords: totalWords ?? this.totalWords,
      totalFans: totalFans ?? this.totalFans,
      totalIncome: totalIncome ?? this.totalIncome,
      pendingIncome: pendingIncome ?? this.pendingIncome,
      withdrawableBalance: withdrawableBalance ?? this.withdrawableBalance,
      bankAccount: bankAccount ?? this.bankAccount,
      bankName: bankName ?? this.bankName,
      paypalAccount: paypalAccount ?? this.paypalAccount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as String,
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      penName: json['penName'] as String,
      authorLevel: json['authorLevel'] as String? ?? 'normal',
      totalBooks: json['totalBooks'] as int? ?? 0,
      totalWords: json['totalWords'] as int? ?? 0,
      totalFans: json['totalFans'] as int? ?? 0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      pendingIncome: (json['pendingIncome'] as num?)?.toDouble() ?? 0,
      withdrawableBalance: (json['withdrawableBalance'] as num?)?.toDouble() ?? 0,
      bankAccount: json['bankAccount'] as String?,
      bankName: json['bankName'] as String?,
      paypalAccount: json['paypalAccount'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'penName': penName,
      'authorLevel': authorLevel,
      'totalBooks': totalBooks,
      'totalWords': totalWords,
      'totalFans': totalFans,
      'totalIncome': totalIncome,
      'pendingIncome': pendingIncome,
      'withdrawableBalance': withdrawableBalance,
      'bankAccount': bankAccount,
      'bankName': bankName,
      'paypalAccount': paypalAccount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        user,
        penName,
        authorLevel,
        totalBooks,
        totalWords,
        totalFans,
        totalIncome,
        pendingIncome,
        withdrawableBalance,
        bankAccount,
        bankName,
        paypalAccount,
        createdAt,
        updatedAt,
      ];
}
