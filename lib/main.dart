import 'package:brotube/SearchScreen.dart';

import 'package:flutter/material.dart';

import 'package:brotube/services/service_api.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const BroTube());
}

class BroTube extends StatelessWidget {
  const BroTube({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => APIYoutube(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BroTube',
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Provider.of<APIYoutube>(context, listen: false).getChannelModel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Search",
                    ),
                  ),
                ),
                IconButton(
                    onPressed: (() {
                      Provider.of<APIYoutube>(context, listen: false)
                          .getSearchModel(search: _textEditingController.text);
                    }),
                    icon: const Icon(Icons.search))
              ]),
              SearchScreen()
            ],
          ),
        ),
      ),
    );
  }
}
