import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entitites/push_message.dart';

import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int pushNumberId = 0;

  final Future<void> Function() requestLocalNotificationPermissions;
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data
  }) showLocalNotification;

  NotificationsBloc({
    required this.requestLocalNotificationPermissions,
    required this.showLocalNotification
  }) : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationStatusChanged);

    on<NotificationReceived>(_onPushMessageReceived);

    //* Verificar el status del permiso
    _initialStatusCheck();
    //* Listener
    _onForegroundMessage();
  }

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationStatusChanged(NotificationStatusChanged event, Emitter<NotificationsState> emit) {
    emit(
      state.copyWith(
        authorizationStatus: event.authorizationStatus
      )
    );

    _getFCMToken();
  }

  void _onPushMessageReceived(NotificationReceived event, Emitter<NotificationsState> emit) {
    emit(
      state.copyWith(
        notifications: [ event.pushMessage, ...state.notifications ]
      )
    );
  }

  void _getFCMToken() async {
    if (state.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    final token = await messaging.getToken();
    print(token);
  } 

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) {
      return;
    }
    final notification = PushMessage(
      messageId: message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '', 
      title: message.notification!.title ?? '', 
      body: message.notification!.body ?? '', 
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid 
        ? message.notification!.android?.imageUrl
        : message.notification!.apple?.imageUrl

    );

    showLocalNotification(
      id: ++pushNumberId,
      body: notification.body,
      title: notification.title,
      data: notification.messageId
    );

    add(NotificationReceived(notification));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));

    _getFCMToken();
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    //Permiso a las local notifications
    await requestLocalNotificationPermissions();

    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exist = state.notifications.any((element) => element.messageId == pushMessageId);

    if (!exist) {
      return null;
    }

    return state.notifications.firstWhere((element) => element.messageId == pushMessageId);
  }
}