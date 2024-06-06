import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:mega/ui/loading_screen.dart';
import 'package:mega/ui/rooms.dart';

import 'constants.dart';

class UDPScreen extends StatefulWidget {
  const UDPScreen({super.key});

  @override
  State<UDPScreen> createState() => _UDPScreenState();
}

class _UDPScreenState extends State<UDPScreen> {
  String name = '';
  String password = '';
  String responseAll = 'no ';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool configured = false;
  bool readOnly = false;
  bool navigate = false;
  bool connectionSuccess = false;
  bool roomConfig = false;
  var commandResponse = '';
  String macAddress = "";
  void sendFrame(Map<String, dynamic> jsonFrame, String ipAddress, int port) {
    // Convert the Map to a JSON string
    String frame = jsonEncode(jsonFrame);

    // Bind to any available IPv4 address and port 0 (let the OS assign a port)
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print('Sending JSON frame');
      print(jsonFrame);
      socket.broadcastEnabled = true;

      // Send the JSON string as a list of bytes
      socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
    });
  }

  void startListen() {
    // Bind to any available IPv4 address and the specified port (8081)
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081)
        .then((RawDatagramSocket socket) {
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            // Convert the received data to a string
            String response = String.fromCharCodes(datagram.data);
            print('response $response');
            if (response == "OK") {
              commandResponse = response;
            } else {
              try {
                // Parse the JSON string to a Map
                Map<String, dynamic> jsonResponse = jsonDecode(response);
                print('response $response');
                // print('Received JSON response: $jsonResponse');

                commandResponse = jsonResponse['commands'];
                if (commandResponse == 'MAC_ADDRESS_READ_OK') {
                  setState(() {
                    macAddress = jsonResponse["mac_address"];
                    readOnly = true;
                  });
                } else if (commandResponse == 'UPDATE_OK') {
                } else if (commandResponse == 'WIFI_CONFIG_OK') {
                  /*setState(() {
                    configured = true;
                  });*/
                } else if (commandResponse == 'WIFI_CONFIG_FAIL') {
                } else if (commandResponse == 'WIFI_CONFIG_CONNECTING') {
                  setState(() {
                    configured = true;
                  });
                } else if (commandResponse == 'WIFI_CONFIG_MISSED_DATA') {
                } else if (commandResponse == 'WIFI_CONFIG_SAME') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("WIFI_CONFIG_SAME"),
                  ));
                } else if (commandResponse == 'WIFI_CONNECT_CHECK_OK') {
                  setState(() {
                    connectionSuccess = true;
                    showSnack(context, 'Connected Successfully');
                  });
                } else if (commandResponse == 'SWITCH_READ_OK') {
                }
                /*else if (commandResponse == 'SWITCH_WRITE_OK') {

                }*/
                else if (commandResponse == 'RGB_READ_OK') {
                }
                /* else if (commandResponse == 'RGB_WRITE_OK') {

                }*/
                else if (commandResponse == 'DEVICE_CONFIG_WRITE_OK') {
                  setState(() {
                    roomConfig = true;
                  });
                }
                /*if (response.startsWith('WIFI_CONFIG::[@MS_SEP@]::')) {
                setState(() {
                  configured = true;
                });
              } else if (response.startsWith('MAC_ADDRESS_READ::[@MS_SEP@]::')) {
                setState(() {
                  readOnly = false;
                });
                print('true');
              } else if (response.startsWith('WIFI_CONNECT_OK')) {
                setState(() {
                  connectionSuccess = true;
                  showSnack(context, 'Connected Successfully');
                });
              } else if (response.startsWith('STATUS_READ::[@MS_SEP@]::')) {
                setState(() {});
              } else if (response.startsWith('RGB_READ::')) {
                setState(() {});
              }*/
              } catch (e) {
                print('Error decoding JSON: $e');
              }
            }
          }
        }
      });
    });
  }
  /*dynamic searchJson(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) {
      return json[key];
    }

    for (var value in json.values) {
      if (value is Map) {
        var result = searchJson(Map<String, dynamic>.from(value), key);
        if (result != null) {
          return result;
        }
      }
      else if (value is List) {
        for (var item in value) {
          if (item is Map) {
            var result = searchJson(Map<String, dynamic>.from(item), key);
            if (result != null) {
              return result;
            }
          }
        }
      }
    }

    return null;
  }*/
  /*void sendFrame(String frame, String ipAddress, int port) {
    // Removed the ipAddress assignment
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print('hello2');
      socket.broadcastEnabled = true;
      socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
    });
  }
///todo: json
  void startListen() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081) //local port
        .then((RawDatagramSocket socket) {
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            String response = String.fromCharCodes(datagram.data);
            if (response.startsWith('WIFI_CONFIG::[@MS_SEP@]::')) {
              setState(() {
                configured = true;
              });
            } else if (response.startsWith('MAC_ADDRESS_READ::[@MS_SEP@]::')) {
              setState(() {
                readOnly = false;
              });
              print('true');
            } else if (response.startsWith('WIFI_CONNECT_OK')) {
              setState(() {
                connectionSuccess = true;
                showSnack(context, 'Connected Successfully');
              });
            } else if (response.startsWith('STATUS_READ::[@MS_SEP@]::')) {
              setState(() {});
            } else if (response.startsWith('RGB_READ::')) {
              setState(() {});
            }
            setState(() {
              responseAll = response;
            });
          }
        }
      });
    });
  }*/

  void close() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8081) //local port
        .then((RawDatagramSocket socket) {
      socket.close();
    });
  }

  void showSnack(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    startListen();
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }

  int _currentStep = 0;
  IconData _selectedIcon = Icons.living_sharp;
  List<IconData> icons = [
    Icons.living_sharp,
    Icons.bedroom_baby_sharp,
    Icons.bedroom_parent_sharp,
    Icons.kitchen_sharp,
    Icons.bathroom_sharp,
    Icons.dining_sharp,
    Icons.desk_sharp,
    Icons.local_laundry_service_sharp,
    Icons.garage_sharp,
    Icons.camera_outdoor_sharp,
  ];
  String getIconName(IconData icon) {
    if (icon == Icons.living_sharp) {
      return 'Living Room';
    } else if (icon == Icons.bedroom_baby_sharp) {
      return 'Baby Bedroom';
    } else if (icon == Icons.bedroom_parent_sharp) {
      return 'Parent Bedroom';
    } else if (icon == Icons.kitchen_sharp) {
      return 'Kitchen';
    } else if (icon == Icons.bathroom_sharp) {
      return 'Bathroom';
    } else if (icon == Icons.dining_sharp) {
      return 'Dining Room';
    } else if (icon == Icons.desk_sharp) {
      return 'Desk';
    } else if (icon == Icons.local_laundry_service_sharp) {
      return 'Laundry Room';
    } else if (icon == Icons.garage_sharp) {
      return 'Garage';
    } else /* if (icon == Icons.camera_outdoor_sharp) */ {
      return 'Outdoor';
    }
  }

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
                  const Text(
                    'HEADLINE1',
                    style: TextStyle(
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
                  Text('command $commandResponse'),

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
              const Text(
                'Wifi Network Configuration',
                style: TextStyle(
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
              Text('command $commandResponse'),
              Form(
                key: _formKey,
                /*autovalidateMode: !readOnly
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,*/
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Wifi Network Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your Wifi Network\'s name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        name = _nameController.text;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
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
                        password = _passwordController.text;
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
                  const Text(
                    'Check connection',
                    style: TextStyle(
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
                  Text('command $commandResponse'),

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
              const Text(
                'choose your room name',
                style: TextStyle(
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
              Text('command $commandResponse'),
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
                  items: icons.map<DropdownMenuItem<IconData>>((IconData icon) {
                    return DropdownMenuItem<IconData>(
                      value: icon,
                      child: Row(
                        children: [
                          Icon(icon),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            getIconName(icon),
                          ),
                        ],
                      ),
                      onTap: () {
                        roomName = getIconName(icon);
                      },
                    );
                  }).toList(),
                ),
              ),
              /*ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'check connectivity',
                ),
              ),*/
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
                  _currentStep != 0 && !configured && !connectionSuccess
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: (_currentStep != 0 && readOnly) ||
                      (_currentStep == 1 && !configured) ||
                      (_currentStep == 2 && !connectionSuccess) ||
                  !roomConfig,
                  child: Expanded(
                    child: SizedBox(
                      // width: width * .4,
                      child: ElevatedButton(
                        onPressed: controls.onStepCancel,
                        child: const Text(
                          'Back',
                          style: TextStyle(
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
                    // width: (_currentStep == 0 || connectionSuccess || configured) ? width * .7 : width * .4,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep == 0) {
                          if (readOnly) {
                            controls.onStepContinue!();
                          } else {
                            sendFrame(
                              {"commands": 'MAC_ADDRESS_READ'},
                              '255.255.255.255',
                              8888,
                            );
                          }
                        } 
                        else if (_currentStep == 2) {
                          if (connectionSuccess) {
                            controls.onStepContinue!();
                          } else {
                            sendFrame(
                              {
                                "commands": 'WIFI_CONNECT_CHECK',
                                "mac_address": macAddress,
                              },
                              '255.255.255.255',
                              8888,
                            );
                            showSnack(context, 'Wait A Second');
                          }
                        } 
                        else if (_currentStep == 1) {
                          if (configured) {
                            controls.onStepContinue!();
                          } else {
                            if (_formKey.currentState!.validate()) {
                              print(
                                  'validated${_formKey.currentState!.validate()}');
                              sendFrame(
                                {
                                  "commands": "WIFI_CONFIG",
                                  "mac_address": macAddress,
                                  "wifi_ssid": name,
                                  "wifi_password": password,
                                },
                                '192.168.4.1',
                                8888,
                              );
                            } else {
                              showSnack(context, 'Fields are Empty');
                            }
                          }
                        } 
                        else {
                          // items.assign(macAddress, roomName);
                          items[macAddress] = roomName;
                          if(roomConfig){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadingPage(
                                  onValueReceived: (bool value) {
                                    // Navigate based on the received boolean value
                                    if (value) {
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Rooms(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                          else{
                            sendFrame(
                              {
                                "commands": 'DEVICE_CONFIG_WRITE',
                                "mac_address": macAddress,
                                "device_location":roomName,
                              },
                              '255.255.255.255',
                              8888,
                            );
                            items.assign(macAddress, roomName);
                            /*saveInDB('Devices');*/
                          }
                        }
                      },
                      child: Text(
                        _currentStep == 0
                            ? (readOnly ? 'Next' : 'connect')
                            : _currentStep == 2
                                ? (connectionSuccess ? 'Next' : 'Configure')
                                : _currentStep == 1
                                    ? (configured ? 'Next' : 'Check Connection')
                                    : roomConfig? 'Finish':'Save',
                        /*_currentStep == getSteps().length - 1
                            ? 'Finish'
                            : (_currentStep != 1 || connectionSuccess)
                                ? 'Next'
                                : 'Check Connection',*/
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
