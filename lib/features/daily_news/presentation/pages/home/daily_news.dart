import 'package:flutter/material.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
    );
  }

  _buildAppbar() {
    return AppBar(
      title: Text(
        'Daily News',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}