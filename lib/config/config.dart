import 'package:flutter_dotenv/flutter_dotenv.dart';

final String dropBoxIPConfigLink = dotenv.get('CLOUD_FILE_STORED_IP', fallback: '');
final bool showFilmPicture = bool.parse(dotenv.get('SHOW_FILM_PICTURE', fallback: "false"), caseSensitive: false);