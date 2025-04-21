import 'package:flutter/material.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/config/colors.dart';

class ExerciseSearchDialog extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSelectExercises;

  const ExerciseSearchDialog({
    super.key,
    required this.onSelectExercises,
  });

  static Future<List<Map<String, dynamic>>?> show(BuildContext context) async {
    return await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) => ExerciseSearchDialog(
        onSelectExercises: (exercises) {
          Navigator.of(context).pop(exercises);
        },
      ),
    );
  }

  @override
  State<ExerciseSearchDialog> createState() => _ExerciseSearchDialogState();
}

class _ExerciseSearchDialogState extends State<ExerciseSearchDialog> {
  List<Map<String, dynamic>> _searchResults = [];
  final List<Map<String, dynamic>> _selectedExercises = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchExercises(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await ExerciseApi.fetchSearch(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        FailToast.show('Failed to get exercises');
      }
    }
  }

  void _toggleExerciseSelection(Map<String, dynamic> exercise) {
    setState(() {
      if (!_isExerciseSelected(exercise)) {
        _selectedExercises.add(exercise);
      } else {
        _selectedExercises
            .removeWhere((e) => e['exerciseId'] == exercise['exerciseId']);
      }
    });
  }

  bool _isExerciseSelected(Map<String, dynamic> exercise) {
    return _selectedExercises
        .any((e) => e['exerciseId'] == exercise['exerciseId']);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: white,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Search Exercises',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: accentRed,
                    )),
            const SizedBox(height: 16),
            SearchInput(
              placeholder: 'Search for exercises',
              hasIcon: false,
              onChanged: (query) {
                _fetchExercises(query);
              },
            ),
            const SizedBox(height: 8),
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isNotEmpty)
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: _ExerciseSearchResults(
                    results: _searchResults,
                    selectedExercises: _selectedExercises,
                    onToggleSelection: _toggleExerciseSelection,
                  ),
                ),
              )
            else if (_searchController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('No exercises found')),
              ),
            if (_selectedExercises.isNotEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text('Selected (${_selectedExercises.length}):',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              Flexible(
                  child: Container(
                color: white,
                child: ListView.builder(
                    itemCount: _selectedExercises.length,
                    itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Chip(
                            label: Text(_selectedExercises[index]['name']),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _toggleExerciseSelection(
                                _selectedExercises[index]),
                          ),
                        )),
              )),
            ],
            const SizedBox(height: 16),
            AccentButton(
              onPressed: () {
                if (_selectedExercises.isEmpty) {
                  return;
                }
                widget.onSelectExercises(_selectedExercises);
              },
              label: 'Add Selected',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final List<Map<String, dynamic>> selectedExercises;
  final Function(Map<String, dynamic>) onToggleSelection;

  const _ExerciseSearchResults({
    required this.results,
    required this.selectedExercises,
    required this.onToggleSelection,
  });

  bool _isSelected(Map<String, dynamic> exercise) {
    return selectedExercises
        .any((e) => e['exerciseId'] == exercise['exerciseId']);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final exercise = results[index];
        final isSelected = _isSelected(exercise);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: Text(exercise['name']),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: accentRed)
              : const Icon(Icons.circle_outlined),
          selected: isSelected,
          selectedTileColor: lightGray,
          onTap: () => onToggleSelection(exercise),
        );
      },
    );
  }
}
