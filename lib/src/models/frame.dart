import 'package:paynal/src/models/command.enum.dart';
import 'package:paynal/src/models/bytes.dart';
import 'package:paynal/src/utils/trim_null.dart';

class Frame {
  Frame(this.command, this.headers, this.body);

  final Command command;
  final Map<String, String> headers;
  final String body;

  factory Frame.fromString(String payload) {
    final commandheadersRawBody = payload.split('$breakByte$breakByte');
    final commandAndHeaders = commandheadersRawBody[0];
    final rawBody = commandheadersRawBody[1];
    final commandHeaders = commandAndHeaders.split(breakByte);
    final command = commandHeaders[0];
    final rawHeaders = commandHeaders.sublist(1);
    final body = trimNull(rawBody);
    final Map<String, String> headers = {};
    for (var rawHeader in rawHeaders) {
      final header = rawHeader.split(':');
      headers[header[0]] = header[1];
    }
    return Frame(stringToCommand(command), headers, body);
  }

  @override
  toString() {
    final stringBuilder = [command.name];
    final headersList =
        headers.entries.map<String>((entry) => '${entry.key}:${entry.value}');
    if (headersList.isNotEmpty) stringBuilder.add(headersList.join(breakByte));
    stringBuilder.add(breakByte);
    if (body.isNotEmpty) stringBuilder.add(body);
    stringBuilder.add(nullByte);
    return stringBuilder.join(breakByte);
  }
}
