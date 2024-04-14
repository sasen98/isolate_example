import 'dart:isolate';

import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Isolates Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// either define the function outside the class or make it static
void calculateWithIsolate(SendPort sendPort) {
  /// SendPort is responsible to send the result to the recevice port in the form of message
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }
  sendPort.send(total);
}

class _MyHomePageState extends State<MyHomePage> {
  int maxValue = 1000000000;
  // calculate
  double calculate() {
    var total = 0.0;
    for (var i = 0; i < maxValue; i++) {
      total += i;
    }
    return total;
  }

  Future<double> awaitAndCalculate() async {
    var total = 0.0;
    for (var i = 0; i < maxValue; i++) {
      total += i;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/ball.gif'),

              /// normal function
              ElevatedButton(
                onPressed: () {
                  double val = calculate();
                  print("Normal Calculated Value is:::::::::::::::::: $val");
                },
                child: const Text("Calculate"),
              ),
              const SizedBox(
                height: 20,
              ),

              /// await and calculate
              ElevatedButton(
                onPressed: () async {
                  double val = await awaitAndCalculate();
                  print(
                      "Awaited and Calculated Value is:::::::::::::::::: $val");
                },
                child: const Text("Await and Calculate"),
              ),
              const SizedBox(
                height: 20,
              ),

              /// isolate
              ElevatedButton(
                onPressed: () async {
                  ReceivePort receivePort = ReceivePort();

                  /// await is for creating an isolate and not for receving data from it
                  await Isolate.spawn(
                      calculateWithIsolate, receivePort.sendPort);

                  /// receive message from spawn isolate to main isolate
                  double val = await receivePort.first;
                  print(
                      "Calculated with isolate value is :::::::::::::::::::::: $val");
                },
                child: const Text("Calculate with isolate"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
