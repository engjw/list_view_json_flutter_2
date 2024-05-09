import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

import '../../models/mini_list_model.dart';
import '../../values/styles.dart';
import 'bloc/mini_list_bloc.dart';

String? _htmlData;

class MiniListScreen extends StatefulWidget {
  const MiniListScreen({super.key});
  @override
  State<MiniListScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MiniListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late MiniListBloc _miniListBloc;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _miniListBloc = BlocProvider.of<MiniListBloc>(context);
    _miniListBloc.add(LoadMiniList(searchText));
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        'https://garagedreams.net/buyers-guide/first-gen-mini-r50-r52-r53-buyers-guide'));
    if (response.statusCode == 200) {
      setState(() {
        _htmlData = response.body;
      });
    } else {
      throw Exception('Failed to load');
    }
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
                          visible: searchText.isNotEmpty,
                          child: IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                            ),
                            onPressed: () => {
                              setState(() {
                                searchText = '';
                                _searchController.text = '';
                                _miniListBloc.add(LoadMiniList(searchText));
                              })
                            },
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          searchText = value;
                        });
                        _miniListBloc.add(LoadMiniList(searchText));
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
          child: BlocBuilder<MiniListBloc, MiniListState>(
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
                        onTap: () =>
                            showMiniDetailsModalBottomSheet(context, mini),
                      );
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
                style: ValueStyles.title,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

void showMiniDetailsModalBottomSheet(BuildContext context, MiniListModel mini) {
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
                    HtmlWidget(simplifyImageTags(
                        extractContent(_htmlData ?? '', mini.id!))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String extractContent(String htmlContent, String id) {
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
  return extractedContent.toString();
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
