import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType textInputType;
  final String prefixText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.textInputType,
    required this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextField(
        controller: controller,
        keyboardType: textInputType,
        decoration: InputDecoration(
          prefixText: prefixText,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ),
    );
  }
}
