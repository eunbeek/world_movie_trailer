import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

Future<void> showPermissionDialog(BuildContext context) async {
  final settingsProvider = Provider.of<SettingsProvider>(context,listen: false);
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(getPermissionLabel(settingsProvider.language, 'permissionRequired')),
      content: Text(getPermissionLabel(settingsProvider.language, 'permissionDesc')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(getPermissionLabel(settingsProvider.language, 'cancel')),
        ),
        TextButton(
          onPressed: () {
            openAppSettings();
            Navigator.pop(context);
          },
          child: Text(getPermissionLabel(settingsProvider.language, 'openSettings')),
        ),
      ],
    ),
  );
}
