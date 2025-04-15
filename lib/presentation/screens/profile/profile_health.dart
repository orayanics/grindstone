import 'package:flutter/material.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/services/user_session.dart';
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

class UpdateHealthForm extends StatefulWidget {
  const UpdateHealthForm({super.key});

  @override
  State<UpdateHealthForm> createState() => _UpdateHealthState();
}

class _UpdateHealthState extends State<UpdateHealthForm> {
  final _formKey = GlobalKey<FormState>();

  // Health info
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _sex = 'Male';
  final List<String> _sexOptions = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Form(
        key: _formKey,
        child: Column(
          children: [
            FormInputNumber(
              controller: _weightController,
              label: 'Weight (kg)',
              isRequired: true,
              isPrimary: false,
              placeholder: userProvider.weight?.toString() ?? 'Error fetching',
            ),
            const SizedBox(height: 16),
            FormInputNumber(
              controller: _heightController,
              label: 'Height (cm)',
              isRequired: true,
              isPrimary: false,
              placeholder: userProvider.height?.toString() ?? 'Error fetching',
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Sex',
              options: _sexOptions,
              value: _sex,
              isRequired: true,
              onChanged: (String newValue) {
                setState(() {
                  _sex = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            FormInputNumber(
              controller: _ageController,
              label: 'Age',
              isRequired: true,
              isPrimary: false,
              placeholder: userProvider.age?.toString() ?? 'Error fetching',
            ),
          ],
        ));
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
              '${userProvider.firstName ?? 'User'} ${userProvider.lastName ?? ''}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }
}
