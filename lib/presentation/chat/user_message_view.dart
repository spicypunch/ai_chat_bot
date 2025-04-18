import 'package:flutter/material.dart';

class UserMessageView extends StatelessWidget {
  final String chat;

  const UserMessageView({
    required this.chat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("👤"),
        Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            chat,
            style: TextStyle(color: Colors.black87, fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
