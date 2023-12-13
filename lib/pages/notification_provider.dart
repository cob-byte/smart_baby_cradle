import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPd extends ChangeNotifier {
  List<bool> notificationRead = List<bool>.filled(0, false, growable: true);
  List<String> notificationTitles = <String>[];
  List<String> notificationBodies = <String>[];
  bool isSelecting = false;

  reload() => notifyListeners();

  NotificationPd() {
    notificationRead = [];
    notificationTitles = [];
    notificationBodies = [];
  }

  void addNotification(String title, String body) {
    notificationTitles.insert(0, title);
    notificationBodies.insert(0, body);
    notificationRead.insert(0, false);
    reload();
  }

  void deleteNotification(int index) {
    notificationTitles.removeAt(index);
    notificationBodies.removeAt(index);
    notificationRead.removeAt(index);
    reload();
  }

  void deleteAllNotifications(BuildContext context) {
    if (notificationTitles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Notifications to Delete'),
        ),
      );
    } else {
      notificationTitles.clear();
      notificationBodies.clear();
      notificationRead.clear();
      reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All Notifications Deleted'),
        ),
      );
    }
  }

  void markAllAsRead(BuildContext context) {
    if (notificationTitles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Notifications to Mark as Read'),
        ),
      );
    } else {
      for (var i = 0; i < notificationRead.length; i++) {
        notificationRead[i] = true;
      }
      reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All Notifications Marked As Read'),
        ),
      );
    }
  }

  void loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    for (var i = 0; i < notifications.length; i += 2) {
      addNotification(notifications[i], notifications[i + 1]);
    }
  }
}