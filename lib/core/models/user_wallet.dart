// // user_wallet.dart
// class UserWallet {
//   final String address;
//   final String balance; // ETH balance
//   final String usdtBalance;

//   UserWallet({
//     required this.address,
//     required this.balance,
//     required this.usdtBalance,
//   });

//   Map<String, dynamic> toJson() => {
//     'address': address,
//     'balance': balance,
//     'usdtBalance': usdtBalance,
//   };

//   factory UserWallet.fromJson(Map<String, dynamic> json) => UserWallet(
//     address: json['address'],
//     balance: json['balance'],
//     usdtBalance: json['usdtBalance'],
//   );
// }

class UserWallet {
  final String address;
  final String balance; // ETH balance
  final String rtknBalance; // ✅ Renamed from usdtBalance

  UserWallet({
    required this.address,
    required this.balance,
    required this.rtknBalance, // ✅ Changed
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      address: json['address'] as String,
      balance: json['balance'] as String,
      rtknBalance: json['rtknBalance'] as String, // ✅ Changed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'balance': balance,
      'rtknBalance': rtknBalance, // ✅ Changed
    };
  }

  UserWallet copyWith({
    String? address,
    String? balance,
    String? rtknBalance, // ✅ Changed
  }) {
    return UserWallet(
      address: address ?? this.address,
      balance: balance ?? this.balance,
      rtknBalance: rtknBalance ?? this.rtknBalance, // ✅ Changed
    );
  }
}
