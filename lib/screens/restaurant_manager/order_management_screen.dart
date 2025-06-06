import 'package:flutter/material.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  String _selectedStatus = 'all';
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    
    // Simulate loading orders - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    setState(() {
      _orders = [
        Order(
          id: 1,
          orderNumber: 'ORD-001',
          customerName: 'John Doe',
          customerPhone: '+250788123456',
          items: ['2x Margherita Pizza', '1x Caesar Salad'],
          totalAmount: 50.97,
          status: 'pending',
          orderType: 'delivery',
          orderTime: DateTime.now().subtract(const Duration(minutes: 5)),
          estimatedTime: 25,
          specialInstructions: 'Extra cheese on pizza',
        ),
        Order(
          id: 2,
          orderNumber: 'ORD-002',
          customerName: 'Jane Smith',
          customerPhone: '+250788654321',
          items: ['1x Pepperoni Pizza', '2x Chicken Wings'],
          totalAmount: 53.97,
          status: 'preparing',
          orderType: 'pickup',
          orderTime: DateTime.now().subtract(const Duration(minutes: 15)),
          estimatedTime: 10,
          specialInstructions: '',
        ),
        Order(
          id: 3,
          orderNumber: 'ORD-003',
          customerName: 'Bob Johnson',
          customerPhone: '+250788987654',
          items: ['1x Margherita Pizza', '1x Caesar Salad', '2x Beverages'],
          totalAmount: 45.96,
          status: 'ready',
          orderType: 'delivery',
          orderTime: DateTime.now().subtract(const Duration(minutes: 30)),
          estimatedTime: 0,
          specialInstructions: 'Call when arriving',
        ),
        Order(
          id: 4,
          orderNumber: 'ORD-004',
          customerName: 'Alice Brown',
          customerPhone: '+250788456789',
          items: ['3x Chicken Wings', '1x Beverage'],
          totalAmount: 32.97,
          status: 'delivered',
          orderType: 'delivery',
          orderTime: DateTime.now().subtract(const Duration(hours: 1)),
          estimatedTime: 0,
          specialInstructions: '',
        ),
      ];
      _filteredOrders = List.from(_orders);
      _isLoading = false;
    });
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        final matchesSearch = order.orderNumber.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            order.customerName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            order.customerPhone.contains(_searchController.text);
        
        final matchesStatus = _selectedStatus == 'all' || order.status == _selectedStatus;
        final matchesType = _selectedType == 'all' || order.orderType == _selectedType;
        
        return matchesSearch && matchesStatus && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildOrderStats(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _filterOrders(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                      DropdownMenuItem(value: 'preparing', child: Text('Preparing')),
                      DropdownMenuItem(value: 'ready', child: Text('Ready')),
                      DropdownMenuItem(value: 'picked_up', child: Text('Picked Up')),
                      DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      _filterOrders();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Types')),
                      DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                      DropdownMenuItem(value: 'pickup', child: Text('Pickup')),
                      DropdownMenuItem(value: 'dine_in', child: Text('Dine In')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                      _filterOrders();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStats() {
    final totalOrders = _orders.length;
    final pendingOrders = _orders.where((o) => o.status == 'pending' || o.status == 'confirmed').length;
    final preparingOrders = _orders.where((o) => o.status == 'preparing').length;
    final readyOrders = _orders.where((o) => o.status == 'ready').length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', totalOrders.toString(), Colors.blue),
            _buildStatItem('Pending', pendingOrders.toString(), Colors.orange),
            _buildStatItem('Preparing', preparingOrders.toString(), Colors.purple),
            _buildStatItem('Ready', readyOrders.toString(), Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    if (_filteredOrders.isEmpty) {
      return const Center(
        child: Text('No orders found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getOrderStatusColor(order.status),
              child: Text(
                order.orderNumber.split('-')[1],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text('${order.orderNumber} - ${order.customerName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${order.totalAmount.toStringAsFixed(2)} • ${order.orderType}'),
                Text(_formatOrderTime(order.orderTime)),
                if (order.estimatedTime > 0)
                  Text('Est. ${order.estimatedTime} min remaining'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getOrderStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusDisplayName(order.status),
                style: TextStyle(
                  color: _getOrderStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $item'),
                    )),
                    if (order.specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Special Instructions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(order.specialInstructions),
                    ],
                    const SizedBox(height: 8),
                    Text('Customer: ${order.customerPhone}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _buildOrderActions(order),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildOrderActions(Order order) {
    List<Widget> actions = [];

    switch (order.status) {
      case 'pending':
        actions.addAll([
          ElevatedButton.icon(
            onPressed: () => _updateOrderStatus(order, 'confirmed'),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          OutlinedButton.icon(
            onPressed: () => _updateOrderStatus(order, 'cancelled'),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ]);
        break;
      case 'confirmed':
        actions.add(
          ElevatedButton.icon(
            onPressed: () => _updateOrderStatus(order, 'preparing'),
            icon: const Icon(Icons.restaurant, size: 16),
            label: const Text('Start Preparing'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        );
        break;
      case 'preparing':
        actions.add(
          ElevatedButton.icon(
            onPressed: () => _updateOrderStatus(order, 'ready'),
            icon: const Icon(Icons.done, size: 16),
            label: const Text('Mark Ready'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        );
        break;
      case 'ready':
        if (order.orderType == 'pickup') {
          actions.add(
            ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(order, 'picked_up'),
              icon: const Icon(Icons.person, size: 16),
              label: const Text('Picked Up'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          );
        } else {
          actions.add(
            ElevatedButton.icon(
              onPressed: () => _updateOrderStatus(order, 'delivered'),
              icon: const Icon(Icons.delivery_dining, size: 16),
              label: const Text('Out for Delivery'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          );
        }
        break;
    }

    actions.add(
      TextButton.icon(
        onPressed: () => _callCustomer(order),
        icon: const Icon(Icons.phone, size: 16),
        label: const Text('Call'),
      ),
    );

    return actions;
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'picked_up':
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'picked_up':
        return 'Picked Up';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatOrderTime(DateTime orderTime) {
    final now = DateTime.now();
    final difference = now.difference(orderTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _updateOrderStatus(Order order, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Text('Change order ${order.orderNumber} status to ${_getStatusDisplayName(newStatus)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order.orderNumber} status updated to ${_getStatusDisplayName(newStatus)}')),
              );
              // TODO: Implement actual status update
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _callCustomer(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${order.customerName} at ${order.customerPhone}')),
    );
    // TODO: Implement actual phone call functionality
  }
}

// Order model
class Order {
  final int id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final List<String> items;
  final double totalAmount;
  final String status;
  final String orderType;
  final DateTime orderTime;
  final int estimatedTime;
  final String specialInstructions;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderType,
    required this.orderTime,
    required this.estimatedTime,
    required this.specialInstructions,
  });
}
