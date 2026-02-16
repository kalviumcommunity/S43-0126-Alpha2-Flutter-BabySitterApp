import 'package:flutter/material.dart';
import '../../services/database_check_service.dart';

/// Screen to check database connectivity and status.
class DatabaseCheckScreen extends StatefulWidget {
  const DatabaseCheckScreen({super.key});

  @override
  State<DatabaseCheckScreen> createState() => _DatabaseCheckScreenState();
}

class _DatabaseCheckScreenState extends State<DatabaseCheckScreen> {
  final DatabaseCheckService _dbCheck = DatabaseCheckService();
  Map<String, dynamic>? _connectionStatus;
  Map<String, dynamic>? _userInfo;
  bool _loading = false;

  Future<void> _checkDatabase() async {
    setState(() {
      _loading = true;
      _connectionStatus = null;
    });

    try {
      final status = await _dbCheck.checkDatabaseConnection();
      final userInfo = await _dbCheck.getCurrentUserInfo();

      if (mounted) {
        setState(() {
          _connectionStatus = status;
          _userInfo = userInfo;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectionStatus = {
            'isConnected': false,
            'error': 'Check failed: $e',
          };
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkDatabase,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_connectionStatus != null) ...[
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildCollectionsCard(),
                    const SizedBox(height: 16),
                    _buildCountsCard(),
                  ],
                  if (_userInfo != null) ...[
                    const SizedBox(height: 16),
                    _buildUserInfoCard(),
                  ],
                  if (_connectionStatus?['error'] != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final isConnected = _connectionStatus!['isConnected'] as bool;
    return Card(
      color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              color: isConnected ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Database Connected' : 'Database Not Connected',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isConnected ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Project: ${_connectionStatus!['projectId'] ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsCard() {
    final collections = _connectionStatus!['collections'] as List<dynamic>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collections Found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (collections.isEmpty)
              const Text('No collections accessible')
            else
              ...collections.map((col) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.folder, size: 20),
                        const SizedBox(width: 8),
                        Text(col.toString()),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildCountsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Counts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildCountRow('Users', _connectionStatus!['userCount'] ?? 0),
            _buildCountRow('Babysitters', _connectionStatus!['babysitterCount'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildCountRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current User Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (_userInfo?['email'] != null)
              Text('Email: ${_userInfo!['email']}'),
            if (_userInfo?['uid'] != null)
              Text('UID: ${_userInfo!['uid']}'),
            if (_userInfo?['hasUserDoc'] != null)
              Text(
                'Has User Document: ${_userInfo!['hasUserDoc'] ? 'Yes' : 'No'}',
                style: TextStyle(
                  color: _userInfo!['hasUserDoc'] ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Error Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _connectionStatus!['error'].toString(),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
