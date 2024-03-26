// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool onLight = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: onLight ? Colors.amber[300] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              onLight ? Icons.lightbulb : Icons.lightbulb_outline_rounded,
              size: 250,
              color: onLight ? Colors.white : null,
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 95,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.blueAccent),
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      onLight = !onLight;
                    });
                  },
                  child: Text(
                    onLight ? 'Off' : 'On',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
