import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String guid;
  final String title;
  final String body;
  final Map<String, dynamic> data;

  const NotificationEntity({
    required this.guid,
    required this.title,
    required this.body,
    required this.data,
  });

  @override
  List<Object?> get props => [guid, title, body, data];
}
