import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'db_helper.dart';
import 'timing_selection_screen.dart';
import 'sync_service.dart';

class FranchiseSelectionScreen extends StatefulWidget {
  const FranchiseSelectionScreen({super.key});

  @override
  _FranchiseSelectionScreenState createState() => _FranchiseSelectionScreenState();
}

class _FranchiseSelectionScreenState extends State<FranchiseSelectionScreen> {
  List<Map<String, dynamic>> franchises = [];
  final DBHelper dbHelper = DBHelper.instance;
  final SyncService syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _loadFranchises();
  }

  Future<void> _loadFranchises() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Offline mode
      franchises = await dbHelper.getFranchises();
    } else {
      // Online mode
      await syncService.synchronizeData();
      franchises = await dbHelper.getFranchises();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Franchise'),
      ),
      body: ListView.builder(
        itemCount: franchises.length,
        itemBuilder: (context, index) {
          final franchise = franchises[index];
          return ListTile(
            title: Text(franchise['franchise_name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimingSelectionScreen(franchiseId: franchise['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
