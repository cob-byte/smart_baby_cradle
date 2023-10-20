import 'package:flutter/material.dart';

class WakeUpTimesScreen extends StatelessWidget {
  static const routeName = '/wake-up-times';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wake-Up Times Details'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/night-background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.alarm,
                  size: 100,
                  color: Colors.orange,
                ),
                SizedBox(height: 20),
                Text(
                  'Wake-Up Times Details:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '7:00 AM', // Replace this with the actual wake-up time
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality here if needed
                  },
                  child: Text('View Details'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
