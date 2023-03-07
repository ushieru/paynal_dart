import 'package:paynal/src/models/command.enum.dart';
import 'package:paynal/src/models/frame.dart';

Frame unsubscribeFrame(String id) {
  return Frame(Command.UNSUBSCRIBE, {'id': id}, '');
}
