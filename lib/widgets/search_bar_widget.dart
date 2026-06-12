import 'package:flutter/material.dart';

class SearchBarWidget
    extends StatelessWidget {

  final Function(String)
      onChanged;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration:
          InputDecoration(
        prefixIcon:
            const Icon(
          Icons.search,
        ),
        hintText:
            'Search claims...',
      ),
    );
  }
}