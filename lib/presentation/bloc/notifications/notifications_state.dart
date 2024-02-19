part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {

  final AuthorizationStatus authorizationStatus;

  final List<PushMessage> notifications;
  const NotificationsState({
    this.authorizationStatus = AuthorizationStatus.notDetermined, 
    this.notifications = const []
  });

  NotificationsState copyWith({
    AuthorizationStatus? authorizationStatus,
    List<PushMessage>? notifications,
  }) => NotificationsState(
    authorizationStatus: authorizationStatus ?? this.authorizationStatus,
    notifications: notifications ?? this.notifications
  );
  
  @override
  List<Object> get props => [ authorizationStatus, notifications ];
}
