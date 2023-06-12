import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    required BluetoothDevice device,
    int? rssi,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool enabled = true,
  }) : super(
          onTap: onTap,
          enabled: enabled,
          leading: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.devices,
              color: Colors.grey,
            ),
          ),

          title: Text(
            device.name ?? "",
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            device.address.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          trailing: const CircleAvatar(
            backgroundColor: Colors.black26,
            child: Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
            ),
          ),
        );
}
