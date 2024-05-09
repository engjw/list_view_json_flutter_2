part of 'mini_list_bloc.dart';

@immutable
abstract class MiniListState extends Equatable {}

class MiniListLoading extends MiniListState {
  @override
  List<Object?> get props => [];
}

class MiniListLoaded extends MiniListState {
  final List<MiniListModel> miniListResponseData;

  MiniListLoaded(this.miniListResponseData);

  @override
  List<Object?> get props => [miniListResponseData];
}
