import 'package:expense/widgets/expenses_list/expenses_list.dart';
import 'package:flutter/material.dart';
import 'package:expense/model/expense.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _regExpenses = [
    Expense(
      title: 'Eggs',
      amount: 40,
      date: DateTime.now(),
      category: Category.bazar,
    ),
    Expense(
      title: 'Chilly',
      amount: 15,
      date: DateTime.now(),
      category: Category.bazar,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Text('The Chart'),
            ExpensesList(expenses: _regExpenses)
          ],
        ),
      ),
    );
  }
}
