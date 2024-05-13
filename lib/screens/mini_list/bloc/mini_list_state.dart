part of 'mini_list_bloc.dart';

@immutable
abstract class MiniListState extends Equatable {}

class MiniListLoading extends MiniListState {
  @override
  List<Object?> get props => [];
}

class FullContentLoaded extends MiniListState {
  final String fullContentResponseData;

  FullContentLoaded(this.fullContentResponseData);

  @override
  List<Object?> get props => [fullContentResponseData];
}

class MiniListLoaded extends MiniListState {
  final List<MiniListModel> miniListResponseData;

  MiniListLoaded(this.miniListResponseData);

  @override
  List<Object?> get props => [miniListResponseData];
}

class MiniDetailLoaded extends MiniListState {
  final ContentResult miniDetailResponseData;

  MiniDetailLoaded(this.miniDetailResponseData);

  @override
  List<Object?> get props => [miniDetailResponseData];
}

class ContentResult {
  final String htmlContent;
  final List<Map<String, String>>? tableData;

  ContentResult({this.htmlContent = '', this.tableData});
}
