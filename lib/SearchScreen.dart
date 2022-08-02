import 'package:brotube/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'VideoScreen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Provider.of<APIYoutube>(context).videoSearchLoading
        ? const Text("Search for result")
        : Expanded(
            child: Provider.of<APIYoutube>(context).videoResultsPerPage == 0.0
                ? const Center(
                    child: Text("No Results Found"), //Not Working
                  )
                : NotificationListener<ScrollNotification>(
                    child: ListView.builder(
                      itemCount:
                          Provider.of<APIYoutube>(context).videoTitle.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: ListTile(
                            leading: SizedBox(
                              height: 100,
                              width: 100,
                              child: CachedNetworkImage(
                                  imageUrl: Provider.of<APIYoutube>(context)
                                      .videoThumbnailUrl[index]),
                            ),
                            title: Text(Provider.of<APIYoutube>(context)
                                .videoTitle[index]),
                            subtitle: Text(Provider.of<APIYoutube>(context)
                                .videoDescription[index]),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return VideoScreen(
                                  videoID: Provider.of<APIYoutube>(context)
                                      .videoID[index]);
                            }));
                          },
                        );
                      },
                    ),
                    onNotification: (ScrollNotification scrollInfo) {
                      print(
                          'This is scroll value: ${scrollInfo.metrics.pixels}');
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        print('Scroll end Triggered');
                        Provider.of<APIYoutube>(context, listen: false)
                            .getSearchModelLoadMore();
                      }
                      return false;
                    },
                  ),
          );
  }
}
