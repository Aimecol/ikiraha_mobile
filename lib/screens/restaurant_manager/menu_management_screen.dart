import 'package:flutter/material.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<MenuItem> _menuItems = [];
  List<MenuItem> _filteredItems = [];
  String _selectedCategory = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);
    
    // Simulate loading menu items - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    setState(() {
      _menuItems = [
        MenuItem(
          id: 1,
          name: 'Margherita Pizza',
          description: 'Classic pizza with tomato sauce, mozzarella, and basil',
          price: 18.99,
          category: 'Pizza',
          isAvailable: true,
          isVegetarian: true,
          preparationTime: 15,
          stock: 25,
          lowStockThreshold: 5,
        ),
        MenuItem(
          id: 2,
          name: 'Pepperoni Pizza',
          description: 'Pizza with pepperoni, mozzarella, and tomato sauce',
          price: 21.99,
          category: 'Pizza',
          isAvailable: true,
          isVegetarian: false,
          preparationTime: 15,
          stock: 3,
          lowStockThreshold: 5,
        ),
        MenuItem(
          id: 3,
          name: 'Caesar Salad',
          description: 'Fresh romaine lettuce with Caesar dressing and croutons',
          price: 12.99,
          category: 'Salads',
          isAvailable: false,
          isVegetarian: true,
          preparationTime: 8,
          stock: 0,
          lowStockThreshold: 3,
        ),
        MenuItem(
          id: 4,
          name: 'Chicken Wings',
          description: 'Spicy buffalo chicken wings with ranch dip',
          price: 15.99,
          category: 'Appetizers',
          isAvailable: true,
          isVegetarian: false,
          preparationTime: 12,
          stock: 18,
          lowStockThreshold: 8,
        ),
      ];
      _filteredItems = List.from(_menuItems);
      _isLoading = false;
    });
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _menuItems.where((item) {
        final matchesSearch = item.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            item.description.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesCategory = _selectedCategory == 'all' || item.category == _selectedCategory;
        final matchesStatus = _selectedStatus == 'all' || 
                            (_selectedStatus == 'available' && item.isAvailable) ||
                            (_selectedStatus == 'unavailable' && !item.isAvailable) ||
                            (_selectedStatus == 'low_stock' && item.stock <= item.lowStockThreshold);
        
        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildMenuStats(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMenuItemsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
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
                hintText: 'Search menu items...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _filterItems(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Categories')),
                      DropdownMenuItem(value: 'Pizza', child: Text('Pizza')),
                      DropdownMenuItem(value: 'Salads', child: Text('Salads')),
                      DropdownMenuItem(value: 'Appetizers', child: Text('Appetizers')),
                      DropdownMenuItem(value: 'Beverages', child: Text('Beverages')),
                      DropdownMenuItem(value: 'Desserts', child: Text('Desserts')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategory = value!);
                      _filterItems();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'available', child: Text('Available')),
                      DropdownMenuItem(value: 'unavailable', child: Text('Unavailable')),
                      DropdownMenuItem(value: 'low_stock', child: Text('Low Stock')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      _filterItems();
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

  Widget _buildMenuStats() {
    final totalItems = _menuItems.length;
    final availableItems = _menuItems.where((i) => i.isAvailable).length;
    final lowStockItems = _menuItems.where((i) => i.stock <= i.lowStockThreshold).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', totalItems.toString(), Colors.blue),
            _buildStatItem('Available', availableItems.toString(), Colors.green),
            _buildStatItem('Low Stock', lowStockItems.toString(), Colors.red),
            _buildStatItem('Filtered', _filteredItems.length.toString(), Colors.purple),
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

  Widget _buildMenuItemsList() {
    if (_filteredItems.isEmpty) {
      return const Center(
        child: Text('No menu items found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getItemStatusColor(item),
              child: Text(
                item.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('\$${item.price.toStringAsFixed(2)}'),
                    const SizedBox(width: 8),
                    Text('• ${item.category}'),
                    const SizedBox(width: 8),
                    Text('• ${item.preparationTime}min'),
                    if (item.isVegetarian) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.eco, size: 16, color: Colors.green),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Text('Stock: ${item.stock}'),
                    if (item.stock <= item.lowStockThreshold)
                      const Text(
                        ' (Low)',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: item.isAvailable ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleItemAction(item, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Item'),
                    ),
                    PopupMenuItem(
                      value: item.isAvailable ? 'disable' : 'enable',
                      child: Text(item.isAvailable ? 'Disable' : 'Enable'),
                    ),
                    const PopupMenuItem(
                      value: 'stock',
                      child: Text('Update Stock'),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate'),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getItemStatusColor(MenuItem item) {
    if (!item.isAvailable) return Colors.red;
    if (item.stock <= item.lowStockThreshold) return Colors.orange;
    return Colors.green;
  }

  void _handleItemAction(MenuItem item, String action) {
    switch (action) {
      case 'view':
        _showItemDetails(item);
        break;
      case 'edit':
        _showEditItemDialog(item);
        break;
      case 'enable':
      case 'disable':
        _toggleItemAvailability(item);
        break;
      case 'stock':
        _showUpdateStockDialog(item);
        break;
      case 'duplicate':
        _duplicateItem(item);
        break;
    }
  }

  void _showItemDetails(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Price', '\$${item.price.toStringAsFixed(2)}'),
            _buildDetailRow('Category', item.category),
            _buildDetailRow('Preparation Time', '${item.preparationTime} minutes'),
            _buildDetailRow('Stock', '${item.stock} units'),
            _buildDetailRow('Low Stock Threshold', '${item.lowStockThreshold} units'),
            _buildDetailRow('Available', item.isAvailable ? 'Yes' : 'No'),
            _buildDetailRow('Vegetarian', item.isVegetarian ? 'Yes' : 'No'),
            const SizedBox(height: 8),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(item.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditItemDialog(MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit item functionality coming soon!')),
    );
  }

  void _showAddItemDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add item functionality coming soon!')),
    );
  }

  void _toggleItemAvailability(MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.isAvailable ? 'Disabling' : 'Enabling'} ${item.name}...')),
    );
  }

  void _showUpdateStockDialog(MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update stock functionality coming soon!')),
    );
  }

  void _duplicateItem(MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicating ${item.name}...')),
    );
  }
}

// MenuItem model
class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final bool isVegetarian;
  final int preparationTime;
  final int stock;
  final int lowStockThreshold;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.isVegetarian,
    required this.preparationTime,
    required this.stock,
    required this.lowStockThreshold,
  });
}
