import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
/*class ColorPick extends StatefulWidget {
  const ColorPick({super.key});

  @override
  State<ColorPick> createState() => _ColorPickState();
}

class _ColorPickState extends State<ColorPick> {
  bool lightTheme = true;
  Color currentColor = Colors.amber;
  void changeColor(Color color) => setState(() => currentColor = color);
  @override
  Widget build(BuildContext context) {
    final foregroundColor = useWhiteForeground(currentColor) ? Colors.white : Colors.black;
    return AnimatedTheme(
      data: lightTheme ? ThemeData.light() : ThemeData.dark(),
      child: Builder(builder: (context) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => setState(() => lightTheme = !lightTheme),
            icon: Icon(lightTheme ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            label: Text(lightTheme ? 'Night' : '  Day '),
            backgroundColor: currentColor,
            foregroundColor: foregroundColor,
            elevation: 15,
          ),
          appBar: AppBar(
            title: const Text('Color Picker'),
            backgroundColor: currentColor,
          ),
          body: HUEColorPicker(
            pickerColor: currentColor,
            onColorChanged: changeColor,
          ),
        );
      }),
    );
  }
}*/

class HUEColorPicker extends StatefulWidget {
  const HUEColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<HUEColorPicker> createState() => _HUEColorPickerState();
}

class _HUEColorPickerState extends State<HUEColorPicker> {

  @override
  Widget build(BuildContext context) {
    return ColorPicker(
      pickerColor: widget.pickerColor,
      onColorChanged: widget.onColorChanged,
      colorPickerWidth: 300,
      pickerAreaHeightPercent: 0.7,
      enableAlpha: false,
      labelTypes: const [],
      displayThumbColor: true,
      portraitOnly: true,
      paletteType: PaletteType.hueWheel,
      pickerAreaBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(2),
        topRight: Radius.circular(2),
      ),
      hexInputBar: false,
    );
  }
}