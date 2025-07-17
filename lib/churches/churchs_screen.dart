import 'package:flutter/material.dart';

class ChurchesScreen extends StatelessWidget {
  const ChurchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> churches=
        ['Church 1', 'Church 2', 'Church 3', 'Church 4', 'Church 5'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Churches'),
      ),
      body:ListView.builder(itemBuilder:
      (context, i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Text(churches[i],style: const TextStyle(fontSize: 24,fontWeight: FontWeight.w500),)
            ],
          );
        },
        itemCount: churches.length, // Example count of churches
      ),
    );
  }
}