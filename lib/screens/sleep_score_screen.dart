import 'package:flutter/material.dart';

class SleepScoreScreen extends StatelessWidget {
  static const routeName = '/sleep-score';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Score'),
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
                  Icons.star,
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  'Your Sleep Score:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '85', // Replace this with the actual sleep score
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
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
