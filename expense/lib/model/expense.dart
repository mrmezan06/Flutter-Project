import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final formatter = DateFormat.yMEd().add_jm();

const uuid = Uuid();

enum Category {
  food,
  bazar,
  breakfast,
  shopping,
  health,
  entertainment,
  cigarette,
  rent,
  utility,
  wifi,
  travel,
  fuel,
  other,
}

const categoryIcons = {
  Category.food: Icons.food_bank,
  Category.bazar: Icons.shopping_bag,
  Category.breakfast: Icons.breakfast_dining,
  Category.shopping: Icons.shopping_cart,
  Category.health: Icons.medical_services,
  Category.entertainment: Icons.movie,
  Category.cigarette: Icons.smoking_rooms,
  Category.rent: Icons.house,
  Category.utility: Icons.water,
  Category.wifi: Icons.wifi,
  Category.travel: Icons.flight,
  Category.fuel: Icons.local_gas_station,
  Category.other: Icons.money,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }
}
