import 'package:expense/widgets/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:expense/model/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.food;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    if (pickedDate == null) {
      return;
    }
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitExpenseData() {
    final enteredTitle = _titleController.text.trim();
    final enteredAmount = double.tryParse(_amountController.text);

    final isInvalidAmount = enteredAmount == null || enteredAmount <= 0;

    if (enteredTitle.isEmpty || isInvalidAmount || _selectedDate == null) {
      // Show error dialog
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Input'),
              content: const Text(
                  'Please enter valid title, amount and date to continue.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Okay'))
              ],
            );
          });
      return;
    }

    final expense = Expense(
      title: enteredTitle,
      amount: enteredAmount,
      date: _selectedDate!,
      category: _selectedCategory,
    );

    widget.onAddExpense(expense);

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;

      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 48, 16, keyboardSpace + 16),
            child: Column(
              children: [
                if (width >= 600)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyTextField(
                          controller: _titleController,
                          hintText: 'Title',
                          textInputType: TextInputType.text,
                          prefixText: '',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyTextField(
                          controller: _amountController,
                          hintText: 'Amount',
                          textInputType: TextInputType.number,
                          prefixText: '\$ ',
                        ),
                      ),
                    ],
                  )
                else
                  MyTextField(
                    controller: _titleController,
                    hintText: 'Title',
                    textInputType: TextInputType.text,
                    prefixText: '',
                  ),
                const SizedBox(height: 16),
                if (width >= 600)
                  Row(
                    children: [
                      DropdownButton(
                        menuMaxHeight: 200,
                        value: _selectedCategory,
                        items: Category.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(categoryIcons[category]),
                                const SizedBox(width: 16),
                                Text(category.name.toUpperCase()),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(_selectedDate == null
                                ? 'No Date Chosen!'
                                : formatter.format(_selectedDate!)),
                            IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(
                                Icons.calendar_month,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: MyTextField(
                          controller: _amountController,
                          hintText: 'Amount',
                          textInputType: TextInputType.number,
                          prefixText: '\$ ',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(_selectedDate == null
                                ? 'No Date Chosen!'
                                : formatter.format(_selectedDate!)),
                            IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(
                                Icons.calendar_month,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (width >= 600)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: _submitExpenseData,
                        child: const Text('Save',
                            style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton(
                        menuMaxHeight: 200,
                        value: _selectedCategory,
                        items: Category.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(categoryIcons[category]),
                                const SizedBox(width: 16),
                                Text(category.name.toUpperCase()),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: _submitExpenseData,
                        child: const Text('Save',
                            style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      );
    });
  }
}
