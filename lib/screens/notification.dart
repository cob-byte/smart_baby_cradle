import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/notification_provider.dart';
import '../theme_provider.dart';

class NotificationPage extends StatefulWidget {
  static const routeName = '/notification';

  NotificationPage({Key? key}) : super(key: key);

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    var _pd = Provider.of<NotificationPd>(context, listen: false);

    return Theme(
      data: currentTheme,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear All',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text('Are you sure you want to delete all notifications?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Delete All'),
                        onPressed: () {
                          _pd.deleteAllNotifications(context);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark All As Read',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text('Are you sure you want to mark all notifications as read?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Mark All As Read'),
                        onPressed: () {
                          _pd.markAllAsRead(context);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                currentTheme.colorScheme.primary,
                currentTheme.colorScheme.secondary,
                currentTheme.colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
            ),
          ),
        child: Stack(
        children: [
          Positioned(
                bottom: -60,
                right: -50,
                child: Image(
                  image: AssetImage('assets/image/cradle_bg.png'),
                  width: 200,
                  height: 200,
                ),
              ),
          _pd.notificationTitles.isEmpty
            ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 33,
                    color: Colors.black,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'No Notification',
                    style: TextStyle(fontSize: 25, color: Colors.black,fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: _pd.notificationTitles.length,
            itemBuilder: (context, index) {
              IconData iconData;
              switch (_pd.notificationTitles[index]) {
                case 'Object Detected':
                  iconData = Icons.warning;
                  break;
                case 'Temperature Alert':
                  iconData = Icons.thermostat;
                  break;
                case 'Noisy Environment':
                  iconData = Icons.volume_up;
                  break;
                case "Baby's Awake!":
                  iconData = Icons.child_care;
                  break;
                case 'Unsafe Head Positioning!':
                  iconData = Icons.accessibility_new;
                  break;
                default:
                  iconData = Icons.notifications;
                  break;
              }
              return Dismissible(
              key: Key('Key_$index'),
              background: Container(
                color: Colors.red,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                alignment: Alignment.center,
              ),
              onDismissed: (direction) {
                _pd.deleteNotification(index);
                debugPrint('delete the notification');
              },
              child: Container(
                width: 500, // Set the width of the ListTile
                child: ListTile(
                  tileColor: _pd.notificationRead[index]
                      ? Colors.grey[350]
                      : Colors.white,
                  leading: CircleAvatar(
                    backgroundColor: _pd.notificationRead[index]
                        ? Colors.grey
                        : Colors.blue,
                    child: Icon(
                      iconData,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    _pd.notificationTitles[index],
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    _pd.notificationBodies[index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Text("Mark as read"),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text("Delete"),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 1:
                          if (!_pd.notificationRead[index]) {
                            _pd.notificationRead[index] = true;
                            _pd.reload();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Notification Marked As Read'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Notification Already Read'),
                              ),
                            );
                          }
                          break;
                        case 2:
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirm Delete'),
                              content: Text('Are you sure you want to delete this notification?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () {
                                    _pd.deleteNotification(index);
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Notification Deleted'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                          break;
                      }
                    },
                  ),
                  onTap: () {
                    if (!_pd.notificationRead[index]) {
                      _pd.notificationRead[index] = true;
                      _pd.reload();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notification Marked As Read'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notification Already Read'),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
      ),
      ),
      ),
    );
  }
}