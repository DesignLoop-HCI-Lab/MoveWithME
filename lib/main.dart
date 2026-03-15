
// Imports 
import 'dart:async'; // Timer function to poll ESP every 300ms
import 'dart:convert'; // converts JSON recieved from ESP to Objects /strings
import 'package:flutter/material.dart'; // Material UI framework
import 'package:http/http.dart' as http; //handle API calls 

void main() { // run main. dart
  runApp(const MyApp()); //default widget (follows as class below)
}

class MyApp extends StatelessWidget { // App container stateless because wont change state
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { //method that builds UI 
    return const MaterialApp(
      debugShowCheckedModeBanner: false, //removes red debug banner
      home: MovementScreen(), //sets first screen
    );
  }
}

// first screen, statefull because state changes all the time 
class MovementScreen extends StatefulWidget { 
  const MovementScreen({super.key});

  @override
  State<MovementScreen> createState() => _MovementScreenState(); //calls state variables
}

//setting state variables 
class _MovementScreenState extends State<MovementScreen> {

  String movement = "none"; //no movement when app launches
  Timer? timer; // initializes timer 

  @override
  void initState() { //runs when screen loads 
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 300), (_) { //start 300ms timer
      fetchMovement(); // poll ESP every with method below 
    });
  }

  Future<void> fetchMovement() async { //runs async
    try {
      final response = await http.get( //send http request to ESP
        Uri.parse("http://192.168.4.1/status"),
      );

      if (response.statusCode == 200) { //executes upon successful response 
        final data = json.decode(response.body);//decodes json 
        setState(() {
          movement = data["movement"]; //sets movement state redraws screen every change 
        });
      }
    } catch (e) { //runs when things go wrong 
      // Ignore connection errors - we are ignoring the errors so that app does not crash
    }
  }

  @override
  void dispose() {//kills timer :)
    timer?.cancel();
    super.dispose();
  }

  // Instructions on how to draw screen switch with colours

  Color getColor() {
    switch (movement) {
      case "left":
        return Colors.blue;
      case "right":
        return Colors.green;
      case "jump":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String getText() { //switch with text
    switch (movement) {
      case "left":
        return "⬅ LEFT";
      case "right":
        return "RIGHT ➡";
      case "jump":
        return "🚀 JUMP!";
      default:
        return "STILL";
    }
  }
  //building the activity 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getColor(),
      body: Center(
        child: Text(
          getText(),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
