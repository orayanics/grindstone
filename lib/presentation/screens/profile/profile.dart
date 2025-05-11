import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const UserDetails(),
          const ProfileSettings(),
        ],
      ),
    );
  }
}

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

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
          const SizedBox(height: 24),
          _buildInfoRow(Icons.calendar_today, 'Age',
              userProvider.age?.toString() ?? 'Not set'),
          const Divider(),
          _buildInfoRow(
              Icons.height,
              'Height',
              userProvider.height != null
                  ? '${userProvider.height} cm'
                  : 'Not set'),
          const Divider(),
          _buildInfoRow(
              Icons.monitor_weight,
              'Weight',
              userProvider.weight != null
                  ? '${userProvider.weight} kg'
                  : 'Not set'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// profile settings in card
class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
                color: const Color.fromARGB(12, 0, 0, 0),
                spreadRadius: 3,
                blurRadius: 2,
                offset: Offset(1, 0))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
            ),
          ),
          _settingsRow(Icons.person_2_rounded, 'Profile Information', () {
            GoRouter.of(context).push(AppRoutes.updatePersonal);
          }),
          _settingsRow(Icons.health_and_safety, 'Health Data', () {
            GoRouter.of(context).push(AppRoutes.updateHealth);
          }),
          _settingsRow(Icons.password_rounded, 'Change Password', () {
            GoRouter.of(context).push(AppRoutes.changePassword);
          }),
          _settingsRow(
            Icons.waving_hand_rounded,
            'Logout',
            () async {
              final authService = context.read<AuthService>();
              await authService.signout(context);
            },
          )
        ],
      ),
    );
  }

  Widget _settingsRow(IconData icon, String label, [VoidCallback? onPressed]) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(
                  width: 16.0,
                ),
                Text(label),
              ],
            ),
            const Icon(Icons.arrow_forward_ios_rounded)
          ],
        ),
      ),
    );
  }
}
