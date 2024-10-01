import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YouTubePlayer(),
    );
  }
}

class YouTubePlayer extends StatefulWidget {
  @override
  _YouTubePlayerState createState() => _YouTubePlayerState();
}

class _YouTubePlayerState extends State<YouTubePlayer> {
  final String apiKey = 'AIzaSyDGwcunF_-YOAQCW8pSFb4GYe1yTWys6ik'; // Replace with your actual API key
  final List<String> videoUrls = [
    'https://www.youtube.com/watch?v=7n9DkOzjwlA', // Replace with an initial video ID
  ];
  int currentIndex = 0;
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Ensure WebView is initialized
    if (WebView.platform == SurfaceAndroidWebView()) {
      WebView.platform = SurfaceAndroidWebView();
    }
    fetchRelatedVideos(videoUrls[currentIndex].split('/').last); // Fetch related videos for the initial video
  }

  Future<void> fetchRelatedVideos(String videoId) async {
    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?relatedToVideoId=$videoId&part=id&type=video&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        videoUrls.clear(); // Clear existing URLs
        for (var item in data['items']) {
          videoUrls.add('https://www.youtube.com/embed/${item['id']['videoId']}');
        }
      });
    } else {
      throw Exception('Failed to load related videos');
    }
  }

  void _loadNextVideo() {
    setState(() {
      currentIndex = (currentIndex + 1) % videoUrls.length; // Loop back to start
    });
    _controller.loadUrl(videoUrls[currentIndex]);
    fetchRelatedVideos(videoUrls[currentIndex].split('/').last); // Fetch related videos for the new video
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Video Player'),
      ),
      body: Column(
        children: [
          Expanded(
            child: WebView(
              initialUrl: videoUrls[currentIndex],
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController controller) {
                _controller = controller;
              },
            ),
          ),
          ElevatedButton(
            onPressed: _loadNextVideo,
            child: Text('Next Suggested Video'),
          ),
        ],
      ),
    );
  }
}
