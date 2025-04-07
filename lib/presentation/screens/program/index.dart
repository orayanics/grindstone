import 'package:flutter/material.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ProgramIndexView extends StatefulWidget {
  const ProgramIndexView({super.key});

  @override
  State<ProgramIndexView> createState() => _ProgramIndexViewState();
}

class _ProgramIndexViewState extends State<ProgramIndexView> {
  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  void _loadPrograms() {
    final programService = Provider.of<ProgramService>(context, listen: false);
    programService.fetchPrograms();
  }

  @override
  Widget build(BuildContext context) {
    final programService = Provider.of<ProgramService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Programs')),
      body: programService.isLoading
          ? Center(child: CircularProgressIndicator())
          : programService.errorMessage != null
              ? Center(child: Text('Error: ${programService.errorMessage}'))
              : programService.programs.isEmpty
                  ? Center(child: Text('No programs found'))
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

                              _loadPrograms();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
