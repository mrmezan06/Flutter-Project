import 'package:expense/widgets/expenses_list/expenses_list.dart';
import 'package:expense/widgets/new_expense.dart';
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

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
        context: context, builder: (context) => const NewExpense());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          )
        ],
      ),

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
