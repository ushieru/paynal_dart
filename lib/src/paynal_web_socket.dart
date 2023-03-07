import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:paynal/src/models/bytes.dart';
import 'package:paynal/src/models/frame.dart';
import 'package:paynal/src/models/paynal_socket.dart';

class PaynalWebSocket extends PaynalSocket {
  late WebSocketChannel _socket;

  PaynalWebSocket(String url, String username, String password,
      {void Function(PaynalWebSocket webSocket)? onConnect}) {
    _socket = WebSocketChannel.connect(Uri.parse(url));
    _socket.stream.listen((event) => $listener(event.toString()));
    $connect(username, password, onConnect: () {
      if (onConnect != null) onConnect(this);
    });
  }

  @override
  void $sendFrame(Frame frame) {
    _socket.sink.add(frame.toString());
  }

  @override
  void $sendPing() => _socket.sink.add(breakByte);

  @override
  void $closeConnection() {
    $closeSocket();
    _socket.sink.close();
  }
}
