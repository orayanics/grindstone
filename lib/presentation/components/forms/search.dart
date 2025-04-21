import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class SearchInput extends StatefulWidget {
  final String placeholder;
  final bool hasIcon;
  final Function(String) onChanged;

  const SearchInput({
    super.key,
    required this.placeholder,
    required this.onChanged,
    this.hasIcon = true,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleSearchChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSearchChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleSearchChange() {
    setState(() {
      _searchQuery = _controller.text;
    });
    widget.onChanged(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(color: textLight),
                    prefixIcon:
                        widget.hasIcon ? Icon(Icons.search_rounded) : null,
                    prefixIconColor: textLight,
                    suffixIcon: widget.hasIcon && _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded),
                            onPressed: _clearSearch,
                          )
                        : null,
                    suffixIconColor: textLight,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                  onChanged: widget.onChanged,
                ),
              ],
            )));
  }
}
