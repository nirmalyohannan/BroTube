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
    Map<String, dynamic> json = jsonDecode(response.body);

    channelVideoCount = json['items'][0]['statistics']['videoCount'];
    channelThumbnailUrl =
        json['items'][0]['snippet']['thumbnails']['default']['url'];
    channelTitle = json['items'][0]['snippet']['localized']['title'];
    // print('$channelTitle , $channelVideoCount , $channelThumbnailUrl');
    channelLoading = false;
    notifyListeners();
    // print("NotifyListener called");
    // print('Channel loading : $channelLoading');
    //return false;
  }

////////////////////////////////////////////////////////////////////////////

  Future<void> getSearchModel({required String search}) async {
    videoTitle.clear();
    videoDescription.clear();
    videoThumbnailUrl.clear();
    Map<String, String> parameters = {
      'part': 'snippet',
      'q': search,
      'key': API_KEY,
    };
    Map<String, String> header = {
      HttpHeaders.contentTypeHeader: 'application/json'
    };

    Uri uri = Uri.https(
      _baseURL,
      'youtube/v3/search',
      parameters,
    );

    Response response = await http.get(uri, headers: header);
    Map<String, dynamic> json = jsonDecode(response.body);

    int nthResult = 0;
    int videoResultsPerPage = json['pageInfo']['resultsPerPage'];
    print("Video Results Per Page: $videoResultsPerPage");
    if (videoResultsPerPage != 0) {}
    while (nthResult < videoResultsPerPage) {
      videoTitle.add(json['items'][nthResult]['snippet']['title']);
      videoThumbnailUrl.add(
          json['items'][nthResult]['snippet']['thumbnails']['medium']['url']);
      videoDescription.add(json['items'][nthResult]['snippet']['description']);

      // print(videoTitle[nthResult]);
      //print(videoDescription[nthResult]);
      //print(videoThumbnailUrl[nthResult]);
      nthResult++;
    }

    videoSearchLoading = false;
    //print('Video Searching status: ${videoSearchLoading.toString()}');
    notifyListeners();
    if (json['nextPageToken'] != null) {
      nextPageToken = json['nextPageToken'];
      print('this is the next page toke : $nextPageToken');

      parameters = {
        'part': 'snippet',
        'pageToken': nextPageToken,
        'q': search,
        'key': API_KEY,
      };
      uri = Uri.https(
        _baseURL,
        'youtube/v3/search',
        parameters,
      );

      response = await http.get(uri, headers: header);
      json = jsonDecode(response.body);
      nthResult = 0;
      while (nthResult < videoResultsPerPage) {
        videoTitle.add(json['items'][nthResult]['snippet']['title']);
        videoThumbnailUrl.add(
            json['items'][nthResult]['snippet']['thumbnails']['medium']['url']);
        videoDescription
            .add(json['items'][nthResult]['snippet']['description']);

        nthResult++;
      }
      notifyListeners();
    }
  }
}
