import 'package:expense/widgets/chart/chart.dart';
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
  void _addExpense(Expense expense) {
    setState(() {
      _regExpenses.add(expense);
    });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => NewExpense(
              onAddExpense: _addExpense,
            ));
  }

  void _removeExpense(Expense expense) {
    final expensIndex = _regExpenses.indexOf(expense);
    setState(() {
      _regExpenses.remove(expense);
    });

    // Clear previous snackbar if any
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense removed successfully!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _regExpenses.insert(expensIndex, expense);
            });
          },
        ),
      ),
    );
  }

 

  @override
  Widget build(BuildContext context) {

    // Find the total width of the screen
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;


    Widget mainContent = const Center(
      child: Text('No Expenses added yet!'),
    );

    if (_regExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _regExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
        child: width < height
            ? Column(
          children: [
            Chart(expenses: _regExpenses),
            const SizedBox(
              height: 10,
            ),
            mainContent
          ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 25,
                  ),
                  Expanded(
                    flex: 1,
                    child: Chart(expenses: _regExpenses),
                  ),
                  Expanded(
                    flex: 2,
                    child: mainContent,
                  ),
                ],
        ),
      ),
    );
  }
}
