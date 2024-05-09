import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_view_json_flutter_2/screens/mini_list/bloc/mini_list_bloc.dart';

import 'screens/mini_list/mini_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MiniListBloc(),
      child: MaterialApp(
        title: 'Flutter Assessment',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: const MiniListScreen(),
      ),
    );
  }
}
