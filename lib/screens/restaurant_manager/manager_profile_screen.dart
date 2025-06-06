import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/role_based_navigation.dart';
import '../auth/login_screen.dart';

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Map<String, dynamic> _restaurantInfo = {};

  @override
  void initState() {
    super.initState();
    _loadRestaurantInfo();
  }

  Future<void> _loadRestaurantInfo() async {
    setState(() => _isLoading = true);
    
    // Simulate loading restaurant info
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    setState(() {
      _restaurantInfo = {
        'name': 'Pizza Palace',
        'category': 'Italian',
        'rating': 4.5,
        'totalReviews': 120,
        'isOpen': true,
        'address': 'Kigali, Rwanda',
        'phone': '+250788123456',
        'email': 'info@pizzapalace.com',
        'manager_since': '2024-01-15',
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  _buildRestaurantInfo(),
                  const SizedBox(height: 24),
                  _buildManagerStats(),
                  const SizedBox(height: 24),
                  _buildProfileOptions(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: RoleBasedNavigation.getRoleColor('restaurant_manager'),
              child: Text(
                user?.firstName.substring(0, 1).toUpperCase() ?? 'M',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'Manager Name',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'manager@example.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: RoleBasedNavigation.getRoleColor('restaurant_manager').withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                RoleBasedNavigation.getRoleDisplayName('restaurant_manager'),
                style: TextStyle(
                  color: RoleBasedNavigation.getRoleColor('restaurant_manager'),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Restaurant Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Restaurant', _restaurantInfo['name'] ?? 'N/A'),
            _buildInfoRow('Category', _restaurantInfo['category'] ?? 'N/A'),
            _buildInfoRow('Rating', '${_restaurantInfo['rating'] ?? 0} (${_restaurantInfo['totalReviews'] ?? 0} reviews)'),
            _buildInfoRow('Address', _restaurantInfo['address'] ?? 'N/A'),
            _buildInfoRow('Phone', _restaurantInfo['phone'] ?? 'N/A'),
            _buildInfoRow('Email', _restaurantInfo['email'] ?? 'N/A'),
            _buildInfoRow('Manager Since', _restaurantInfo['manager_since'] ?? 'N/A'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:', style: TextStyle(fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _restaurantInfo['isOpen'] == true ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _restaurantInfo['isOpen'] == true ? 'Open' : 'Closed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
              children: [
                _buildStatCard('Orders Today', '23', Icons.shopping_bag, Colors.blue),
                _buildStatCard('Menu Items', '45', Icons.restaurant_menu, Colors.green),
                _buildStatCard('Avg Rating', '4.5', Icons.star, Colors.amber),
                _buildStatCard('This Month', '456', Icons.calendar_month, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildProfileOption(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile coming soon!')),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.lock,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change password coming soon!')),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.notifications,
          title: 'Notification Settings',
          subtitle: 'Configure notification preferences',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification settings coming soon!')),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.analytics,
          title: 'Performance Reports',
          subtitle: 'View detailed performance analytics',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Performance reports coming soon!')),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & support coming soon!')),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {
            _showAboutDialog();
          },
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Ikiraha Restaurant Manager',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.restaurant,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const Text('Restaurant management made easy.'),
        const SizedBox(height: 16),
        const Text('Manage your menu, orders, and track performance all in one place.'),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
