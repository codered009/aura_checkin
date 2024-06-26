// main.dart
import 'package:flutter/material.dart';
import 'initial_selection_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'location_service.dart';
import 'splash_screen.dart'; // Adjust the import as needed
import 'sync_service.dart';
import 'qr_check_in_page.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await LocationService().sendLocationInBackground();
    return Future.value(true);
  });
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask("1", "locationBackgroundTask", frequency: const Duration(minutes: 15));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
    final SyncService syncService = SyncService();
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Checkin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
        home: FutureBuilder(
        future: syncService.synchronizeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return QRCheckInPage();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
