import 'package:flutter/material.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_session.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/routes/routes.dart';

class ProgramIndexView extends StatefulWidget {
  const ProgramIndexView({super.key});

  @override
  State<ProgramIndexView> createState() => _ProgramIndexViewState();
}

class _ProgramIndexViewState extends State<ProgramIndexView> {
  bool _isInitialized = false;

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

  void _checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
        FailToast.show('You must be logged in to view programs');
        context.go(AppRoutes.login);
      }
    });
  }

  void _initProgramsListener() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authService.isSignedIn && userProvider.isAuthenticated()) {
      final programService =
          Provider.of<ProgramService>(context, listen: false);

      programService.startProgramsListener();
    }
  }

  Future<void> _refreshPrograms() async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    await programService.refreshPrograms();
  }

  @override
  Widget build(BuildContext context) {
    final programService = Provider.of<ProgramService>(context);
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You must be logged in to view programs'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              child: Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshPrograms,
          child: programService.isLoading && programService.programs.isEmpty
              ? Center(child: CircularProgressIndicator())
              : programService.errorMessage != null
                  ? Center(child: Text('Error: ${programService.errorMessage}'))
                  : programService.programs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('No programs found'),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    context.go(AppRoutes.createProgram),
                                child: Text('Create New Program'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: programService.programs.length,
                          itemBuilder: (context, index) {
                            final program = programService.programs[index];
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () async {
                                  await context.push(
                                    '/program-details/${program.id}',
                                    extra: program.programName,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        program.programName,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text('Day: ${program.dayOfExecution}'),
                                      Text(
                                          'Exercises: ${program.exercises.length}'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => context.go(AppRoutes.createProgram),
            tooltip: 'Create New Program',
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
