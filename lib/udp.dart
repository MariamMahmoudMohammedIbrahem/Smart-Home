import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'db/functions.dart';

class UDPScreen extends StatefulWidget {
  const UDPScreen({super.key});

  @override
  State<UDPScreen> createState() => _UDPScreenState();
}

class _UDPScreenState extends State<UDPScreen> {
  void sendFrame(Map<String, dynamic> jsonFrame, String ipAddress, int port) {
    String frame = jsonEncode(jsonFrame);

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print(jsonFrame);
      socket.broadcastEnabled = true;
      socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
    });
  }

  void showSnack(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  int _currentStep = 0;
  IconData _selectedIcon = Icons.living_sharp;

  List<Step> getSteps() {
    return [
      Step(
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        title: const Text(''),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flex(
                direction: Axis.vertical,
                children: [
                  Text(
                    'Connecting To The Device',
                    style: TextStyle(
                      color: Colors.pink.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'go to the wifi lists and connect to \'EsPap\' Network',
                    style: TextStyle(
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ///TODO: change image
                  Image.asset(
                    'images/light-control.gif',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Step(
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        title: const Text(''),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Text(
                'Wifi Network Configuration',
                style: TextStyle(
                  color: Colors.pink.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Please add your home\'s Wifi Network Name and Password',
                style: TextStyle(
                  fontSize: 23,
                ),
                textAlign: TextAlign.center,
              ),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Wifi Network Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your Wifi Network\'s name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        name = nameController.text;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Wifi Network Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              eye = !eye;
                            });
                          },
                          icon: Icon(
                            eye
                                ? Icons.remove_red_eye_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      obscureText: eye,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your Wifi Network\'s password';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        password = passwordController.text;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 2,
        title: const Text(''),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flex(
                direction: Axis.vertical,
                children: [
                  Text(
                    'Check connection',
                    style: TextStyle(
                      color: Colors.pink.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Please Make Sure That you are connected to the Wifi Network that your Device is connected to',
                    style: TextStyle(
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ///TODO: change image
                  Image.asset(
                    'images/light-control.gif',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Step(
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 3,
        title: const Text(''),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Text(
                'choose your room name',
                style: TextStyle(
                  color: Colors.pink.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'make sure that you are connected to the previous wifi network and choose room name',
                style: TextStyle(
                  fontSize: 23,
                ),
                textAlign: TextAlign.center,
              ),
              SingleChildScrollView(
                child: DropdownButton<IconData>(
                  value: _selectedIcon,
                  menuMaxHeight: 200,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (IconData? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _selectedIcon = newValue;
                      }
                    });
                  },
                  items: iconsRooms.map<DropdownMenuItem<IconData>>((IconData icon) {
                    return DropdownMenuItem<IconData>(
                      value: icon,
                      child: Row(
                        children: [
                          Icon(icon),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            getRoomName(icon),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          roomName = getRoomName(icon);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context)
                  .colorScheme
                  .copyWith(onSurface: Colors.pink.shade200,
                  primary: Colors.pink.shade900)),
          child: Stepper(
            steps: getSteps(),
            physics: const ScrollPhysics(),
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepCancel: () => _currentStep == 0
                ? null
                : setState(() {
                    _currentStep -= 1;
                  }),
            onStepContinue: () {
              bool isLastStep = (_currentStep == getSteps().length - 1);
              if (isLastStep) {
                //Do something with this information
              } else {
                setState(() {
                  _currentStep += 1;
                });
              }
            },
            onStepTapped: (step) {},
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return Row(
                mainAxisAlignment:
                    _currentStep != 0 && !Provider.of<AuthProvider>(context).configured && !!Provider.of<AuthProvider>(context).connectionSuccess
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: (_currentStep != 0 && Provider.of<AuthProvider>(context).readOnly) ||
                        (_currentStep == 1 && !Provider.of<AuthProvider>(context).configured) ||
                        (_currentStep == 2 && !!Provider.of<AuthProvider>(context).connectionSuccess) ||
                        !!Provider.of<AuthProvider>(context).roomConfig,
                    child: Expanded(
                      child: SizedBox(
                        // width: width * .4,
                        child: ElevatedButton(
                          onPressed: controls.onStepCancel,
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.pink.shade900,
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.pink.shade900,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Consumer<AuthProvider>(
                        builder: (context, booleanProvider, child) {
                          return ElevatedButton(
                            onPressed: () {
                              if (_currentStep == 0) {
                                if (booleanProvider.readOnly) {
                                  if (items.containsKey(booleanProvider.macAddress)) {
                                    showSnack(context,
                                        'you already have this device configured');
                                  } else {
                                    controls.onStepContinue!();
                                  }
                                } else {
                                  sendFrame(
                                    {"commands": 'MAC_ADDRESS_READ'},
                                    '255.255.255.255',
                                    8888,
                                  );
                                }
                              }
                              else if (_currentStep == 2) {
                                if (booleanProvider.connectionSuccess) {
                                  controls.onStepContinue!();
                                } else {
                                  sendFrame(
                                    {
                                      "commands": 'WIFI_CONNECT_CHECK',
                                      "mac_address": booleanProvider.macAddress,
                                    },
                                    '255.255.255.255',
                                    8888,
                                  );
                                  showSnack(context, 'Wait A Second');
                                }
                              } else if (_currentStep == 1) {
                                if (booleanProvider.configured) {
                                  controls.onStepContinue!();
                                } else {
                                  if (formKey.currentState!.validate()) {
                                    print(
                                        'validated${formKey.currentState!.validate()}');
                                    sendFrame(
                                      {
                                        "commands": "WIFI_CONFIG",
                                        "mac_address": booleanProvider.macAddress,
                                        "wifi_ssid": name,
                                        "wifi_password": password,
                                      },
                                      '255.255.255.255',
                                      8888,
                                    );
                                  } else {
                                    showSnack(context, 'Fields are Empty');
                                  }
                                }
                              } else {
                                if (booleanProvider.roomConfig) {
                                  Navigator.pop(context);
                                }
                                else {
                                  sendFrame(
                                    {
                                      "commands": 'DEVICE_CONFIG_WRITE',
                                      "mac_address": booleanProvider.macAddress,
                                      "device_location": roomName,
                                    },
                                    '255.255.255.255',
                                    8888,
                                  );
                                  print('boolean provider${booleanProvider.deviceLocation}');
                                  sqlDb.insertData('''
                                    INSERT OR IGNORE INTO led (`mac_address`, `device_type`, `device_location`, `wifi_ssid`, `wifi_password`)
                                    VALUES ("${booleanProvider.macAddress}", "${booleanProvider.deviceType}", "$roomName", "${booleanProvider.wifiSsid}", "${booleanProvider.wifiPassword}")
                                  ''');
                                  sqlDb.readData();
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade900,
                            ),
                            child: Text(
                              _currentStep == 0
                                  ? (booleanProvider.readOnly && !items.containsKey(booleanProvider.macAddress)
                                      ? 'Next'
                                      : 'connect')
                                  : _currentStep == 2
                                      ? (booleanProvider.connectionSuccess ? 'Next' : 'Configure')
                                      : _currentStep == 1
                                          ? (booleanProvider.configured ? 'Next' : 'Check Connection')
                                          : !booleanProvider.roomConfig
                                              ? 'Finish'
                                              : 'Save',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
