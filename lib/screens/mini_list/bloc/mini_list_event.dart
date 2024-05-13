part of 'mini_list_bloc.dart';

@immutable
abstract class MiniListEvent extends Equatable {
  const MiniListEvent();
}

class LoadFullContentEvent extends MiniListEvent {
  const LoadFullContentEvent();

  @override
  List<Object?> get props => [];
}

class LoadMiniListEvent extends MiniListEvent {
  final String searchText;
  final String fullContent;

  const LoadMiniListEvent(this.searchText, this.fullContent);

  @override
  List<Object?> get props => [];
}

class LoadMiniDetailEvent extends MiniListEvent {
  final String fullContent;
  final String id;

  const LoadMiniDetailEvent(this.fullContent, this.id);

  @override
  List<Object?> get props => [];
}
