# Smart Home Light Control Application

## Overview
GlowGrid is an Android application that allows users to control light switches through a Wi-Fi network. 
The app provides simple on/off control of switches and allows users to adjust the color of one LED light. 
Users can manage devices across different rooms and share settings between mobile devices via QR 
code. 

## Features
- Control of multiple light switches 
- RGB color control for one LED 
- Device sharing via QR code 
- Room and device management 
- Dark and light theme options 

## Permissions
- Camera (for QR code scanning during device sharing).

## Usage
- Connect to Your Device: Open the app and connect to your smart lighting system via Wi-Fi.
- Navigate Through Rooms: Select rooms from the app's interface to control specific lights.
- Toggle or Dim Lights: Use on-screen switches and sliders to adjust the lighting as desired.

## Technologies Used
- Frontend: Flutter (Dart)
- Backend: Firebase (for data storage and real-time updates) [if applicable]
- Connectivity: Wi-Fi

## Project Structure
- /lib: Main codebase with widgets, models, and services
- /images: Contains images and icons for the app

## screenshots
Here is a glimpse of the smart Home Light Control Application:

### Main Dashboard
![Dashboard](assets/screenshots/main_dashboard.jpg)

### Light Control Page
![Light Control](assets/screenshots/light_control.png)

### Device Configuration Page
- step 1:
![Light Control](assets/screenshots/device_connecting.jpg)
- step 2:
![Light Control](assets/screenshots/device_configuration.png)
- step 3:
![Light Control](assets/screenshots/Wi-Fi_configuration.jpg)
- step 4:
![Light Control](assets/screenshots/room_configure.jpg)

### Export Data Page
![Light Control](assets/screenshots/export_data.png)

### Import Data Page
![Light Control](assets/screenshots/import_data.png)

## License
This project is licensed under the GNU Affero General Public License v3.0.