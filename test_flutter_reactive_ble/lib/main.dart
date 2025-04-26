import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:test_flutter_reactive_ble/src/ble/ble_device_connector.dart';
import 'package:test_flutter_reactive_ble/src/ble/ble_device_interactor.dart';
import 'package:test_flutter_reactive_ble/src/ble/ble_scanner.dart';
import 'package:test_flutter_reactive_ble/src/ble/ble_status_monitor.dart';
import 'package:test_flutter_reactive_ble/src/ui/ble_status_screen.dart';
import 'package:test_flutter_reactive_ble/src/ui/device_list.dart';
import 'package:provider/provider.dart';

import 'src/ble/ble_logger.dart';

const _themeColor = Colors.lightGreen;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  final connector = BleDeviceConnector(
    ble: ble,
    logMessage: bleLogger.addToLog,
  );
  final serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: (deviceId) async {
      await ble.discoverAllServices(deviceId);
      return ble.getDiscoveredServices(deviceId);
    },
    logMessage: bleLogger.addToLog,
    readRssi: ble.readRssi,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: scanner),
        Provider.value(value: monitor),
        Provider.value(value: connector),
        Provider.value(value: serviceDiscoverer),
        Provider.value(value: bleLogger),
        StreamProvider<BleScannerState?>(
          create: (_) => scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Reactive BLE example',
        color: _themeColor,
        theme: ThemeData(primarySwatch: _themeColor),
        home: const HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
    builder: (_, status, __) {
      if (status == BleStatus.ready) {
        return const DeviceListScreen();
      } else {
        return BleStatusScreen(status: status ?? BleStatus.unknown);
      }
    },
  );
}
