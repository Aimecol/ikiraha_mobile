import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};
  Map<String, dynamic> _restaurantInfo = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    // Simulate loading dashboard data
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data - replace with actual API calls
    setState(() {
      _restaurantInfo = {
        'name': 'Pizza Palace',
        'category': 'Italian',
        'rating': 4.5,
        'totalReviews': 120,
        'isOpen': true,
        'address': 'Kigali, Rwanda',
        'phone': '+250788123456',
      };
      
      _dashboardData = {
        'todayOrders': 23,
        'pendingOrders': 5,
        'completedOrders': 18,
        'todayRevenue': 450.75,
        'menuItems': 45,
        'activeItems': 42,
        'lowStockItems': 3,
        'averageOrderValue': 19.60,
        'customerSatisfaction': 4.3,
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
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(user),
                    const SizedBox(height: 20),
                    _buildRestaurantInfo(),
                    const SizedBox(height: 20),
                    _buildTodayStats(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade600,
              Colors.amber.shade400,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.firstName ?? 'Manager'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Restaurant Manager • ${_restaurantInfo['name'] ?? 'Restaurant'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _restaurantInfo['isOpen'] == true ? Icons.store : Icons.store_mall_directory,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _restaurantInfo['isOpen'] == true ? 'Open' : 'Closed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_restaurantInfo['rating'] ?? 0} (${_restaurantInfo['totalReviews'] ?? 0} reviews)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
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
            _buildInfoRow('Name', _restaurantInfo['name'] ?? 'N/A'),
            _buildInfoRow('Category', _restaurantInfo['category'] ?? 'N/A'),
            _buildInfoRow('Address', _restaurantInfo['address'] ?? 'N/A'),
            _buildInfoRow('Phone', _restaurantInfo['phone'] ?? 'N/A'),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Orders Today',
              _dashboardData['todayOrders']?.toString() ?? '0',
              Icons.shopping_bag,
              Colors.blue,
            ),
            _buildStatCard(
              'Pending',
              _dashboardData['pendingOrders']?.toString() ?? '0',
              Icons.pending,
              Colors.orange,
            ),
            _buildStatCard(
              'Revenue',
              '\$${(_dashboardData['todayRevenue'] ?? 0).toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildStatCard(
              'Avg Order',
              '\$${(_dashboardData['averageOrderValue'] ?? 0).toStringAsFixed(0)}',
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3,
              children: [
                _buildActionButton('View Orders', Icons.list_alt, () {}),
                _buildActionButton('Add Menu Item', Icons.add_circle, () {}),
                _buildActionButton('Update Stock', Icons.inventory, () {}),
                _buildActionButton('View Reports', Icons.analytics, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label functionality coming soon!')),
        );
      },
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activities = [
                  {'title': 'New order received', 'subtitle': 'Order #1234 - \$25.50', 'icon': Icons.shopping_bag},
                  {'title': 'Menu item updated', 'subtitle': 'Pizza Margherita price changed', 'icon': Icons.edit},
                  {'title': 'Order completed', 'subtitle': 'Order #1233 delivered', 'icon': Icons.check_circle},
                  {'title': 'Low stock alert', 'subtitle': 'Mozzarella cheese running low', 'icon': Icons.warning},
                  {'title': 'Customer review', 'subtitle': '5 stars - "Great food!"', 'icon': Icons.star},
                ];
                
                final activity = activities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(activity['title'] as String),
                  subtitle: Text(activity['subtitle'] as String),
                  trailing: Text(
                    '${index + 1}h ago',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
