import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/restaurant.dart';

class RestaurantManagementScreen extends StatefulWidget {
  const RestaurantManagementScreen({super.key});

  @override
  State<RestaurantManagementScreen> createState() => _RestaurantManagementScreenState();
}

class _RestaurantManagementScreenState extends State<RestaurantManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = true;
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    setState(() => _isLoading = true);

    try {
      // Load restaurants from database
      final restaurants = await _databaseService.getRestaurants(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        category: _selectedCategory != 'all' ? _selectedCategory : null,
        status: _selectedStatus != 'all' ? _selectedStatus : null,
      );

      setState(() {
        _restaurants = restaurants;
        _filteredRestaurants = List.from(_restaurants);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading restaurants: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterRestaurants() {
    setState(() {
      _filteredRestaurants = _restaurants.where((restaurant) {
        final matchesSearch = restaurant.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            (restaurant.email?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);

        final matchesStatus = _selectedStatus == 'all' ||
                            (_selectedStatus == 'active' && restaurant.isActive) ||
                            (_selectedStatus == 'inactive' && !restaurant.isActive) ||
                            (_selectedStatus == 'open' && restaurant.isOpen) ||
                            (_selectedStatus == 'closed' && !restaurant.isOpen);

        final matchesCategory = _selectedCategory == 'all' ||
                              (restaurant.categoryName != null && restaurant.categoryName == _selectedCategory);

        return matchesSearch && matchesStatus && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(context),
          _buildRestaurantStats(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRestaurantsList(context),
          ),
        ],
      ),
      floatingActionButton: isMobile ? FloatingActionButton(
        onPressed: _showAddRestaurantDialog,
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    return Card(
      margin: EdgeInsets.all(isMobile ? 8 : 16),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _loadRestaurants(),
            ),
            SizedBox(height: isMobile ? 12 : 16),

            // Filters - responsive layout
            if (isMobile)
              // Mobile: Stack filters vertically
              Column(
                children: [
                  _buildStatusDropdown(),
                  const SizedBox(height: 12),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 12),
                  _buildAddRestaurantButton(),
                ],
              )
            else if (isTablet)
              // Tablet: Two filters in row, button below
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatusDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCategoryDropdown()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildAddRestaurantButton(),
                      const Spacer(),
                    ],
                  ),
                ],
              )
            else
              // Desktop: All in one row
              Row(
                children: [
                  Expanded(flex: 2, child: _buildStatusDropdown()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildCategoryDropdown()),
                  const SizedBox(width: 16),
                  _buildAddRestaurantButton(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Status')),
        DropdownMenuItem(value: 'active', child: Text('Active')),
        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
        DropdownMenuItem(value: 'open', child: Text('Open')),
        DropdownMenuItem(value: 'closed', child: Text('Closed')),
      ],
      onChanged: (value) {
        setState(() => _selectedStatus = value!);
        _loadRestaurants();
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Categories')),
        DropdownMenuItem(value: 'Fast Food', child: Text('Fast Food')),
        DropdownMenuItem(value: 'Pizza', child: Text('Pizza')),
        DropdownMenuItem(value: 'Asian', child: Text('Asian')),
        DropdownMenuItem(value: 'Italian', child: Text('Italian')),
        DropdownMenuItem(value: 'Healthy', child: Text('Healthy')),
      ],
      onChanged: (value) {
        setState(() => _selectedCategory = value!);
        _loadRestaurants();
      },
    );
  }

  Widget _buildAddRestaurantButton() {
    return ElevatedButton.icon(
      onPressed: _showAddRestaurantDialog,
      icon: const Icon(Icons.add),
      label: const Text('Add Restaurant'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildRestaurantStats(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final totalRestaurants = _restaurants.length;
    final activeRestaurants = _restaurants.where((r) => r.isActive).length;
    final openRestaurants = _restaurants.where((r) => r.isOpen).length;
    final featuredRestaurants = _restaurants.where((r) => r.isFeatured).length;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: isMobile
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatItem('Total', totalRestaurants.toString(), Colors.blue, isMobile)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatItem('Active', activeRestaurants.toString(), Colors.green, isMobile)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatItem('Open', openRestaurants.toString(), Colors.orange, isMobile)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatItem('Featured', featuredRestaurants.toString(), Colors.purple, isMobile)),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalRestaurants.toString(), Colors.blue, isMobile),
                _buildStatItem('Active', activeRestaurants.toString(), Colors.green, isMobile),
                _buildStatItem('Open', openRestaurants.toString(), Colors.orange, isMobile),
                _buildStatItem('Featured', featuredRestaurants.toString(), Colors.purple, isMobile),
              ],
            ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsList(BuildContext context) {
    if (_filteredRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    if (isDesktop) {
      return _buildDesktopRestaurantsList();
    } else if (isTablet) {
      return _buildTabletRestaurantsList();
    } else {
      return _buildMobileRestaurantsList();
    }
  }

  Widget _buildMobileRestaurantsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _filteredRestaurants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getRestaurantStatusColor(restaurant),
                      radius: 20,
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (restaurant.categoryName != null)
                            Text(
                              restaurant.categoryName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildStatusIcons(restaurant),
                  ],
                ),
                const SizedBox(height: 8),
                if (restaurant.email != null)
                  Text(
                    restaurant.email!,
                    style: const TextStyle(fontSize: 12),
                  ),
                Text(
                  restaurant.shortAddress,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(
                      ' ${restaurant.rating} (${restaurant.totalReviews})',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    _buildActionButtons(restaurant, true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletRestaurantsList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _filteredRestaurants[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getRestaurantStatusColor(restaurant),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusIcons(restaurant),
                  ],
                ),
                const SizedBox(height: 12),
                if (restaurant.categoryName != null)
                  Text(
                    restaurant.categoryName!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (restaurant.email != null)
                  Text(
                    restaurant.email!,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  restaurant.shortAddress,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(
                      ' ${restaurant.rating} (${restaurant.totalReviews})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButtons(restaurant, false),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopRestaurantsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 60), // Avatar space
                Expanded(flex: 2, child: Text('Restaurant', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Category & Location', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Table rows
          ...List.generate(_filteredRestaurants.length, (index) {
            final restaurant = _filteredRestaurants[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRestaurantStatusColor(restaurant),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (restaurant.description != null)
                          Text(
                            restaurant.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (restaurant.email != null)
                          Text(
                            restaurant.email!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (restaurant.phone != null)
                          Text(
                            restaurant.phone!,
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (restaurant.categoryName != null)
                          Text(
                            restaurant.categoryName!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text(
                          restaurant.shortAddress,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(
                          ' ${restaurant.rating}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildStatusIcons(restaurant),
                  ),
                  SizedBox(
                    width: 120,
                    child: _buildActionButtons(restaurant, false),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusIcons(Restaurant restaurant) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: restaurant.isActive ? 'Active' : 'Inactive',
          child: Icon(
            restaurant.isActive ? Icons.check_circle : Icons.cancel,
            color: restaurant.isActive ? Colors.green : Colors.red,
            size: 16,
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: restaurant.isOpen ? 'Open' : 'Closed',
          child: Icon(
            restaurant.isOpen ? Icons.store : Icons.store_mall_directory,
            color: restaurant.isOpen ? Colors.green : Colors.grey,
            size: 16,
          ),
        ),
        if (restaurant.isFeatured) ...[
          const SizedBox(width: 4),
          Tooltip(
            message: 'Featured',
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(Restaurant restaurant, bool isMobile) {
    if (isMobile) {
      return PopupMenuButton<String>(
        onSelected: (value) => _handleRestaurantAction(restaurant, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility, size: 16),
                SizedBox(width: 8),
                Text('View Details'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: 8),
                Text('Edit Restaurant'),
              ],
            ),
          ),
          PopupMenuItem(
            value: restaurant.isActive ? 'deactivate' : 'activate',
            child: Row(
              children: [
                Icon(
                  restaurant.isActive ? Icons.block : Icons.check_circle,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(restaurant.isActive ? 'Deactivate' : 'Activate'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'menu',
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, size: 16),
                SizedBox(width: 8),
                Text('Manage Menu'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'orders',
            child: Row(
              children: [
                Icon(Icons.receipt_long, size: 16),
                SizedBox(width: 8),
                Text('View Orders'),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _handleRestaurantAction(restaurant, 'view'),
            icon: const Icon(Icons.visibility, size: 18),
            tooltip: 'View Details',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: () => _handleRestaurantAction(restaurant, 'edit'),
            icon: const Icon(Icons.edit, size: 18),
            tooltip: 'Edit Restaurant',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: () => _handleRestaurantAction(
              restaurant,
              restaurant.isActive ? 'deactivate' : 'activate',
            ),
            icon: Icon(
              restaurant.isActive ? Icons.block : Icons.check_circle,
              size: 18,
            ),
            tooltip: restaurant.isActive ? 'Deactivate' : 'Activate',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      );
    }
  }

  Color _getRestaurantStatusColor(Restaurant restaurant) {
    if (!restaurant.isActive) return Colors.red;
    if (!restaurant.isOpen) return Colors.orange;
    return Colors.green;
  }

  void _handleRestaurantAction(Restaurant restaurant, String action) {
    switch (action) {
      case 'view':
        _showRestaurantDetails(restaurant);
        break;
      case 'edit':
        _showEditRestaurantDialog(restaurant);
        break;
      case 'activate':
      case 'deactivate':
        _toggleRestaurantStatus(restaurant);
        break;
      case 'menu':
        _manageRestaurantMenu(restaurant);
        break;
      case 'orders':
        _viewRestaurantOrders(restaurant);
        break;
    }
  }

  void _showRestaurantDetails(Restaurant restaurant) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getRestaurantStatusColor(restaurant),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                restaurant.name,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            _buildStatusIcons(restaurant),
          ],
        ),
        content: Container(
          width: isDesktop ? 600 : (isTablet ? 500 : double.maxFinite),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: isDesktop || isTablet
                ? _buildDesktopDetailsLayout(restaurant)
                : _buildMobileDetailsLayout(restaurant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handleRestaurantAction(restaurant, 'edit');
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDetailsLayout(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (restaurant.description != null) ...[
          Text(
            restaurant.description!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildDetailSection('Contact Information', [
          if (restaurant.email != null) _buildDetailRow('Email', restaurant.email!),
          if (restaurant.phone != null) _buildDetailRow('Phone', restaurant.phone!),
          if (restaurant.website != null) _buildDetailRow('Website', restaurant.website!),
        ]),
        const SizedBox(height: 16),
        _buildDetailSection('Location & Category', [
          if (restaurant.categoryName != null) _buildDetailRow('Category', restaurant.categoryName!),
          _buildDetailRow('Address', restaurant.fullAddress),
        ]),
        const SizedBox(height: 16),
        _buildDetailSection('Business Details', [
          _buildDetailRow('Status', restaurant.isActive ? 'Active' : 'Inactive'),
          _buildDetailRow('Open', restaurant.isOpen ? 'Yes' : 'No'),
          _buildDetailRow('Featured', restaurant.isFeatured ? 'Yes' : 'No'),
          _buildDetailRow('Rating', restaurant.ratingText),
        ]),
        const SizedBox(height: 16),
        _buildDetailSection('Delivery Information', [
          _buildDetailRow('Delivery Fee', '\$${restaurant.deliveryFee.toStringAsFixed(2)}'),
          _buildDetailRow('Min Order', '\$${restaurant.minimumOrderAmount.toStringAsFixed(2)}'),
          _buildDetailRow('Delivery Radius', '${restaurant.deliveryRadius.toStringAsFixed(1)} km'),
          _buildDetailRow('Est. Delivery Time', '${restaurant.estimatedDeliveryTime} min'),
        ]),
        const SizedBox(height: 16),
        _buildDetailSection('System Information', [
          if (restaurant.ownerName != null) _buildDetailRow('Owner', restaurant.ownerName!),
          _buildDetailRow('Created', restaurant.createdAt.toString().split('.')[0]),
          _buildDetailRow('Updated', restaurant.updatedAt.toString().split('.')[0]),
        ]),
      ],
    );
  }

  Widget _buildDesktopDetailsLayout(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (restaurant.description != null) ...[
          Text(
            restaurant.description!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildDetailSection('Contact Information', [
                    if (restaurant.email != null) _buildDetailRow('Email', restaurant.email!),
                    if (restaurant.phone != null) _buildDetailRow('Phone', restaurant.phone!),
                    if (restaurant.website != null) _buildDetailRow('Website', restaurant.website!),
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection('Business Details', [
                    _buildDetailRow('Status', restaurant.isActive ? 'Active' : 'Inactive'),
                    _buildDetailRow('Open', restaurant.isOpen ? 'Yes' : 'No'),
                    _buildDetailRow('Featured', restaurant.isFeatured ? 'Yes' : 'No'),
                    _buildDetailRow('Rating', restaurant.ratingText),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  _buildDetailSection('Location & Category', [
                    if (restaurant.categoryName != null) _buildDetailRow('Category', restaurant.categoryName!),
                    _buildDetailRow('Address', restaurant.fullAddress),
                  ]),
                  const SizedBox(height: 16),
                  _buildDetailSection('Delivery Information', [
                    _buildDetailRow('Delivery Fee', '\$${restaurant.deliveryFee.toStringAsFixed(2)}'),
                    _buildDetailRow('Min Order', '\$${restaurant.minimumOrderAmount.toStringAsFixed(2)}'),
                    _buildDetailRow('Delivery Radius', '${restaurant.deliveryRadius.toStringAsFixed(1)} km'),
                    _buildDetailRow('Est. Delivery Time', '${restaurant.estimatedDeliveryTime} min'),
                  ]),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailSection('System Information', [
          if (restaurant.ownerName != null) _buildDetailRow('Owner', restaurant.ownerName!),
          _buildDetailRow('Created', restaurant.createdAt.toString().split('.')[0]),
          _buildDetailRow('Updated', restaurant.updatedAt.toString().split('.')[0]),
        ]),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditRestaurantDialog(Restaurant restaurant) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit restaurant functionality coming soon!')),
    );
  }

  void _showAddRestaurantDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add restaurant functionality coming soon!')),
    );
  }

  Future<void> _toggleRestaurantStatus(Restaurant restaurant) async {
    final newStatus = !restaurant.isActive;
    final action = newStatus ? 'Activating' : 'Deactivating';

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$action restaurant...')),
      );

      final success = await _databaseService.updateRestaurantStatus(restaurant.id, newStatus);

      if (success) {
        // Reload restaurants to reflect changes
        await _loadRestaurants();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Restaurant ${newStatus ? 'activated' : 'deactivated'} successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to ${newStatus ? 'activate' : 'deactivate'} restaurant'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _manageRestaurantMenu(Restaurant restaurant) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu management coming soon!')),
    );
  }

  void _viewRestaurantOrders(Restaurant restaurant) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restaurant orders view coming soon!')),
    );
  }
}
