import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/auth_controller.dart';
import '../../venues/views/venue_list_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  String? _selectedUser;

  final List<Map<String, String>> _users = [
    {'id': 'User_A', 'name': 'User A'},
    {'id': 'User_B', 'name': 'User B'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'QuickSlot',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32.sp,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Select a profile to continue',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Profile',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: _selectedUser,
                        hint: const Text('Choose profile...'),
                        items: _users.map((user) {
                          return DropdownMenuItem<String>(
                            value: user['id'],
                            child: Text(user['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUser = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _selectedUser == null
                    ? null
                    : () {
                        ref.read(authProvider.notifier).login(_selectedUser!);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VenueListScreen(),
                          ),
                        );
                      },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
