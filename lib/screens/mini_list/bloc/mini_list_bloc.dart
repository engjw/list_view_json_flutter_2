import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

import '../../../models/mini_list_model.dart';
import '../../../services/mini_list_service.dart';
part 'mini_list_event.dart';
part 'mini_list_state.dart';

class MiniListBloc extends Bloc<MiniListEvent, MiniListState> {
  MiniListBloc() : super(MiniListLoading()) {
    on<LoadFullContentEvent>(_onLoadFullContent);
    on<LoadMiniListEvent>(_onLoadMiniList);
    on<LoadMiniDetailEvent>(_onLoadMiniDetail);
  }

  Future<void> _onLoadFullContent(
      LoadFullContentEvent event, Emitter<MiniListState> emit) async {
    await MiniListService()
        .loadFullContent()
        .then((value) => {emit(FullContentLoaded(value ?? ''))});
  }

  Future<void> _onLoadMiniList(
      LoadMiniListEvent event, Emitter<MiniListState> emit) async {
    List<MiniListModel> miniList = extractTitlesAndIds(event.fullContent);
    if (event.searchText.isNotEmpty) {
      miniList = miniList
          .where((item) => item.title!
              .toLowerCase()
              .contains(event.searchText.toLowerCase()))
          .toList();
    }
    emit(MiniListLoaded(miniList));
  }

  Future<void> _onLoadMiniDetail(
      LoadMiniDetailEvent event, Emitter<MiniListState> emit) async {
    emit(MiniDetailLoaded(extractContent(event.fullContent, event.id)));
  }
}

List<MiniListModel> extractTitlesAndIds(String htmlContent) {
  var document = parse(htmlContent);
  List<MiniListModel> miniList = [];
  var h2Elements = document.querySelectorAll('h2');
  for (var element in h2Elements) {
    var span = element.querySelector('span[id]');
    if (span != null && span.id.isNotEmpty) {
      var title = element.text.trim();
      var id = span.id;
      miniList.add(MiniListModel(title: title, id: id));
    }
  }
  return miniList;
}

ContentResult extractContent(String htmlContent, String id) {
  var document = parse(htmlContent);
  StringBuffer extractedContent = StringBuffer();
  bool startCollecting = false;

  dom.Element? startElement =
      document.querySelector('h2 span[id="$id"]')?.parent;
  if (startElement != null) {
    dom.Element? currentElement = startElement;
    while (currentElement != null) {
      if (startCollecting) {
        if (currentElement.localName == 'h2' &&
            currentElement != startElement) {
          break;
        }
        extractedContent.write(currentElement.outerHtml);
      } else {
        extractedContent.write(currentElement.outerHtml);
        startCollecting = true;
      }
      currentElement = currentElement.nextElementSibling;
    }
  }
  var tempDoc = parse(extractedContent.toString());
  if (tempDoc.querySelector('table') != null) {
    return ContentResult(
        htmlContent: extractedContent.toString(),
        tableData: extractTableData(extractedContent.toString()));
  } else {
    return ContentResult(
        htmlContent: simplifyImageTags(extractedContent.toString()));
  }
}

String simplifyImageTags(String htmlContent) {
  var document = parse(htmlContent);

  document.querySelectorAll('img').forEach((img) {
    var src = img.attributes['data-src'] ?? img.attributes['src'];
    var newImgTag = '<img src="$src" />';
    img.replaceWith(parseFragment(newImgTag));
  });

  document.querySelectorAll('noscript').forEach((noscript) {
    noscript.remove();
  });

  return document.body?.innerHtml ?? '';
}

List<Map<String, String>> extractTableData(String htmlContent) {
  var document = parse(htmlContent);
  List<Map<String, String>> tableData = [];

  var tables = document.querySelectorAll('table');
  for (var table in tables) {
    var headers = table
        .querySelectorAll('tr')
        .first
        .children
        .map((th) => th.text.trim())
        .toList();
    var rows = table.querySelectorAll('tr').skip(1);

    for (var row in rows) {
      var rowData = <String, String>{};
      var cells = row.children.map((td) => td.text.trim()).toList();
      for (int i = 0; i < headers.length && i < cells.length; i++) {
        rowData[headers[i]] = cells[i];
      }
      tableData.add(rowData);
    }
  }

  return tableData;
}
