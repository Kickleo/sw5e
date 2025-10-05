import 'package:equatable/equatable.dart';

sealed class RemoteArticlesEvent extends Equatable {
  const RemoteArticlesEvent();
  @override
  List<Object?> get props => [];
}

class RemoteArticlesRequested extends RemoteArticlesEvent {
  final String? country;
  final String? category;
  const RemoteArticlesRequested({this.country, this.category});

  @override
  List<Object?> get props => [country, category];
}