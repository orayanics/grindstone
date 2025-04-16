import 'package:flutter/material.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_session.dart';
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
      final programService =
          Provider.of<ProgramService>(context, listen: false);

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final programService = Provider.of<ProgramService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isAuthenticated()) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filteredPrograms = _searchQuery.isEmpty
        ? programService.programs
        : programService.programs
            .where((program) => program.programName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

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
                child: programService.isLoading &&
                        programService.programs.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : programService.errorMessage != null
                        ? Center(
                            child:
                                Text('Error: ${programService.errorMessage}'))
                        : filteredPrograms.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(_searchQuery.isEmpty
                                        ? 'No programs found'
                                        : 'No programs matching "$_searchQuery"'),
                                    SizedBox(height: 16),
                                    if (_searchQuery.isEmpty)
                                      ElevatedButton(
                                        onPressed: () =>
                                            context.go(AppRoutes.createProgram),
                                        child: Text('Create New Program'),
                                      ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredPrograms.length,
                                itemBuilder: (context, index) {
                                  final program = filteredPrograms[index];
                                  return Card(
                                    elevation: 0,
                                    margin: EdgeInsets.only(
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
                                          border: Border.all(
                                            color: Colors.transparent,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4.0,
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  program.programName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  program.dayOfExecution,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: textLight,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.0),
                                            // TODO: Refactor to listview builder with singlechildscrollview
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Wrap(
                                                spacing: 8,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 8.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: accentRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                    child: Text(
                                                      'Day: ${program.dayOfExecution}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: white,
                                                          ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 8.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: accentRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                    child: Text(
                                                      'Exercises: ${program.exercises.length}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
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
            child: Icon(
              Icons.add_rounded,
              color: white,
            ),
          ),
        ),
      ],
    );
  }
}
