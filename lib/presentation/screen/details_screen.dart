import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/domain/entitites/push_message.dart';
import 'package:push_app/presentation/bloc/notifications/notifications_bloc.dart';

class DetailsScreen extends StatelessWidget {
  
  final String pushMessageId;

  const DetailsScreen({
    super.key, 
    required this.pushMessageId
  });

  @override
  Widget build(BuildContext context) {

    final PushMessage? message = context.watch<NotificationsBloc>().getMessageById(pushMessageId);
    if (message == null) {
      return const Center(
        child: Text('Notificación no existe'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles Push'),
      ),
      body: _DetailsView(messages: message),
    );
  }
}

class _DetailsView extends StatelessWidget {

  final PushMessage messages;

  const _DetailsView({
    required this.messages
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [

          if (messages.imageUrl != null) 
            Image.network(messages.imageUrl!),

            const SizedBox(height: 30),

            Text(messages.title, style: textStyles.titleMedium),
            Text(messages.body),

            const Divider(),

            Text(messages.data.toString())
        ],
      ),
    );
  }
}