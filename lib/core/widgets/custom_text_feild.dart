import 'package:eightclub/core/extensions/build_extension.dart';
import 'package:flutter/material.dart';

class CustomTextFeild extends StatelessWidget {
  const CustomTextFeild({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 14,
  });
  final TextEditingController controller;
  final int? maxLines;
  final String hintText;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.colorScheme.surface,
      ),
      child: TextField(
        textInputAction: TextInputAction.go,
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hintText),
      ),
    );
  }
}
