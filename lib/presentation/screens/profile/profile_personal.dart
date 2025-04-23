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
          SizedBox(
            height: 16.0,
          ),
          SizedBox(
            width: double.infinity,
            child: AccentButton(label: 'Save Changes', onPressed: () {}),
          )
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
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Form(
        key: _formKey,
        child: Column(
          children: [
            FormInputText(
                controller: _firstNameController,
                label: 'First Name',
                isRequired: true,
                isPrimary: false,
                placeholder: userProvider.firstName ?? 'Error fetching'),
            const SizedBox(height: 16),
            FormInputText(
              controller: _lastNameController,
              label: 'Last Name',
              isRequired: true,
              isPrimary: false,
              placeholder: userProvider.lastName ?? 'Error fetching',
            ),
          ],
        ));
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
