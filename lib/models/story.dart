
import 'package:instagram_histories/models/user.dart';

enum MediaType{
  image,
  video
}

class Story {
  final String url;
  final User user;
  final MediaType media;
  final Duration duration;

  Story({
  required this.url,
  required this.user,
  required this.media,
  required this.duration
  });
}