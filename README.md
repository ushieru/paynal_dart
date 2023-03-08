# Paynal 

Dart STOMP client implementation.

Paynal is a simple [STOMP v1.2](https://stomp.github.io/stomp-specification-1.2.html) implementation. STOMP (The Simple Text Oriented Messaging Protocol) is a very simple and easy to implement protocol, coming from the HTTP school of design.

## Usage:

```dart
import 'package:paynal/paynal.dart';

void main() {
  PaynalWebSocket('ws://127.0.0.1:15674/ws', 'guest', 'guest',
      onConnect: (socket) {
    final subscription = socket.subscribe('/queue/example', print);
    socket.send('/queue/example', body: 'example from socket 1');
    socket.send('/queue/example', body: 'example from socket 2');
    socket.send('/queue/example', body: 'example from socket 3');
    socket.send('/queue/example', body: 'example from socket 4');
    subscription.unsubscribe();
    socket.send('/queue/example', body: 'example from socket 5');
  });
}
```

## Support:
- [x] CONNECTED
- [x] CONNECT
- [x] SUBSCRIBE
- [x] MESSAGE
- [x] SEND
- [X] UNSUBSCRIBE
- [ ] ERROR
- [ ] ACK
- [ ] NACK
- [ ] BEGIN
- [ ] COMMIT
- [ ] ABORT
