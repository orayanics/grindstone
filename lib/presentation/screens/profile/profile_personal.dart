import 'package:flutter/material.dart';
      import 'package:grindstone/core/exports/components.dart';
      import 'package:grindstone/core/services/user_provider.dart';
      import 'package:provider/provider.dart';

      class ProfilePersonalView extends StatelessWidget {
        const ProfilePersonalView({super.key});

        @override
        Widget build(BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                PersonalUserDetails(),
                UpdatePersonalForm(),
              ],
            ),
          );
        }
      }

      class UpdatePersonalForm extends StatefulWidget {
        const UpdatePersonalForm({super.key});

        @override
        State<UpdatePersonalForm> createState() => _UpdatePersonalState();
      }

      class _UpdatePersonalState extends State<UpdatePersonalForm> {
        final _formKey = GlobalKey<FormState>();
        final TextEditingController _firstNameController = TextEditingController();
        final TextEditingController _lastNameController = TextEditingController();

        @override
        void initState() {
          super.initState();
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          _firstNameController.text = userProvider.firstName ?? '';
          _lastNameController.text = userProvider.lastName ?? '';
        }

        void _updatePersonalDetails() async {
          if (_formKey.currentState!.validate()) {
            final userProvider = Provider.of<UserProvider>(context, listen: false);

            try {
              await userProvider.updatePersonalDetails(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
              );
              SuccessToast.show("Personal details updated successfully");
            } catch (e) {
              FailToast.show("Failed to update personal details: $e");
            }
          }
        }

        @override
        Widget build(BuildContext context) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                FormInputText(
                  controller: _firstNameController,
                  label: 'First Name',
                  isRequired: true,
                  isPrimary: false,
                  placeholder: 'Enter your first name',
                ),
                const SizedBox(height: 16),
                FormInputText(
                  controller: _lastNameController,
                  label: 'Last Name',
                  isRequired: true,
                  isPrimary: false,
                  placeholder: 'Enter your last name',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AccentButton(
                    label: 'Save Changes',
                    onPressed: _updatePersonalDetails,
                  ),
                ),
              ],
            ),
          );
        }
      }

      class PersonalUserDetails extends StatelessWidget {
        const PersonalUserDetails({super.key});

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
                    '${userProvider.firstName ?? 'User'} ${userProvider.lastName ?? ''}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
          );
        }
      }