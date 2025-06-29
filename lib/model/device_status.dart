import '../commons.dart';

class DeviceStatus {
  final String macAddress;
  int sw1;
  int sw2;
  int sw3;
  int led;
  Color currentColor;

  DeviceStatus({
    required this.macAddress,
    this.sw1 = 0,
    this.sw2 = 0,
    this.sw3 = 0,
    this.led = 0,
    this.currentColor = const Color(0xFFFFFFFF),
  });

  // Factory constructor to create from a map (if needed)
  factory DeviceStatus.fromMap(Map<String, dynamic> map) {
    return DeviceStatus(
      macAddress: map['MacAddress'],
      sw1: map['sw1'],
      sw2: map['sw2'],
      sw3: map['sw3'],
      led: map['led'],
      currentColor: Color(map['CurrentColor']),
    );
  }

  // Convert to map (optional, for saving or serialization)
  Map<String, dynamic> toMap() {
    return {
      'MacAddress': macAddress,
      'sw1': sw1,
      'sw2': sw2,
      'sw3': sw3,
      'led': led,
      'CurrentColor': currentColor.value,
    };
  }
}

extension DeviceStatusHelper on DeviceStatus {
  int getSwitchValue(int index) {
    switch (index) {
      case 0:
        return sw1;
      case 1:
        return sw2;
      case 2:
        return sw3;
      case 3:
        return led;
      default:
        throw ArgumentError('Invalid switch index: $index');
    }
  }
}

DeviceStatus? findDeviceByMac(List<DeviceStatus> devices, String macAddress) {
  return devices.firstWhereOrNull((d) => d.macAddress == macAddress);
}
