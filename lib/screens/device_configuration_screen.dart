import '../commons.dart';

class DeviceConfigurationScreen extends StatefulWidget {
  const DeviceConfigurationScreen({super.key});

  @override
  State<DeviceConfigurationScreen> createState() =>
      _DeviceConfigurationScreenState();
}

class _DeviceConfigurationScreenState extends State<DeviceConfigurationScreen> {

  bool _isSsidFieldVisible = false;
  bool _isPasswordFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Platform.isIOS
        ? CupertinoPageScaffold(
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black  // Dark mode background
                      : Colors.white, // Set the background color of the Stepper
                ),
                child: Stepper(
                    steps: getSteps(),
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
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: MyColors.greenDark1,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            child: CupertinoButton(
                              onPressed: () {
                                Provider.of<AuthProvider>(context, listen: false).configured = false;
                                snackBarCount = 0;
                                controls.onStepCancel!();
                              },
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent, // important to keep border visible
                              /*style: ElevatedButton.styleFrom(
                                side: const BorderSide(
                                  color: MyColors.greenDark1,
                                ),
                              ),*/
                              child: const Text(
                                'Back',
                                style: titleTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    width5,
                    Expanded(
                      child: SizedBox(
                        child: Consumer<AuthProvider>(
                            builder: (context, booleanProvider, child) {
                              return CupertinoButton(
                                onPressed: () {
                                  if (currentStep == 0) {
                                    if (booleanProvider.readOnly) {
                                      pressCount = 0;
                                      if (macAddresses
                                          .contains(booleanProvider.macAddress)) {
                                        showSnack(context,
                                            'you already have this device configured', 'Please Make sure you are connected to the device you want to configure');
                                      } else {
                                        snackBarCount = 0;
                                        pressCount = 0;
                                        controls.onStepContinue!();
                                      }
                                    } else {
                                      sendFrame(
                                        {"commands": 'MAC_ADDRESS_READ'},
                                        ip,
                                        port,
                                      );
                                      pressCount++;
                                      if(pressCount==2){
                                        showHint(context, 'Please Make sure you are connected to the device you want to configure');
                                      }
                                    }
                                  }
                                  else if (currentStep == 2) {
                                    if (booleanProvider.connectionFailed) {
                                      showSnack(context, 'Connection Failed', 'Please Make Sure Your Wi-Fi network data are correct');
                                    } else if (booleanProvider.connectionSuccess &&
                                        !booleanProvider.connectionFailed) {
                                      snackBarCount = 0;
                                      controls.onStepContinue!();
                                    } else {
                                      print("sending frame ${booleanProvider.macAddress}");
                                      sendFrame(
                                        {
                                          "commands": 'WIFI_CONNECT_CHECK',
                                          "mac_address": booleanProvider.macAddress,
                                        },
                                        ip,
                                        port,
                                      );
                                      showSnack(context, 'Wait A Second', 'Please Make sure you are connected to your Wi-Fi Network');
                                    }
                                  } else if (currentStep == 1) {
                                    if (booleanProvider.configured) {
                                      snackBarCount = 0;
                                      controls.onStepContinue!();
                                    } else {
                                      if (formKey.currentState!.validate() && name.isNotEmpty) {
                                        print("sending frame ${booleanProvider.macAddress}, $name, $password");
                                        sendFrame(
                                          {
                                            "commands": "WIFI_CONFIG",
                                            "mac_address": booleanProvider.macAddress,
                                            "wifi_ssid": name,
                                            "wifi_password": password,
                                          },
                                          ip,
                                          port,
                                        );
                                      } else {
                                        showSnack(context, 'Fields are Empty', 'You must Fill the field to continue the steps');
                                      }
                                    }
                                  } else {
                                    if (booleanProvider.roomConfig) {
                                      booleanProvider.roomConfig = false;
                                      Navigator.pop(context);
                                    } else {
                                      if (newRoom.name.isEmpty) {
                                        newRoom = iconsRoomsClass.first;
                                      } else {
                                        insertRoom(newRoom,
                                            apartmentMap.first['ApartmentID'])
                                            .then((value) {
                                          getRoomsByApartmentID(context,
                                              apartmentMap
                                                  .first['ApartmentID']);
                                          insertDevice(
                                            booleanProvider.macAddress,
                                            booleanProvider.wifiSsid,
                                            booleanProvider.wifiPassword,
                                            booleanProvider.deviceType,
                                            value,
                                          )
                                              .then((value) =>
                                          {
                                            Provider
                                                .of<AuthProvider>(context,
                                                listen: false)
                                                .roomConfig = true,
                                            exportData().then((value) =>
                                                Provider.of<AuthProvider>(
                                                    context,
                                                    listen: false)
                                                    .toggling('adding', false))
                                          });
                                        });
                                      }
                                    }
                                  }
                                },
                                color: MyColors.greenDark1,
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
              )
          ),
        )
            )
        : Scaffold(
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                  onSurface: MyColors.greenLight2,
                  primary: MyColors.greenDark1)),
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
                            snackBarCount = 0;
                            controls.onStepCancel!();
                          },
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                              color: MyColors.greenDark1,
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: titleTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  width5,
                  Expanded(
                    child: SizedBox(
                      child: Consumer<AuthProvider>(
                          builder: (context, booleanProvider, child) {
                            return ElevatedButton(
                              onPressed: () {
                                if (currentStep == 0) {
                                  if (booleanProvider.readOnly) {
                                    pressCount = 0;
                                    if (macAddresses
                                        .contains(booleanProvider.macAddress)) {
                                      showSnack(context,
                                          'you already have this device configured', 'Please Make sure you are connected to the device you want to configure');
                                    } else {
                                      snackBarCount = 0;
                                      pressCount = 0;
                                      controls.onStepContinue!();
                                    }
                                  } else {
                                    sendFrame(
                                      {"commands": 'MAC_ADDRESS_READ'},
                                      ip,
                                      port,
                                    );
                                    pressCount++;
                                    if(pressCount==2){
                                      showHint(context, 'Please Make sure you are connected to the device you want to configure');
                                    }
                                  }
                                }
                                else if (currentStep == 2) {
                                  if (booleanProvider.connectionFailed) {
                                    showSnack(context, 'Connection Failed', 'Please Make Sure Your Wi-Fi network data are correct');
                                  } else if (booleanProvider.connectionSuccess &&
                                      !booleanProvider.connectionFailed) {
                                    snackBarCount = 0;
                                    controls.onStepContinue!();
                                  } else {
                                    sendFrame(
                                      {
                                        "commands": 'WIFI_CONNECT_CHECK',
                                        "mac_address": booleanProvider.macAddress,
                                      },
                                      ip,
                                      port,
                                    );
                                    showSnack(context, 'Wait A Second', 'Please Make sure you are connected to your Wi-Fi Network');
                                  }
                                } else if (currentStep == 1) {
                                  if (booleanProvider.configured) {
                                    snackBarCount = 0;
                                    controls.onStepContinue!();
                                  } else {
                                    print("wifi name $name");
                                    if (formKey.currentState!.validate() && name.isNotEmpty) {
                                      sendFrame(
                                        {
                                          "commands": "WIFI_CONFIG",
                                          "mac_address": booleanProvider.macAddress,
                                          "wifi_ssid": name,
                                          "wifi_password": password,
                                        },
                                        ip,
                                        port,
                                      );
                                    } else {
                                      showSnack(context, 'Fields are Empty', 'You must Fill the field to continue the steps');
                                    }
                                  }
                                } else {
                                  if (booleanProvider.roomConfig) {
                                    booleanProvider.roomConfig = false;
                                    Navigator.pop(context);
                                  } else {
                                    insertRoom(newRoom,
                                        apartmentMap.first['ApartmentID'])
                                        .then((value) {
                                      getRoomsByApartmentID(context,
                                          apartmentMap.first['ApartmentID']);
                                      insertDevice(
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
                                        exportData().then((value) =>
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
                                backgroundColor: MyColors.greenDark1,
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

  Widget scaffoldBody (BuildContext context, bool isDarkMode) {
    // 1. Main Stepper Entry Point
      return SafeArea(
        child: Platform.isIOS
            ? Material(
          color: Colors.transparent,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: isDarkMode
                  ? Colors.black
                  : Colors.white,
            ),
            child: buildStepper(context, isDarkMode),
          ),
        )
            : Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              onSurface: MyColors.greenLight2,
              primary: MyColors.greenDark1,
            ),
          ),
          child: buildStepper(context, isDarkMode),
        ),
      );
    }

// 2. Shared Stepper Widget
    Widget buildStepper(BuildContext context, bool isDarkMode) {
      return Stepper(
        type: StepperType.horizontal,
        physics: const ScrollPhysics(),
        steps: getSteps(),
        currentStep: currentStep,
        onStepCancel: currentStep == 0
            ? null
            : () => setState(() {
          currentStep -= 1;
        }),
        onStepContinue: () => setState(() {
          if (currentStep < getSteps().length - 1) currentStep += 1;
        }),
          controlsBuilder: (context, controls) {
            final auth = Provider.of<AuthProvider>(context);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: currentStep != 0 &&
                    !auth.configured &&
                    auth.connectionSuccess
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  if (currentStep == 2 && auth.connectionFailed)
                    Expanded(
                      child: Platform.isIOS
                          ? CupertinoButton(
                        onPressed: () {
                          auth.configured = false;
                          snackBarCount = 0;
                          controls.onStepCancel?.call();
                        },
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: const Text('Back', style: titleTextStyle),
                      )
                          : ElevatedButton(
                        onPressed: () {
                          auth.configured = false;
                          snackBarCount = 0;
                          controls.onStepCancel?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: MyColors.greenDark1),
                        ),
                        child: const Text('Back', style: titleTextStyle),
                      ),
                    ),
                  width5,
                  Expanded(
                    child: Platform.isIOS
                        ? buildCupertinoNextButton(context, controls, auth, isDarkMode)
                        : buildMaterialNextButton(context, controls, auth, isDarkMode),
                  ),
                ],
              ),
            );
          }

        // controlsBuilder: (context, controls) => buildControls(context, controls),
      );
    }

// 3. Controls Builder
    Widget buildControls(BuildContext context, ControlsDetails controls) {
      final auth = Provider.of<AuthProvider>(context);
      final isVisible = (currentStep == 2 && auth.connectionFailed);
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return Row(
        mainAxisAlignment: currentStep != 0 && !auth.configured && auth.connectionSuccess
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          Visibility(
            visible: isVisible,
            child: Expanded(
              child: SizedBox(
                child: Platform.isIOS
                    ? buildCupertinoBackButton(context, controls)
                    : buildMaterialBackButton(context, controls),
              ),
            ),
          ),
          width5,
          Expanded(
            child: SizedBox(
              child: Consumer<AuthProvider>(
                builder: (context, booleanProvider, _) {
                  return Platform.isIOS
                      ? buildCupertinoNextButton(context, controls, booleanProvider, isDarkMode)
                      : buildMaterialNextButton(context, controls, booleanProvider, isDarkMode);
                },
              ),
            ),
          ),
        ],
      );

  }
  Widget buildCupertinoBackButton(BuildContext context, ControlsDetails controls) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.greenDark1, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoButton(
        onPressed: () {
          Provider.of<AuthProvider>(context, listen: false).configured = false;
          snackBarCount = 0;
          controls.onStepCancel?.call();
        },
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        child: const Text('Back', style: titleTextStyle),
      ),
    );
  }

  Widget buildMaterialBackButton(BuildContext context, ControlsDetails controls) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<AuthProvider>(context, listen: false).configured = false;
        snackBarCount = 0;
        controls.onStepCancel?.call();
      },
      style: ElevatedButton.styleFrom(
        side: const BorderSide(color: MyColors.greenDark1),
      ),
      child: const Text('Back', style: titleTextStyle),
    );
  }

  void handleStepContinue(
      BuildContext context,
      ControlsDetails controls,
      AuthProvider authProvider,
      ) {
    final isLastStep = currentStep == getSteps().length - 1;

    if (currentStep == 0) {
      if (authProvider.readOnly) {
        pressCount = 0;
        if (macAddresses.contains(authProvider.macAddress)) {
          showSnack(
            context,
            'Device already configured',
            'Please make sure you are connected to the device you want to configure',
          );
        } else {
          snackBarCount = 0;
          pressCount = 0;
          controls.onStepContinue?.call();
        }
      } else {
        sendFrame({'commands': 'MAC_ADDRESS_READ'}, ip, port);
        pressCount++;
        if (pressCount == 2) {
          showHint(context, 'Make sure you are connected to the device');
        }
      }
    } else if (currentStep == 1) {
      if (authProvider.configured) {
        snackBarCount = 0;
        controls.onStepContinue?.call();
      } else {
        if (formKey.currentState?.validate() == true && name.isNotEmpty) {
          sendFrame({
            'commands': 'WIFI_CONFIG',
            'mac_address': authProvider.macAddress,
            'wifi_ssid': name,
            'wifi_password': password,
          }, ip, port);
        } else {
          showSnack(context, 'Fields are Empty', 'Please fill all fields');
        }
      }
    } else if (currentStep == 2) {
      if (authProvider.connectionFailed) {
        showSnack(context, 'Connection Failed', 'Check your Wi-Fi data');
      } else if (authProvider.connectionSuccess) {
        snackBarCount = 0;
        controls.onStepContinue?.call();
      } else {
        sendFrame({
          'commands': 'WIFI_CONNECT_CHECK',
          'mac_address': authProvider.macAddress,
        }, ip, port);
        showSnack(context, 'Wait A Second', 'Ensure connection to Wi-Fi');
      }
    } else {
      if (authProvider.roomConfig) {
        authProvider.roomConfig = false;
        Navigator.pop(context);
      } else {
        if (newRoom.name.isEmpty) {
          newRoom = iconsRoomsClass.first;
        }
        insertRoom(newRoom, apartmentMap.first['ApartmentID']).then((roomId) {
          getRoomsByApartmentID(context, apartmentMap.first['ApartmentID']);
          insertDevice(
            authProvider.macAddress,
            authProvider.wifiSsid,
            authProvider.wifiPassword,
            authProvider.deviceType,
            roomId,
          ).then((_) {
            authProvider.roomConfig = true;
            exportData().then((_) =>
                Provider.of<AuthProvider>(context, listen: false)
                    .toggling('adding', false));
          });
        });
      }
    }
  }

  Widget buildCupertinoNextButton(
      BuildContext context,
      ControlsDetails controls,
      AuthProvider auth,
      bool isDarkMode,
      ) {
    return CupertinoButton(
      onPressed: () => handleStepContinue(context, controls, auth),
      borderRadius: BorderRadius.circular(8),
      color: MyColors.greenDark1,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        getStepButtonText(currentStep, auth),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.grey[900] : Colors.white,
        ),
      ),
    );
  }

  String getStepButtonText(int currentStep, AuthProvider auth) {
    switch (currentStep) {
      case 0:
        return auth.readOnly && !deviceDetails.contains(auth.macAddress)
            ? 'Next'
            : 'Connect';
      case 1:
        return auth.configured ? 'Next' : 'Configure';
      case 2:
        return auth.connectionSuccess && !auth.connectionFailed
            ? 'Next'
            : 'Check Connection';
      default:
        return !auth.roomConfig ? 'Save' : 'Finish';
    }
  }

  Widget buildMaterialNextButton(
      BuildContext context,
      ControlsDetails controls,
      AuthProvider auth,
      bool isDarkMode,
      ) {
    return ElevatedButton(
      onPressed: () => handleStepContinue(context, controls, auth),
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.greenDark1,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        getStepButtonText(currentStep, auth),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.grey[900] : Colors.white,
        ),
        textAlign: TextAlign.center,
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
                    style: cupertinoNavTitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'go to the wifi lists and connect to \'MegaSmart\' Network',
                    style: TextStyle(
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Image.asset(
                    Provider.of<AuthProvider>(context, listen: false).isDarkMode
                        ? 'assets/images/light-control-dark.gif'
                        : 'assets/images/light-control-light.gif',
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
                style: cupertinoNavTitleStyle,
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
                    if(Platform.isAndroid) SizedBox( ///TODO: disappears and appears
                      width: double.infinity,
                        child:DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select Wi-Fi Network'),
                          value: name.isNotEmpty && (name == 'Other' || wifiNetworks.any((network) => network?.ssid == name)) ? name : null,
                          menuMaxHeight: 200,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          onTap: getWifiNetworks,
                          onChanged: (String? newValue) {
                            setState(() {
                              name = newValue ?? '';
                              _isPasswordFieldVisible = true;

                              if (name == 'Other') {
                                _isSsidFieldVisible = true;
                              } else {
                                _isSsidFieldVisible = false;
                              }
                            });
                          },
                          items: [
                            ...wifiNetworks
                                .where((network) => network?.ssid != null && (network!.ssid?.isNotEmpty ?? false))
                                .map<DropdownMenuItem<String>>((WifiNetwork? network) {
                              return DropdownMenuItem<String>(
                                value: network?.ssid,
                                child: Text(network?.ssid ?? ''),
                              );
                            }).toList(),
                            const DropdownMenuItem<String>(
                              value: 'Other',
                              child: Text('Other (Enter manually)'),
                            ),
                          ],
                        ),
                    ),
                    if (_isSsidFieldVisible || Platform.isIOS) ...[ ///TODO: disappears and appears
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Wi-Fi name',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the SSID';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          name = nameController.text.trim();
                        },
                      ),
                    ],
                    if (_isPasswordFieldVisible || _isSsidFieldVisible || Platform.isIOS) ...[ ///TODO: disappears and appears
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
                              eye ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
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
                    style: cupertinoNavTitleStyle,
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
                        ? 'assets/images/light-control-dark.gif'
                        : 'assets/images/light-control-light.gif',
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
                style: cupertinoNavTitleStyle,
                textAlign: TextAlign.center,
              ),
              const Text(
                'make sure that you are connected to the previous wifi network and choose room name',
                style: TextStyle(
                  fontSize: 23,
                ),
                textAlign: TextAlign.center,
              ),
              RoomCustomizationContent(
                initialRoom: iconsRoomsClass.first,
                existingRooms: rooms,
                onChanged: (room) {
                  setState(() {
                    // Update state or handle submission
                    newRoom = room;
                  });
                },
              )

            ],
          ),
        ),
      ),
    ];
  }

  void resetting () {
    nameController.clear();
    passwordController.clear();
    currentStep = 0;
    pressCount = 0;
    name = '';
    password = '';
    eye = true;
  }

  @override
  void dispose() {
    super.dispose();
    resetting();
  }
}
