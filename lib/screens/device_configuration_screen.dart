import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../utils/functions.dart';

class DeviceConfigurationScreen extends StatefulWidget {
  const DeviceConfigurationScreen({super.key});

  @override
  State<DeviceConfigurationScreen> createState() =>
      _DeviceConfigurationScreenState();
}

class _DeviceConfigurationScreenState extends State<DeviceConfigurationScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                  onSurface: const Color(0xFF609e51),
                  primary: const Color(0xFF047424))),
          child: Stepper(
            steps: getSteps(),
            physics: const ScrollPhysics(),
            type: StepperType.horizontal,
            currentStep: currentStep,
            onStepCancel: () => currentStep == 0
                ? null
                : setState(() {
              currentStep -= 1;
            }),
            onStepContinue: () {
              bool isLastStep = (currentStep == getSteps().length - 1);
              if (isLastStep) {
              } else {
                setState(() {
                  currentStep += 1;
                });
              }
            },
            onStepTapped: (step) {},
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return Row(
                mainAxisAlignment: currentStep != 0 &&
                    !Provider.of<AuthProvider>(context).configured &&
                    !!Provider.of<AuthProvider>(context).connectionSuccess
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: (currentStep == 2 &&
                        Provider.of<AuthProvider>(context).connectionFailed),
                    child: Expanded(
                      child: SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false).configured = false;
                            controls.onStepCancel!();
                          },
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF047424),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              color: Color(0xFF047424),
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
                                if (currentStep == 0) {
                                  if (booleanProvider.readOnly) {
                                    if (macMap
                                        .contains(booleanProvider.macAddress)) {
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
                                } else if (currentStep == 2) {
                                  if (booleanProvider.connectionFailed) {
                                    showSnack(context, 'Connection Failed');
                                  } else if (booleanProvider.connectionSuccess &&
                                      !booleanProvider.connectionFailed) {
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
                                } else if (currentStep == 1) {
                                  if (booleanProvider.configured) {
                                    controls.onStepContinue!();
                                  } else {
                                    if (formKey.currentState!.validate()) {
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
                                    booleanProvider.roomConfig = false;
                                    Navigator.pop(context);
                                  } else {
                                    sqlDb
                                        .insertRoom(roomName,
                                        apartmentMap.first['ApartmentID'])
                                        .then((value) {
                                      sqlDb.getRoomsByApartmentID(context,
                                          apartmentMap.first['ApartmentID']);
                                      sqlDb
                                          .insertDevice(
                                        booleanProvider.macAddress,
                                        booleanProvider.wifiSsid,
                                        booleanProvider.wifiPassword,
                                        booleanProvider.deviceType,
                                        value,
                                      )
                                          .then((value) => {
                                        Provider.of<AuthProvider>(context,
                                            listen: false)
                                            .roomConfig = true,
                                        sqlDb.exportData().then((value) =>
                                            Provider.of<AuthProvider>(
                                                context,
                                                listen: false)
                                                .toggling('adding', false))
                                      });
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF047424),
                              ),
                              child: Text(
                                currentStep == 0
                                    ? (booleanProvider.readOnly &&
                                    !deviceDetails.contains(
                                        booleanProvider.macAddress)
                                    ? 'Next'
                                    : 'connect')
                                    : currentStep == 2
                                    ? (booleanProvider.connectionSuccess &&
                                    !booleanProvider.connectionFailed
                                    ? 'Next'
                                    : 'Check Connection')
                                    : currentStep == 1
                                    ? (booleanProvider.configured
                                    ? 'Next'
                                    : 'Configure')
                                    : !booleanProvider.roomConfig
                                    ? 'Save'
                                    : 'Finish',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  isDarkMode ? Colors.grey[900] : Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }),
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

  List<Step> getSteps() {
    return [
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
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
                    'Connecting To The Device',
                    style: TextStyle(
                      color: Color(0xFF047424),
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

                  Image.asset(
                    Provider.of<AuthProvider>(context, listen: false).isDarkMode
                        ? 'images/light-control-dark.gif'
                        : 'images/light-control-light.gif',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text(''),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              const Text(
                'Wifi Network Configuration',
                style: TextStyle(
                  color: Color(0xFF047424),
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
                        setState(() {
                          Provider.of<AuthProvider>(context, listen: false)
                              .configured = false;
                        });
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
                        setState(() {
                          Provider.of<AuthProvider>(context, listen: false)
                              .configured = false;
                        });
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
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
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
                      color: Color(0xFF047424),
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

                  Image.asset(
                    Provider.of<AuthProvider>(context, listen: false).isDarkMode
                        ? 'images/light-control-dark.gif'
                        : 'images/light-control-light.gif',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 3 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 3,
        title: const Text(''),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              const Text(
                'choose your room name',
                style: TextStyle(
                  color: Color(0xFF047424),
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
                  value: selectedIcon,
                  menuMaxHeight: 200,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  underline: Container(
                    height: 2,
                  ),
                  onChanged: (IconData? newValue) {
                    setState(() {
                      if (newValue != null) {
                        selectedIcon = newValue;
                      }
                    });
                  },
                  items: iconsRooms
                      .map<DropdownMenuItem<IconData>>((IconData icon) {
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
  void dispose() {
    nameController.clear();
    passwordController.clear();
    currentStep = 0;
    super.dispose();
  }
}
