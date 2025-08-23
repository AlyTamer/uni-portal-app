// widgets/offline_banner_widget.dart
import 'package:flutter/material.dart';
import '../functions/core/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: ConnectivityService.instance.isOnline,
      stream: ConnectivityService.instance.onlineStream,
      builder: (context, snap) {
        final online = snap.data ?? true;
        return Column(
          children: [
            if (!online)
              Container(
                width: double.infinity,
                color: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: const SafeArea(
                  bottom: false,
                  child: Text('No internet',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
