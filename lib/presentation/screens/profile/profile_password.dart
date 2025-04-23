import 'package:flutter/material.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/services/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePasswordView extends StatelessWidget {
  const ProfilePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          PasswordDetails(),
          UpdatePasswordForm(),
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

class UpdatePasswordForm extends StatefulWidget {
  const UpdatePasswordForm({super.key});

  @override
  State<UpdatePasswordForm> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePasswordForm> {
  final _formKey = GlobalKey<FormState>();

  // Health info
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  // TO-DO: Implement logic

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Form(
        key: _formKey,
        child: Column(
          children: [
            FormInputPassword(
              controller: _newPassword,
              label: 'New Password',
              isRequired: true,
              isPrimary: false,
              placeholder: userProvider.height?.toString() ?? 'Error fetching',
            ),
            const SizedBox(height: 16),
            FormInputPassword(
              controller: _confirmPassword,
              label: 'Confirm Password',
              isRequired: true,
              isPrimary: false,
              placeholder: userProvider.age?.toString() ?? 'Error fetching',
            ),
          ],
        ));
  }
}

class PasswordDetails extends StatelessWidget {
  const PasswordDetails({super.key});

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
