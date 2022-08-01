import 'dart:convert';
import 'package:brotube/utilities/credentials.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class APIYoutube with ChangeNotifier {
  static const CHANNEL_ID = 'UC8k-sxMI1EHlHKhq3VQ4kJQ';
  static const _baseURL = 'www.googleapis.com';
///////////////////////////////////
  String channelThumbnailUrl = '';
  String channelTitle = '';
  String channelVideoCount = '';
  bool channelLoading = true;
////////////////////////////////////

  String searchNextPageToken = '';
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json'
  };
  String videoSearchString = '';
  bool videoSearchLoading = true;
  int videoResultsPerPage = 5;
  String nextPageToken = '';
  List<String> videoTitle = List.filled(0, '', growable: true); //Is Nullable
  List<String> videoThumbnailUrl =
      List.filled(0, '', growable: true); //Is Nullable
  List<String> videoDescription = List.filled(0, '', growable: true); //Nullable
////////////////////////////////////

  Future<void> getChannelModel() async {
    //print('GetResponse started execution');

    Map<String, String> parameters = {
      'part': 'snippet,contentDetails,statistics',
      'id': CHANNEL_ID,
      'key': API_KEY //HIDE API_KEY in Credentials
    };
    Map<String, String> header = {
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    Uri uri = Uri.https(
      _baseURL,
      'youtube/v3/channels',
      parameters,
    );
    // print("Response requesting");
    Response response = await http.get(uri, headers: header);
    Map<String, dynamic> jsonChannel = jsonDecode(response.body);

    channelVideoCount = jsonChannel['items'][0]['statistics']['videoCount'];
    channelThumbnailUrl =
        jsonChannel['items'][0]['snippet']['thumbnails']['default']['url'];
    channelTitle = jsonChannel['items'][0]['snippet']['localized']['title'];
    // print('$channelTitle , $channelVideoCount , $channelThumbnailUrl');
    channelLoading = false;
    notifyListeners();
    // print("NotifyListener called");
    // print('Channel loading : $channelLoading');
    //return false;
  }

////////////////////////////////////////////////////////////////////////////

  Future<void> getSearchModel({required String search}) async {
    ///////////
    try {
      ////THis is temporary code to check internet availability
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');
    }
////////////
    videoSearchString = search;
    videoSearchLoading = true;
    videoTitle.clear();
    videoDescription.clear();
    videoThumbnailUrl.clear();
    Map<String, String> parameters = {
      'part': 'snippet',
      'q': videoSearchString,
      'key': API_KEY,
    };

    Uri uri = Uri.https(
      _baseURL,
      'youtube/v3/search',
      parameters,
    );

    Response response = await http.get(uri, headers: header);
    Map<String, dynamic> jsonSearchResult = jsonDecode(response.body);
    print(jsonSearchResult);

    int nthResult = 0;
    int videoResultsPerPage = jsonSearchResult['pageInfo']['resultsPerPage'];
    print("Video Results Per Page: $videoResultsPerPage");
    if (videoResultsPerPage != 0) {}
    while (nthResult < videoResultsPerPage) {
      videoTitle.add(jsonSearchResult['items'][nthResult]['snippet']['title']);
      videoThumbnailUrl.add(jsonSearchResult['items'][nthResult]['snippet']
          ['thumbnails']['medium']['url']);
      videoDescription
          .add(jsonSearchResult['items'][nthResult]['snippet']['description']);

      // print(videoTitle[nthResult]);
      //print(videoDescription[nthResult]);
      //print(videoThumbnailUrl[nthResult]);
      nthResult++;
    }

    videoSearchLoading = false;
    //print('Video Searching status: ${videoSearchLoading.toString()}');
    notifyListeners();
    if (jsonSearchResult['nextPageToken'] != null) {
      searchNextPageToken = jsonSearchResult['nextPageToken'];
    }

    getSearchModelLoadMore();
    getSearchModelLoadMore();
  }

  Future getSearchModelLoadMore() async {
    if (videoSearchLoading == false) {
      if (searchNextPageToken != '') {
        print('this is the next page toke : $searchNextPageToken');

        Map<String, String> parameters = {
          'part': 'snippet',
          'pageToken': searchNextPageToken,
          'q': videoSearchString,
          'key': API_KEY,
        };
        Uri uri = Uri.https(
          _baseURL,
          'youtube/v3/search',
          parameters,
        );

        Response response = await http.get(uri, headers: header);
        Map<String, dynamic> jsonSearchResult = jsonDecode(response.body);
        int nthResult = 0;
        while (nthResult < videoResultsPerPage) {
          videoTitle
              .add(jsonSearchResult['items'][nthResult]['snippet']['title']);
          videoThumbnailUrl.add(jsonSearchResult['items'][nthResult]['snippet']
              ['thumbnails']['medium']['url']);
          videoDescription.add(
              jsonSearchResult['items'][nthResult]['snippet']['description']);

          nthResult++;
        }
        notifyListeners();
      }
    } else {
      while (videoSearchLoading) {}
    }
  }
}
