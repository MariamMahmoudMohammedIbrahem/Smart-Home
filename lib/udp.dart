import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mega/ui/loading_screen.dart';
import 'package:mega/ui/rooms.dart';

import 'constants.dart';
import 'db/functions.dart';

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
  bool readOnly = true;
  bool navigate = false;
  bool connectionSuccess = false;

  void sendFrame(String frame, String ipAddress, int port) {
    // Removed the ipAddress assignment
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print('hello2');
      socket.broadcastEnabled = true;
      socket.send(frame.codeUnits, InternetAddress(ipAddress), port);
    });
  }

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
  }

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
    startListen();
    super.initState();
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
                    'subtitle',
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
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 2,
        title: const Text(''),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              const Text(
                'Add Wifi-Network',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Please add your home\'s wifi network data',
                style: TextStyle(
                  fontSize: 23,
                ),
                textAlign: TextAlign.center,
              ),
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
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        name = _nameController.text;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
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
              mainAxisAlignment: _currentStep != 0 && !configured && !connectionSuccess
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: (_currentStep != 0 && readOnly) || (_currentStep == 2 && !configured) || (_currentStep == 1 && !connectionSuccess),
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
                const SizedBox(width: 5,),
                Expanded(
                  child: SizedBox(
                    // width: (_currentStep == 0 || connectionSuccess || configured) ? width * .7 : width * .4,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep == 0) {
                          if(!readOnly){
                            controls.onStepContinue!();
                          }
                          else{
                            sendFrame(
                                'MAC_ADDRESS_READ', '255.255.255.255', 8888);
                          }
                        }
                        else if (_currentStep == 1) {
                          if(connectionSuccess){
                            controls.onStepContinue!();
                          }
                          else{
                            sendFrame(
                                'WIFI_CONNECT_CHECK', '255.255.255.255', 8888);
                            showSnack(context, 'Wait A Second');
                          }
                        }
                        else if (_currentStep == 2) {
                          if(configured){
                            controls.onStepContinue!();
                          }else{
                            if(_formKey.currentState!.validate()){
                              print('validated${_formKey.currentState!.validate()}');
                              sendFrame(
                                  'WIFI_CONFIG::[@MS_SEP@]::$name::[@MS&SEP@]::$password',
                                  '192.168.4.1',
                                  8888);
                            }
                            else{
                              showSnack(context, 'Fields are Empty');
                            }
                          }
                        } else {
                          saveInDB('Devices');
                          if (!readOnly) {
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
                                          builder: (context) => const Rooms(userName: '',),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          } else {
                            showSnack(
                              context,
                              'Make Sure You Are Connected to Wifi',
                            );
                          }
                        }
                      },
                      child: Text(
                        _currentStep == 0
                            ? (readOnly ? 'Next' : 'connect')
                            : _currentStep == 1
                                ? (connectionSuccess
                                    ? 'Next'
                                    : 'Check Connection')
                                : _currentStep == 2
                                    ? (configured ? 'Next' : 'Configure')
                                    : 'Finish',
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
