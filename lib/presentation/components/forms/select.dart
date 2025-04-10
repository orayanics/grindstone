import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? value;
  final bool isRequired;
  final bool isPrimary;
  final String placeholder;
  final Function(String) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.options,
    this.value,
    required this.onChanged,
    this.isRequired = false,
    this.isPrimary = false,
    this.placeholder = 'Select',
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.isRequired)
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: widget.isPrimary ? white : lightGray,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.isPrimary ? Colors.transparent : Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton(
                value: widget.value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                elevation: 16,
                items: widget.options.map((String option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
