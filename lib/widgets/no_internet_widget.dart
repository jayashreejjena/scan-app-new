import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key});
  static const noInternetWidgetKey = Key('no-internet-widget-key');
  @override
  Widget build(BuildContext context) => Scaffold(
        key: noInternetWidgetKey,
        backgroundColor: Colors.white12,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                color: Colors.white,
                width: 300,
                height: 100,
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Text(
                    'internetIsNotConnected'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
