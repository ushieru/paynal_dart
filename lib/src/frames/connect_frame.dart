import 'package:paynal/src/models/command.enum.dart';
import 'package:paynal/src/models/frame.dart';

Frame connectFrame(String user, String password, int heartbeatIncoming,
    int heartbeatOutgoing) {
  var headers = <String, String>{
    'heart-beat': [heartbeatIncoming, heartbeatOutgoing].join(','),
    'accept-version': '1.2',
    'login': user,
    'passcode': password
  };
  return Frame(Command.CONNECT, headers, '');
}
