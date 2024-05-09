import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/mini_list_model.dart';
import '../../../services/mini_list_service.dart';
part 'mini_list_event.dart';
part 'mini_list_state.dart';

class MiniListBloc extends Bloc<MiniListEvent, MiniListState> {
  MiniListBloc() : super(MiniListLoading()) {
    on<LoadMiniList>(_onLoadMiniList);
  }

  Future<void> _onLoadMiniList(
      LoadMiniList event, Emitter<MiniListState> emit) async {
    await MiniListService().getMiniList(event.searchText).then((value) => {
          emit(
            MiniListLoaded(value!),
          )
        });
  }
}
