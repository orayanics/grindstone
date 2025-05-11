import 'package:flutter/material.dart';
        import 'package:grindstone/core/exports/components.dart';
        import 'package:grindstone/core/services/user_provider.dart';
        import 'package:provider/provider.dart';

        class ProfileHealthView extends StatelessWidget {
          const ProfileHealthView({super.key});

          @override
          Widget build(BuildContext context) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  HealthUserDetails(),
                  UpdateHealthForm(),
                ],
              ),
            );
          }
        }

        class UpdateHealthForm extends StatefulWidget {
          const UpdateHealthForm({super.key});

          @override
          State<UpdateHealthForm> createState() => _UpdateHealthState();
        }

        class _UpdateHealthState extends State<UpdateHealthForm> {
          final _formKey = GlobalKey<FormState>();

          final TextEditingController _weightController = TextEditingController();
          final TextEditingController _heightController = TextEditingController();
          final TextEditingController _ageController = TextEditingController();
          String _sex = 'Male';
          final List<String> _sexOptions = ['Male', 'Female', 'Other'];

          @override
          void initState() {
            super.initState();
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            _weightController.text = userProvider.weight?.toString() ?? '';
            _heightController.text = userProvider.height?.toString() ?? '';
            _ageController.text = userProvider.age?.toString() ?? '';
          }

          void _updateHealthDetails() async {
            if (_formKey.currentState!.validate()) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);

              try {
                await userProvider.updateHealthDetails(
                  weight: double.parse(_weightController.text),
                  height: double.parse(_heightController.text),
                  age: int.parse(_ageController.text),
                );
                SuccessToast.show("Health details updated successfully");
              } catch (e) {
                FailToast.show("Failed to update health details: $e");
              }
            }
          }

          @override
          Widget build(BuildContext context) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  FormInputNumber(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    isRequired: true,
                    isPrimary: false,
                    placeholder: 'Enter your weight',
                  ),
                  const SizedBox(height: 16),
                  FormInputNumber(
                    controller: _heightController,
                    label: 'Height (cm)',
                    isRequired: true,
                    isPrimary: false,
                    placeholder: 'Enter your height',
                  ),


                  const SizedBox(height: 16),
                  FormInputNumber(
                    controller: _ageController,
                    label: 'Age',
                    isRequired: true,
                    isPrimary: false,
                    placeholder: 'Enter your age',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: AccentButton(
                      label: 'Save Changes',
                      onPressed: _updateHealthDetails,
                    ),
                  ),
                ],
              ),
            );
          }
        }

        class HealthUserDetails extends StatelessWidget {
          const HealthUserDetails({super.key});

          @override
          Widget build(BuildContext context) {
            final userProvider = context.watch<UserProvider>();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Weight: ${userProvider.weight?.toStringAsFixed(1) ?? 'N/A'} kg\n'
                      'Height: ${userProvider.height?.toStringAsFixed(1) ?? 'N/A'} cm\n'
                      'Age: ${userProvider.age ?? 'N/A'}\n',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }
        }