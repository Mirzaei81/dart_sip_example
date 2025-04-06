import 'package:flutter/material.dart';

class ConnectingOverlay extends StatelessWidget {
  final String? progress;
  final String? alert;

  ConnectingOverlay(this.progress, this.alert);

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text(
                alert ?? "",
              ),
              SizedBox(height: 12),
              Text(
                progress ?? '',
              ),
            ],
          ),
        ),
      );
}
