import 'package:paynal/src/models/command.enum.dart';
import 'package:paynal/src/models/frame.dart';

Frame sendFrame(String destination, Map<String, String> headers, String body) {
  headers['destination'] = destination;
  return Frame(Command.SEND, headers, body);
}
