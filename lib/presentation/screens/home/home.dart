import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isInitialized = false;
  String _searchQuery = '';
  Map<String, dynamic>? _mostRecentProgram;

  @override
  void initState() {
    super.initState();
    _loadMostRecentProgram();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initProgramsListener();
      _isInitialized = true;
    }
  }

  void _initProgramsListener() {
    final programService = Provider.of<ProgramService>(context, listen: false);
    programService.startProgramsListener();
  }

  void _loadMostRecentProgram() async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    final recentProgram = await programService.fetchMostRecentExercise();

    if (recentProgram == null) {
      print('No recent program found.');
    } else {
      print('Most recent program fetched: $recentProgram');
    }

    setState(() {
      _mostRecentProgram = recentProgram;
    });
  }

  String _formatLastUpdatedDate(dynamic lastUpdated) {
    if (lastUpdated == null) return 'N/A';

    try {
      // If already a DateTime object
      if (lastUpdated is DateTime) {
        return DateFormat.yMMMMd().format(lastUpdated);
      }

      // If it's a Timestamp from Firestore
      if (lastUpdated.toString().contains('Timestamp')) {
        return DateFormat.yMMMMd().format(lastUpdated.toDate());
      }

      // If it's an ISO 8601 string
      final parsed = DateTime.tryParse(lastUpdated.toString());
      if (parsed != null) {
        return DateFormat.yMMMMd().format(parsed);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return 'Unknown date';
  }

  @override
  Widget build(BuildContext context) {
    final programService = Provider.of<ProgramService>(context);

    return Scaffold(
      body: programService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mostRecentProgram == null
          ? const Center(child: Text('No recent program available'))
          : Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Last session on ${_formatLastUpdatedDate(_mostRecentProgram?['lastUpdated'])}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () => context.push(
                  '/program-details/${_mostRecentProgram?['id']}',
                  extra: _mostRecentProgram?['programName'],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _mostRecentProgram?['programName'] ?? 'No Program Name',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _mostRecentProgram?['dayOfExecution'] ?? 'No Day Available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: accentRed,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                'Day: ${_mostRecentProgram?['dayOfExecution']}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: accentRed,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                'Exercises: ${_mostRecentProgram?['exercises']?.length ?? 0}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
