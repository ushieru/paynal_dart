import 'package:uuid/uuid.dart';
import 'package:paynal/src/models/command.enum.dart';
import 'package:paynal/src/models/frame.dart';

Frame subscribeFrame(String destination, Map<String, String> headers) {
  if (!headers.containsKey('id')) headers['id'] = 'sub-${Uuid().v4()}';
  headers['destination'] = destination;
  return Frame(Command.SUBSCRIBE, headers, '');
}
