import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String _selectedPeriod = 'week';
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    
    // Simulate loading analytics data - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    setState(() {
      _analyticsData = {
        'revenue': {
          'total': 125000.50,
          'growth': 12.5,
          'thisMonth': 25000.00,
          'lastMonth': 22000.00,
        },
        'orders': {
          'total': 3420,
          'growth': 8.3,
          'thisMonth': 680,
          'lastMonth': 628,
        },
        'users': {
          'total': 1250,
          'growth': 15.2,
          'newThisMonth': 95,
          'activeUsers': 890,
        },
        'restaurants': {
          'total': 85,
          'growth': 6.7,
          'newThisMonth': 5,
          'activeRestaurants': 78,
        },
        'topRestaurants': [
          {'name': 'Pizza Palace', 'orders': 245, 'revenue': 12500.00},
          {'name': 'Burger House', 'orders': 198, 'revenue': 9800.00},
          {'name': 'Sushi Zen', 'orders': 156, 'revenue': 15600.00},
        ],
        'recentOrders': [
          {'id': '#ORD-001', 'customer': 'John Doe', 'amount': 25.50, 'status': 'Delivered'},
          {'id': '#ORD-002', 'customer': 'Jane Smith', 'amount': 18.75, 'status': 'Preparing'},
          {'id': '#ORD-003', 'customer': 'Bob Johnson', 'amount': 32.00, 'status': 'Confirmed'},
        ],
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalyticsData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),
                    _buildKPICards(),
                    const SizedBox(height: 20),
                    _buildRevenueChart(),
                    const SizedBox(height: 20),
                    _buildTopRestaurants(),
                    const SizedBox(height: 20),
                    _buildRecentOrders(),
                    const SizedBox(height: 20),
                    _buildExportOptions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              'Period:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'day', label: Text('Day')),
                  ButtonSegment(value: 'week', label: Text('Week')),
                  ButtonSegment(value: 'month', label: Text('Month')),
                  ButtonSegment(value: 'year', label: Text('Year')),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedPeriod = selection.first;
                  });
                  _loadAnalyticsData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards() {
    final revenue = _analyticsData['revenue'] ?? {};
    final orders = _analyticsData['orders'] ?? {};
    final users = _analyticsData['users'] ?? {};
    final restaurants = _analyticsData['restaurants'] ?? {};

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildKPICard(
          'Total Revenue',
          '\$${(revenue['total'] ?? 0).toStringAsFixed(0)}',
          '${revenue['growth'] ?? 0}%',
          revenue['growth'] >= 0,
          Icons.attach_money,
          Colors.green,
        ),
        _buildKPICard(
          'Total Orders',
          '${orders['total'] ?? 0}',
          '${orders['growth'] ?? 0}%',
          orders['growth'] >= 0,
          Icons.shopping_bag,
          Colors.blue,
        ),
        _buildKPICard(
          'Total Users',
          '${users['total'] ?? 0}',
          '${users['growth'] ?? 0}%',
          users['growth'] >= 0,
          Icons.people,
          Colors.orange,
        ),
        _buildKPICard(
          'Restaurants',
          '${restaurants['total'] ?? 0}',
          '${restaurants['growth'] ?? 0}%',
          restaurants['growth'] >= 0,
          Icons.restaurant,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, String growth, bool isPositive, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        growth,
                        style: TextStyle(
                          fontSize: 10,
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart will be implemented with a charting library\n(e.g., fl_chart)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRestaurants() {
    final topRestaurants = _analyticsData['topRestaurants'] as List? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performing Restaurants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topRestaurants.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final restaurant = topRestaurants[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(restaurant['name']),
                  subtitle: Text('${restaurant['orders']} orders'),
                  trailing: Text(
                    '\$${restaurant['revenue'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildRecentOrders() {
    final recentOrders = _analyticsData['recentOrders'] as List? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View all orders coming soon!')),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentOrders.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final order = recentOrders[index];
                return ListTile(
                  title: Text(order['id']),
                  subtitle: Text(order['customer']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order['amount']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getOrderStatusColor(order['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            fontSize: 10,
                            color: _getOrderStatusColor(order['status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'preparing':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildExportOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildExportButton('Export PDF', Icons.picture_as_pdf, () {}),
                _buildExportButton('Export Excel', Icons.table_chart, () {}),
                _buildExportButton('Export CSV', Icons.description, () {}),
                _buildExportButton('Email Report', Icons.email, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label functionality coming soon!')),
        );
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
