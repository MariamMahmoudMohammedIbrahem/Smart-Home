import 'package:flutter/material.dart';

import '../constants.dart';

class LoadingPage extends StatefulWidget {
  final Function(bool) onValueReceived;

  const LoadingPage({super.key, required this.onValueReceived});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      bool value = saved;
      widget.onValueReceived(value);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: Center(
        child: Column(
          children: [
            const Text('Loading...'),
            ElevatedButton(onPressed: (){setState(() {
              saved = true;
            });}, child: const Text('nsv'))
          ],
        ),
      ),
    );
  }
}