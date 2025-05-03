import 'package:flutter/material.dart';
  import 'package:grindstone/core/config/colors.dart';
  import 'package:grindstone/core/services/log_service.dart';
  import 'package:provider/provider.dart';

  class ExerciseListItem extends StatefulWidget {
    final Map<String, String> exercise;
    final VoidCallback? onDelete;
    final VoidCallback? onSelect;

    const ExerciseListItem({
      super.key,
      required this.exercise,
      this.onDelete,
      this.onSelect,
    });

    @override
    State<ExerciseListItem> createState() => _ExerciseListItemState();
  }

  class _ExerciseListItemState extends State<ExerciseListItem> {
    String _weight = '';
    String _reps = '';
    String _rir = '';
    String _action = '';
    IconData? _actionIcon;

    @override
    void initState() {
      super.initState();
      _fetchLatestLog();
    }

    Future<void> _fetchLatestLog() async {
      final logService = Provider.of<LogService>(context, listen: false);
      final logs = await logService.fetchLogById(widget.exercise['id']!);
      if (logs.isNotEmpty) {
        final latestLog = logs.last;
        setState(() {
          _weight = '${latestLog.weight} kg';
          _reps = '${latestLog.reps} reps';
          _rir = '${latestLog.rir} RIR';
          _action = latestLog.action;

          // Determine the icon based on the action
          if (_action == 'Increase') {
            _actionIcon = Icons.arrow_upward;
          } else if (_action == 'Decrease') {
            _actionIcon = Icons.arrow_downward;
          } else if (_action == 'Maintain') {
            _actionIcon = Icons.drag_handle; // Represents "="
          }
        });
      }
    }

    Widget _buildOutlinedText(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Card(
        elevation: 0,
        color: white,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: InkWell(
          onTap: () {
            widget.onSelect!();
          },
          child: Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(12, 0, 0, 0),
                  spreadRadius: 3,
                  blurRadius: 2,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
            child: ListTile(
              title: Text(widget.exercise['name'] ?? 'Unnamed Exercise'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildOutlinedText(_weight),
                        const SizedBox(width: 8.0),
                        _buildOutlinedText(_reps),
                        const SizedBox(width: 8.0),
                        _buildOutlinedText(_rir),
                        const SizedBox(width: 8.0),
                        if (_actionIcon != null) ...[
                          Icon(_actionIcon, color: Colors.red),
                          const SizedBox(width: 4.0),
                          Text(
                            _action,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.delete_rounded,
                  color: black,
                ),
                onPressed: () {
                  widget.onDelete!();
                },
              ),
            ),
          ),
        ),
      );
    }
  }