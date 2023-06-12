import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'BluetoothDeviceListEntry.dart';
import 'SelectBondedDevicePage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
  List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }


  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          setState(() {
            final existingIndex = results.indexWhere(
                    (element) => element.device.address == r.device.address);
            if (existingIndex >= 0)
              results[existingIndex] = r;
            else
              results.add(r);
          });
        });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("Bluetooth App"),

    ),

    floatingActionButton: FloatingActionButton.extended(
    backgroundColor: Colors.grey[900],
    onPressed: (){
    Navigator.of(context).push(
    MaterialPageRoute(
    builder: (context) {
    return SelectBondedDevicePage();
    }));
    },
    icon: Icon(isDiscovering?Icons.stop:Icons.bluetooth),
    label: const Text("Paired Devices"),
    ),


    body:Column(
    children: [
    Container(
    margin: const EdgeInsets.only(left: 25,right: 25,top: 25,bottom: 5),
    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text("Bluetooth",style: TextStyle(
    color: Colors.white,
    fontSize: 18, fontWeight: FontWeight.w500
    ),),
    CupertinoSwitch(
    activeColor: Colors.blue,
    thumbColor: Colors.white,
    trackColor: Colors.grey,
    value: _bluetoothState.isEnabled,

    onChanged: (bool value) {
    // Do the request and update with the true value then
    future() async {
    // async lambda seems to not working
    if (value) {
    await FlutterBluetoothSerial.instance.requestEnable();

    }
    else {
    await FlutterBluetoothSerial.instance.requestDisable();
    }
    }

    future().then((_) {
    setState(() {

    });
    });
    },
    ),
    ],
    ),
    const SizedBox(
    height: 20,
    ),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text("Device name",style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500
    ),),

    Text(_name,style: const TextStyle(
    color: Colors.grey,
    fontSize: 16,
    fontWeight: FontWeight.w400
    ),),
    ],
    ),
    const SizedBox(
    height: 50,
    ),
    Container(

    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text("AVAILABLE DEVICES",style: TextStyle(
    color: Colors.white,
    fontSize: 20
    ),),

    InkWell(
    onTap: (){
    _startDiscovery();
    setState(() {
    isDiscovering=true;
    });
    },
    child: CircleAvatar(
    radius: 16,
    backgroundColor: Colors.grey,
    child:isDiscovering? SizedBox(width:22,height:22,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,)):Icon(Icons.sync,color: Colors.white),),
    )
    ],
    ),
    ),


    ],
    ),
    ),
    const SizedBox(
    height: 50,
    ),
    ListView.builder(
    shrinkWrap: true,
    physics: ScrollPhysics(),
    itemCount: results.length,
    itemBuilder: (BuildContext context, index) {
    BluetoothDiscoveryResult result = results[index];
    final device = result.device;
    final address = device.address;
    return Container(
    margin: EdgeInsets.all(7),
    decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12)
    ),
    child: BluetoothDeviceListEntry(
    device: device,
    rssi: result.rssi,

    onTap: () async {
    try {
    bool bonded = false;
    if (device.isBonded) {
    print('Unbonding from ${device.address}...');
    await FlutterBluetoothSerial.instance
        .removeDeviceBondWithAddress(address);
    print('Unbonding from ${device.address} has succed');
    } else {
    print('Bonding with ${device.address}...');
    bonded = (await FlutterBluetoothSerial.instance
        .bondDeviceAtAddress(address))!;
    print(
    'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
    }
    setState(() {
    results[results.indexOf(result)] = BluetoothDiscoveryResult(
    device: BluetoothDevice(
    name: device.name ?? '',
    address: address,
    type: device.type,
    bondState: bonded
    ? BluetoothBondState.bonded
        : BluetoothBondState.none,
    ),
    rssi: result.rssi);
    });
    } catch (ex) {
    showDialog(
    context: context,
    builder: (BuildContext context) {
    return AlertDialog(
    title: const Text('Error occured while bonding'),
    content: Text("${ex.toString()}"),
    actions: <Widget>[
    TextButton(
    child: new Text("Close"),
    onPressed: () {
    Navigator.of(context).pop();
    },
    ),
    ],
    );
    },
    );
    }
    },
    ),
    );
    },
    ),
    ],
    ),

    ),
    );
    }
  }

