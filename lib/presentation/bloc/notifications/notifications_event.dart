part of 'notifications_bloc.dart';

sealed class NotificationsEvent{
  const NotificationsEvent();
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus authorizationStatus;

  NotificationStatusChanged(this.authorizationStatus);
}

class NotificationReceived extends NotificationsEvent {
  final PushMessage pushMessage;

  NotificationReceived(this.pushMessage);
}