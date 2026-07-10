import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:restart_app/restart_app.dart';

class ShorebirdUpdateService {
  ShorebirdUpdateService._();
  static final ShorebirdUpdateService instance = ShorebirdUpdateService._();

  final ShorebirdUpdater _updater = ShorebirdUpdater();

  /// Checks for a new patch and downloads it if available.
  /// Returns true if a patch was downloaded and is ready to apply.
  Future<bool> checkAndDownloadUpdate() async {
    if (!_updater.isAvailable) return false;

    try {
      final status = await _updater.checkForUpdate();

      if (status != UpdateStatus.outdated) return false;

      await _updater.update();
      return true;
    } on UpdateException catch (e) {
      debugPrint('Shorebird update failed: $e');
      return false;
    }
  }

  /// Checks for an update, and if one was downloaded, shows a
  /// non-dismissible dialog forcing the user to restart.
  Future<void> checkAndForceRestart(BuildContext context) async {
    final updated = await checkAndDownloadUpdate();
    if (!updated) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
            'A new update has been downloaded. The app must restart to continue.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Restart.restartApp(),
              child: const Text('Restart Now'),
            ),
          ],
        ),
      ),
    );
  }
}
