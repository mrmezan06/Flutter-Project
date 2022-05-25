class LsSource {
  final int? id;
  final int amount;
  final String type;
  final String category;
  final String ctime;

  LsSource(
      {this.id,
      required this.amount,
      required this.type,
      required this.category,
      required this.ctime});

  factory LsSource.fromMap(Map<String, dynamic> json) => LsSource(
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
