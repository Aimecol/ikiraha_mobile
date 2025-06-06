import 'package:flutter/material.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _settings = {};
  
  final _appNameController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final _deliveryRadiusController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _supportPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _commissionRateController.dispose();
    _deliveryRadiusController.dispose();
    _minOrderAmountController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    // Simulate loading settings - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data based on database schema
    setState(() {
      _settings = {
        'app_name': 'Ikiraha',
        'app_version': '1.0.0',
        'default_currency': 'USD',
        'default_language': 'en',
        'commission_rate': '15.00',
        'delivery_radius': '25.00',
        'minimum_order_amount': '10.00',
        'max_delivery_time': '120',
        'customer_support_email': 'support@ikiraha.com',
        'customer_support_phone': '+250788123456',
        'maintenance_mode': false,
        'allow_registration': true,
        'email_verification_required': true,
        'phone_verification_required': false,
      };
      
      // Populate controllers
      _appNameController.text = _settings['app_name'] ?? '';
      _commissionRateController.text = _settings['commission_rate'] ?? '';
      _deliveryRadiusController.text = _settings['delivery_radius'] ?? '';
      _minOrderAmountController.text = _settings['minimum_order_amount'] ?? '';
      _supportEmailController.text = _settings['customer_support_email'] ?? '';
      _supportPhoneController.text = _settings['customer_support_phone'] ?? '';
      
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Saving settings...'),
          ],
        ),
      ),
    );

    // Simulate saving - replace with actual API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGeneralSettings(),
                  const SizedBox(height: 20),
                  _buildBusinessSettings(),
                  const SizedBox(height: 20),
                  _buildSystemSettings(),
                  const SizedBox(height: 20),
                  _buildSupportSettings(),
                  const SizedBox(height: 20),
                  _buildSecuritySettings(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _appNameController,
              decoration: const InputDecoration(
                labelText: 'Application Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _settings['default_currency'],
                    decoration: const InputDecoration(
                      labelText: 'Default Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                      DropdownMenuItem(value: 'RWF', child: Text('RWF - Rwandan Franc')),
                    ],
                    onChanged: (value) {
                      setState(() => _settings['default_currency'] = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _settings['default_language'],
                    decoration: const InputDecoration(
                      labelText: 'Default Language',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'fr', child: Text('French')),
                      DropdownMenuItem(value: 'rw', child: Text('Kinyarwanda')),
                      DropdownMenuItem(value: 'sw', child: Text('Swahili')),
                    ],
                    onChanged: (value) {
                      setState(() => _settings['default_language'] = value);
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

  Widget _buildBusinessSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commissionRateController,
                    decoration: const InputDecoration(
                      labelText: 'Commission Rate (%)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _deliveryRadiusController,
                    decoration: const InputDecoration(
                      labelText: 'Delivery Radius (km)',
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _minOrderAmountController,
              decoration: InputDecoration(
                labelText: 'Minimum Order Amount',
                border: const OutlineInputBorder(),
                prefixText: '${_settings['default_currency']} ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Maintenance Mode'),
              subtitle: const Text('Disable app for maintenance'),
              value: _settings['maintenance_mode'] ?? false,
              onChanged: (value) {
                setState(() => _settings['maintenance_mode'] = value);
              },
            ),
            SwitchListTile(
              title: const Text('Allow New Registrations'),
              subtitle: const Text('Allow new users to register'),
              value: _settings['allow_registration'] ?? true,
              onChanged: (value) {
                setState(() => _settings['allow_registration'] = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _supportEmailController,
              decoration: const InputDecoration(
                labelText: 'Support Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _supportPhoneController,
              decoration: const InputDecoration(
                labelText: 'Support Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Email Verification Required'),
              subtitle: const Text('Require email verification for new users'),
              value: _settings['email_verification_required'] ?? true,
              onChanged: (value) {
                setState(() => _settings['email_verification_required'] = value);
              },
            ),
            SwitchListTile(
              title: const Text('Phone Verification Required'),
              subtitle: const Text('Require phone verification for new users'),
              value: _settings['phone_verification_required'] ?? false,
              onChanged: (value) {
                setState(() => _settings['phone_verification_required'] = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loadSettings,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Changes'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('System backup functionality coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.backup),
                  label: const Text('Backup System'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Clear cache functionality coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Cache'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
