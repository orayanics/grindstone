import 'package:flutter/material.dart';
import 'package:grindstone/presentation/components/dialog/exercise_search_dialog.dart';
import 'package:grindstone/core/exports/components.dart';

class SearchExercisesList extends StatefulWidget {
  const SearchExercisesList({super.key});

  @override
  State<SearchExercisesList> createState() => _SearchExercisesListState();
}

class _SearchExercisesListState extends State<SearchExercisesList> {
  List<Map<String, dynamic>> _selectedExercises = [];

  void _openSearchDialog() async {
    final selectedExercises = await ExerciseSearchDialog.show(context);

    if (selectedExercises != null && mounted) {
      setState(() {
        _selectedExercises = selectedExercises;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccentButton(
          label: 'Search Exercises',
          onPressed: _openSearchDialog,
        ),

        // Refactor ui
        if (_selectedExercises.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected: ${_selectedExercises.map((e) => e['name']).join(', ')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedExercises = [];
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
