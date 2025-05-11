import 'package:flutter/material.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/services/user_provider.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfilePasswordView extends StatelessWidget {
  const ProfilePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: const [
          PasswordDetails(),
          UpdatePasswordForm(),
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
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPassword.text != _confirmPassword.text) {
        FailToast.show("Passwords do not match");
        return;
      }

      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.updatePassword(
        newPassword: _newPassword.text,
        context: context,
      );
    }
  }

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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AccentButton(
              label: 'Save Changes',
              onPressed: _updatePassword,
            ),
          ),
        ],
      ),
    );
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
