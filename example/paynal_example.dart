import 'package:paynal/paynal.dart';

void main() {
  PaynalWebSocket('ws://127.0.0.1:15674/ws', 'guest', 'guest',
      onConnect: (socket) {
    final subscription = socket.subscribe('/queue/example', print);
    socket.send('/queue/example', body: 'example from web socket 1');
    socket.send('/queue/example', body: 'example from web socket 2');
    socket.send('/queue/example', body: 'example from web socket 3');
    socket.send('/queue/example', body: 'example from web socket 4');
    subscription.unsubscribe();
    socket.send('/queue/example', body: 'example from web socket 5');
  });
}
