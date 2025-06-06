import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/role_based_navigation.dart';
import '../../models/api_response.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isRefreshing = false;
  List<User> _users = [];
  List<User> _filteredUsers = [];
  String _selectedRole = 'all';
  String _selectedStatus = 'all';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _databaseService.getUsers(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        role: _selectedRole != 'all' ? _selectedRole : null,
        status: _selectedStatus != 'all' ? _selectedStatus : null,
        token: _authService.authToken,
      );

      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = List.from(_users);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load users: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _refreshUsers() async {
    if (!mounted) return;

    setState(() => _isRefreshing = true);

    try {
      final users = await _databaseService.getUsers(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        role: _selectedRole != 'all' ? _selectedRole : null,
        status: _selectedStatus != 'all' ? _selectedStatus : null,
        token: _authService.authToken,
      );

      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = List.from(_users);
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _errorMessage = 'Failed to refresh users: ${e.toString()}';
        });
      }
    }
  }

  void _filterUsers() {
    // Reload users from database with new filters
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1200;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: _buildResponsiveLayout(screenSize, isTablet, isDesktop),
      ),
      floatingActionButton: _buildFloatingActionButton(isTablet),
    );
  }

  Widget _buildResponsiveLayout(Size screenSize, bool isTablet, bool isDesktop) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading users...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      return _buildDesktopLayout(screenSize);
    } else if (isTablet) {
      return _buildTabletLayout(screenSize);
    } else {
      return _buildMobileLayout(screenSize);
    }
  }

  Widget _buildDesktopLayout(Size screenSize) {
    return Row(
      children: [
        // Sidebar with filters
        Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndFilters(isCompact: false),
              const SizedBox(height: 16),
              _buildUserStats(isVertical: true),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildUsersList(isDesktop: true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(Size screenSize) {
    return Column(
      children: [
        _buildSearchAndFilters(isCompact: false),
        _buildUserStats(isVertical: false),
        _buildHeader(),
        Expanded(child: _buildUsersList(isTablet: true)),
      ],
    );
  }

  Widget _buildMobileLayout(Size screenSize) {
    return Column(
      children: [
        _buildSearchAndFilters(isCompact: true),
        _buildUserStats(isVertical: false),
        Expanded(child: _buildUsersList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Users (${_filteredUsers.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_isRefreshing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isTablet) {
    return FloatingActionButton.extended(
      onPressed: _showAddUserDialog,
      icon: const Icon(Icons.add),
      label: Text(isTablet ? 'Add User' : 'Add'),
    );
  }

  Widget _buildSearchAndFilters({required bool isCompact}) {
    return Card(
      margin: EdgeInsets.all(isCompact ? 8 : 16),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCompact) ...[
              Text(
                'Search & Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 12 : 16,
                  vertical: isCompact ? 8 : 12,
                ),
              ),
              onChanged: (_) => _filterUsers(),
            ),
            SizedBox(height: isCompact ? 12 : 16),
            if (isCompact)
              Column(
                children: [
                  _buildRoleDropdown(),
                  const SizedBox(height: 12),
                  _buildStatusDropdown(),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: _buildRoleDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatusDropdown()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Roles')),
        DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
        DropdownMenuItem(value: 'restaurant_owner', child: Text('Restaurant Owner')),
        DropdownMenuItem(value: 'restaurant_manager', child: Text('Restaurant Manager')),
        DropdownMenuItem(value: 'delivery_driver', child: Text('Delivery Driver')),
        DropdownMenuItem(value: 'customer', child: Text('Customer')),
      ],
      onChanged: (value) {
        setState(() => _selectedRole = value!);
        _filterUsers();
      },
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
      ],
      onChanged: (value) {
        setState(() => _selectedStatus = value!);
        _filterUsers();
      },
    );
  }

  Widget _buildUserStats({required bool isVertical}) {
    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => u.isActive).length;
    final verifiedUsers = _users.where((u) => u.isVerified).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isVertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem('Total', totalUsers.toString(), Colors.blue, isVertical: true),
                  const SizedBox(height: 12),
                  _buildStatItem('Active', activeUsers.toString(), Colors.green, isVertical: true),
                  const SizedBox(height: 12),
                  _buildStatItem('Verified', verifiedUsers.toString(), Colors.orange, isVertical: true),
                  const SizedBox(height: 12),
                  _buildStatItem('Filtered', _filteredUsers.length.toString(), Colors.purple, isVertical: true),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', totalUsers.toString(), Colors.blue),
                  _buildStatItem('Active', activeUsers.toString(), Colors.green),
                  _buildStatItem('Verified', verifiedUsers.toString(), Colors.orange),
                  _buildStatItem('Filtered', _filteredUsers.length.toString(), Colors.purple),
                ],
              ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, {bool isVertical = false}) {
    if (isVertical) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
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
            ),
          ],
        ),
      );
    }

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

  Widget _buildUsersList({bool isDesktop = false, bool isTablet = false}) {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      return _buildDesktopUsersList();
    } else if (isTablet) {
      return _buildTabletUsersList();
    } else {
      return _buildMobileUsersList();
    }
  }

  Widget _buildDesktopUsersList() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 56), // Avatar space
                  const Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 1, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 1, child: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 80), // Actions space
                ],
              ),
            ),
            // Table rows
            ...List.generate(_filteredUsers.length, (index) {
              final user = _filteredUsers[index];
              return _buildDesktopUserRow(user, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopUserRow(User user, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: RoleBasedNavigation.getRoleColor(user.roleName),
            child: Text(
              user.firstName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (user.phone != null)
                  Text(
                    user.phone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(user.email),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RoleBasedNavigation.getRoleColor(user.roleName).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                RoleBasedNavigation.getRoleDisplayName(user.roleName),
                style: TextStyle(
                  color: RoleBasedNavigation.getRoleColor(user.roleName),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(
                  user.isActive ? Icons.check_circle : Icons.cancel,
                  color: user.isActive ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(
                  user.isVerified ? Icons.verified : Icons.pending,
                  color: user.isVerified ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isVerified ? 'Yes' : 'No',
                  style: TextStyle(
                    color: user.isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showUserDetails(user),
                  tooltip: 'View Details',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleUserAction(user, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit User'),
                    ),
                    PopupMenuItem(
                      value: user.isActive ? 'deactivate' : 'activate',
                      child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete User'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletUsersList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user, isTablet: true);
      },
    );
  }

  Widget _buildMobileUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user, {bool isTablet = false}) {
    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 0 : 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isTablet ? 24 : 20,
                    backgroundColor: RoleBasedNavigation.getRoleColor(user.roleName),
                    child: Text(
                      user.firstName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 14 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleUserAction(user, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit User'),
                      ),
                      PopupMenuItem(
                        value: user.isActive ? 'deactivate' : 'activate',
                        child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete User'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RoleBasedNavigation.getRoleColor(user.roleName).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  RoleBasedNavigation.getRoleDisplayName(user.roleName),
                  style: TextStyle(
                    color: RoleBasedNavigation.getRoleColor(user.roleName),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    user.isActive ? Icons.check_circle : Icons.cancel,
                    color: user.isActive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: user.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    user.isVerified ? Icons.verified : Icons.pending,
                    color: user.isVerified ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.isVerified ? 'Verified' : 'Pending',
                    style: TextStyle(
                      color: user.isVerified ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (user.phone != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.phone!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleUserAction(User user, String action) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetails(User user) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: RoleBasedNavigation.getRoleColor(user.roleName),
              child: Text(
                user.firstName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${user.firstName} ${user.lastName}'),
                  Text(
                    RoleBasedNavigation.getRoleDisplayName(user.roleName),
                    style: TextStyle(
                      fontSize: 14,
                      color: RoleBasedNavigation.getRoleColor(user.roleName),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: isLargeScreen ? 400 : double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('UUID', user.uuid),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Verified', user.isVerified ? 'Yes' : 'No'),
              if (user.phone != null) _buildDetailRow('Phone', user.phone!),
              if (user.dateOfBirth != null) _buildDetailRow('Date of Birth', user.dateOfBirth!),
              if (user.gender != null) _buildDetailRow('Gender', user.gender!),
              _buildDetailRow('Created', _formatDate(user.createdAt)),
              _buildDetailRow('Updated', _formatDate(user.updatedAt)),
              if (user.lastLoginAt != null) _buildDetailRow('Last Login', _formatDate(user.lastLoginAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditUserDialog(user);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  void _showEditUserDialog(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit user functionality coming soon!')),
    );
  }

  void _showAddUserDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add user functionality coming soon!')),
    );
  }

  Future<void> _toggleUserStatus(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.isActive ? 'Deactivate' : 'Activate'} User'),
        content: Text(
          'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.firstName} ${user.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.red : Colors.green,
            ),
            child: Text(user.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _databaseService.updateUserStatus(
          user.id,
          !user.isActive,
          token: _authService.authToken,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User ${user.isActive ? 'deactivated' : 'activated'} successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers(); // Refresh the list
        } else {
          throw Exception('Failed to update user status');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${user.firstName} ${user.lastName}?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _databaseService.deleteUser(
          user.id,
          token: _authService.authToken,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers(); // Refresh the list
        } else {
          throw Exception('Failed to delete user');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
