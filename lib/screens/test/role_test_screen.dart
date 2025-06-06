import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/role_based_navigation.dart';
import '../../models/api_response.dart';

class RoleTestScreen extends StatefulWidget {
  const RoleTestScreen({super.key});

  @override
  State<RoleTestScreen> createState() => _RoleTestScreenState();
}

class _RoleTestScreenState extends State<RoleTestScreen> {
  final AuthService _authService = AuthService();
  String _selectedRole = 'super_admin';

  final List<String> _roles = [
    'super_admin',
    'admin',
    'restaurant_owner',
    'restaurant_manager',
    'delivery_driver',
    'customer',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Testing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current User Info',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Logged In: ${_authService.isLoggedIn}'),
                    Text('Current Role: ${_authService.currentUserRole ?? 'None'}'),
                    Text('Is Super Admin: ${_authService.isSuperAdmin}'),
                    Text('Is Admin: ${_authService.isAdmin}'),
                    Text('Is Restaurant Owner: ${_authService.isRestaurantOwner}'),
                    Text('Is Delivery Driver: ${_authService.isDeliveryDriver}'),
                    Text('Is Customer: ${_authService.isCustomer}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Role Navigation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Select Role to Test',
                        border: OutlineInputBorder(),
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(RoleBasedNavigation.getRoleDisplayName(role)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _testRole,
                      child: const Text('Test Role Navigation'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Role Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._roles.map((role) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: RoleBasedNavigation.getRoleColor(role),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(RoleBasedNavigation.getRoleDisplayName(role)),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testRole() {
    // Create a mock user with the selected role
    final mockUser = User(
      id: 1,
      uuid: 'test-uuid',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      roleName: _selectedRole,
      isActive: true,
      isVerified: true,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    // Temporarily set the mock user (this is just for testing)
    // In a real app, you would login with proper credentials
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Role Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Testing role: ${RoleBasedNavigation.getRoleDisplayName(_selectedRole)}'),
            const SizedBox(height: 12),
            Text('Navigation items for this role:'),
            const SizedBox(height: 8),
            // Show what navigation items this role would have
            ...RoleBasedNavigation.getNavigationItems().map((item) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    item.icon,
                    const SizedBox(width: 8),
                    Text(item.label!),
                  ],
                ),
              )
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (_authService.isLoggedIn)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                RoleBasedNavigation.navigateToRoleBasedHome(context);
              },
              child: const Text('Navigate'),
            ),
        ],
      ),
    );
  }
}
