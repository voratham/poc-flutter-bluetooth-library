import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:test_flutter_reactive_ble/src/ble/ble_device_connector.dart';
import 'package:test_flutter_reactive_ble/src/ui/device_detail/device_log_tab.dart';
import 'package:provider/provider.dart';

import 'device_interaction_tab.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceDetailScreen({required this.device, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceConnector>(
    builder:
        (_, deviceConnector, __) => _DeviceDetail(
          device: device,
          disconnect: deviceConnector.disconnect,
        ),
  );
}

class _DeviceDetail extends StatelessWidget {
  const _DeviceDetail({
    required this.device,
    required this.disconnect,
    Key? key,
  }) : super(key: key);

  final DiscoveredDevice device;
  final void Function(String deviceId) disconnect;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: true,
    onPopInvoked: (_) async {
      disconnect(device.id);
    },
    child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.name.isNotEmpty ? device.name : "Unnamed"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bluetooth_connected)),
              Tab(icon: Icon(Icons.find_in_page_sharp)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DeviceInteractionTab(device: device),
            const DeviceLogTab(),
          ],
        ),
      ),
    ),
  );
}
