class Balance {
  final int? id;
  final int amount;
  final String type;
  final String category;
  final String ctime;

  Balance(
      {this.id,
      required this.amount,
      required this.type,
      required this.category,
      required this.ctime});

  factory Balance.fromMap(Map<String, dynamic> json) => Balance(
      id: json['id'],
      amount: json['amount'],
      type: json['type'],
      category: json['category'],
      ctime: json['ctime']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'ctime': ctime
    };
  }
}
