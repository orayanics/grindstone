import 'package:flutter/material.dart';
import 'package:grindstone/presentation/screens/program/widgets/exercise_search_dialog.dart';
import 'package:grindstone/core/exports/components.dart';

class SearchExercisesList extends StatefulWidget {
  final List<Map<String, dynamic>> initialExercises;
  final Function(List<Map<String, dynamic>>) onExercisesSelected;

  const SearchExercisesList({
    super.key,
    this.initialExercises = const [],
    required this.onExercisesSelected,
  });

  @override
  State<SearchExercisesList> createState() => _SearchExercisesListState();
}

class _SearchExercisesListState extends State<SearchExercisesList> {
  late List<Map<String, dynamic>> _selectedExercises;

  @override
  void initState() {
    super.initState();
    _selectedExercises = List.from(widget.initialExercises);
  }

  void _openSearchDialog() async {
    final selectedExercises = await ExerciseSearchDialog.show(context);

    if (selectedExercises != null && mounted) {
      setState(() {
        _selectedExercises = selectedExercises;
      });
      widget.onExercisesSelected(_selectedExercises);
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
      widget.onExercisesSelected(_selectedExercises);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: [
        if (_selectedExercises.isNotEmpty) ...[
          const SizedBox(height: 16),
          Flexible(
              child: ListView.builder(
                  itemCount: _selectedExercises.length,
                  itemBuilder: (context, index) {
                    if (index >= _selectedExercises.length) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Chip(
                          label: Text(_selectedExercises[index]['name']),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeExercise(index),
                        ));
                  })),
        ],
        AccentButton(
          label: 'Search Exercises',
          onPressed: _openSearchDialog,
        ),
      ],
    ));
  }
}
