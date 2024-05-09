part of 'mini_list_bloc.dart';

@immutable
abstract class MiniListEvent extends Equatable {
  const MiniListEvent();
}

class LoadMiniList extends MiniListEvent {
  final String searchText;

  const LoadMiniList(this.searchText);

  @override
  List<Object?> get props => [];
}
