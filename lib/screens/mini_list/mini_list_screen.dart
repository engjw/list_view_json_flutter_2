import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../values/styles.dart';
import 'bloc/mini_list_bloc.dart';

class MiniListScreen extends StatefulWidget {
  const MiniListScreen({super.key});
  @override
  State<MiniListScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MiniListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late MiniListBloc _miniListBloc;
  String _searchText = '';
  String _fullContent = '';

  @override
  void initState() {
    super.initState();
    _miniListBloc = BlocProvider.of<MiniListBloc>(context);
    _miniListBloc.add(const LoadFullContentEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130.0),
          child: AppBar(
            flexibleSpace: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Table Content', style: ValueStyles.headline),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontWeight: FontWeight.normal),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        fillColor: Colors.white.withOpacity(0.7),
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3), width: 0),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3), width: 0),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(Icons.search,
                              color: Colors.black.withOpacity(0.3)),
                        ),
                        suffixIcon: Visibility(
                          visible: _searchText.isNotEmpty,
                          child: IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                            ),
                            onPressed: () => {
                              setState(() {
                                _searchText = '';
                                _searchController.text = '';
                                _miniListBloc.add(LoadMiniListEvent(
                                    _searchText, _fullContent));
                              })
                            },
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _searchText = value;
                        });
                        _miniListBloc
                            .add(LoadMiniListEvent(_searchText, _fullContent));
                      },
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocConsumer<MiniListBloc, MiniListState>(
            listener: (context, state) {
              if (state is FullContentLoaded) {
                _fullContent = state.fullContentResponseData;
                _miniListBloc.add(LoadMiniListEvent(_searchText, _fullContent));
              }
              if (state is MiniDetailLoaded) {
                showMiniDetailsModalBottomSheet(
                    context, state.miniDetailResponseData);
                _miniListBloc.add(LoadMiniListEvent(_searchText, _fullContent));
              }
            },
            builder: (context, state) {
              return BlocBuilder<MiniListBloc, MiniListState>(
                builder: (context, state) {
                  if (state is MiniListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MiniListLoaded) {
                    if (state.miniListResponseData.isNotEmpty) {
                      return ListView.builder(
                        itemCount: state.miniListResponseData.length,
                        itemBuilder: (context, index) {
                          final mini = state.miniListResponseData[index];
                          return MiniListing(
                              title: mini.title ?? '',
                              id: mini.id ?? '',
                              onTap: () => _miniListBloc.add(
                                  LoadMiniDetailEvent(
                                      _fullContent, mini.id ?? '')));
                        },
                      );
                    } else {
                      return const Center(
                          child: Text(
                              "No results found. Please try a different search."));
                    }
                  }

                  return Container();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class MiniListing extends StatelessWidget {
  final String title;
  final String id;
  final VoidCallback onTap;

  const MiniListing(
      {super.key, required this.title, required this.id, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ValueStyles.titleBlack,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

void showMiniDetailsModalBottomSheet(
    BuildContext context, ContentResult miniDetail) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      builder: (context, controller) => Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    if (miniDetail.tableData != null)
                      CustomTableWidget(tableData: miniDetail.tableData!)
                    else
                      HtmlWidget(miniDetail.htmlContent),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

class CustomTableWidget extends StatelessWidget {
  final List<Map<String, String>> tableData;

  const CustomTableWidget({super.key, required this.tableData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: Theme.of(context).copyWith(
          dataTableTheme: DataTableThemeData(
            headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) => Theme.of(context).primaryColor),
            dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) => Colors.blue[50]),
            headingTextStyle: ValueStyles.titleWhite,
            dataTextStyle: ValueStyles.bodyBlack,
          ),
        ),
        child: DataTable(
          columns: _createColumns(),
          rows: _createRows(),
          columnSpacing: 38,
          horizontalMargin: 20,
        ),
      ),
    );
  }

  List<DataColumn> _createColumns() {
    if (tableData.isNotEmpty) {
      return tableData.first.keys
          .map((key) => DataColumn(label: Text(key)))
          .toList();
    }
    return [];
  }

  List<DataRow> _createRows() {
    return tableData.map((Map<String, String> row) {
      return DataRow(
          cells: row.values
              .map((value) => DataCell(
                    Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      child: Text(value),
                    ),
                  ))
              .toList());
    }).toList();
  }
}
