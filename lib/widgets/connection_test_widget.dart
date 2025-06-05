import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ConnectionTestWidget extends StatefulWidget {
  const ConnectionTestWidget({super.key});

  @override
  State<ConnectionTestWidget> createState() => _ConnectionTestWidgetState();
}

class _ConnectionTestWidgetState extends State<ConnectionTestWidget> {
  bool _isLoading = false;
  bool? _isConnected;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _isConnected = null;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final isConnected = await authService.testConnection();
      
      setState(() {
        _isConnected = isConnected;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: _isConnected == true 
                      ? Colors.green 
                      : _isConnected == false 
                          ? Colors.red 
                          : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Backend Connection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _testConnection,
                    tooltip: 'Test Connection',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Text('Testing connection...')
            else if (_isConnected == true)
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Connected to backend API',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              )
            else if (_isConnected == false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Connection failed',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Make sure XAMPP is running and the backend is accessible at:\nhttp://localhost/clone/ikiraha_mobile/backend/api/',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
