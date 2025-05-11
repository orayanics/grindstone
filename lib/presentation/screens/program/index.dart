import 'package:flutter/material.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/config/colors.dart';

class ProgramIndexView extends StatefulWidget {
  const ProgramIndexView({super.key});

  @override
  State<ProgramIndexView> createState() => _ProgramIndexViewState();
}

class _ProgramIndexViewState extends State<ProgramIndexView> {
  bool _isInitialized = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initProgramsListener();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated()) {
        FailToast.show('You must be logged in to view programs');
        context.go(AppRoutes.login);
      }
    });
  }

  void _initProgramsListener() {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.isAuthenticated()) {
      final programService = Provider.of<ProgramService>(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        programService.startProgramsListener();
      });
    }
  }

  Future<void> _refreshPrograms() async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    await programService.refreshPrograms();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1; // Reset page on new search
    });
  }

  @override
  Widget build(BuildContext context) {
    final programService = Provider.of<ProgramService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isAuthenticated()) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredPrograms = _searchQuery.isEmpty
        ? programService.programs
        : programService.programs
        .where((program) => program.programName
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();

    final int totalPages = (filteredPrograms.length / _itemsPerPage).ceil();
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = (_currentPage * _itemsPerPage).clamp(0, filteredPrograms.length);
    final paginatedPrograms = filteredPrograms.sublist(
      startIndex,
      endIndex,
    );

    return Stack(
      children: [
        Column(
          children: [
            SearchInput(
              placeholder: 'Search',
              onChanged: _onSearchChanged,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPrograms,
                child: programService.isLoading && programService.programs.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : programService.errorMessage != null
                    ? Center(child: Text('Error: ${programService.errorMessage}'))
                    : filteredPrograms.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_searchQuery.isEmpty
                          ? 'No programs found'
                          : 'No programs matching "$_searchQuery"'),
                      const SizedBox(height: 16),
                      if (_searchQuery.isEmpty)
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.createProgram),
                          child: const Text('Create New Program'),
                        ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: paginatedPrograms.length,
                        itemBuilder: (context, index) {
                          final program = paginatedPrograms[index];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(
                              top: 16.0,
                              left: 16.0,
                              right: 16.0,
                            ),
                            child: InkWell(
                              onTap: () async {
                                await context.push(
                                  '/program-details/${program.id}',
                                  extra: program.programName,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: white,
                                  border: Border.all(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4.0,
                                      offset: Offset(0, 0),
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
                                          program.programName,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          program.dayOfExecution,
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
                                              'Day: ${program.dayOfExecution}',
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
                                              'Exercises: ${program.exercises.length}',
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
                          );
                        },
                      ),
                    ),
                    // Pagination controls
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _currentPage > 1
                                  ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                                  : null,
                            ),
                            Text('Page $_currentPage of $totalPages'),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: _currentPage < totalPages
                                  ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: accentPurple,
            onPressed: () => context.go(AppRoutes.createProgram),
            tooltip: 'Create New Program',
            child: Icon(Icons.add_rounded, color: white),
          ),
        ),
      ],
    );
  }
}
