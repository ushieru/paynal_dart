import 'dart:async';
import 'dart:math';
import 'package:meta/meta.dart';
import 'package:paynal/src/models/bytes.dart';
import 'package:paynal/src/models/command.enum.dart';
import 'package:paynal/src/models/frame.dart';
import 'package:paynal/src/frames/frames.dart';

abstract class PaynalSocket {
  bool _connected = false;
  String _session = '00_paynal_00';
  final Map<String, void Function(Frame frame)> _subscriptions = {};

  Timer? _pingTimer;
  Timer? _pongTimer;
  int _serverActivity = DateTime.now().millisecondsSinceEpoch;

  int _heartbeatOutgoing = 0;
  int _heartbeatIncoming = 0;

  void Function()? _onConnect;

  void send(String destination, {Map<String, String>? headers, String? body}) {
    $sendFrame(sendFrame(destination, headers ?? {}, body ?? ''));
  }

  Subscription subscribe(
      String destination, void Function(Frame frame) callback,
      {Map<String, String>? headers}) {
    final frame = subscribeFrame(destination, headers ?? {});
    final subscriptionId = frame.headers['id']!;
    _subscriptions[subscriptionId] = callback;
    $sendFrame(frame);
    return Subscription(subscriptionId, () => $unsubscribe(subscriptionId));
  }

  @protected
  void $connect(String user, String password,
      {int heartbeatIncoming = 10000,
      int heartbeatOutgoing = 10000,
      void Function()? onConnect}) {
    _heartbeatIncoming = heartbeatIncoming;
    _heartbeatOutgoing = heartbeatOutgoing;
    _onConnect = onConnect;
    $sendFrame(
        connectFrame(user, password, heartbeatIncoming, heartbeatOutgoing));
  }

  @protected
  void $unsubscribe(String id) {
    _subscriptions.remove(id);
    $sendFrame(unsubscribeFrame(id));
  }

  @protected
  void $setupHeartbeat(Map<String, String> headers) {
    if (!['1.1', '1.2'].contains(headers['version'])) return;
    final serverTimers = headers['heart-beat']
        ?.split(',')
        .map((beat) => int.tryParse(beat) ?? 0)
        .toList();
    final serverOutgoing = serverTimers?[0] ?? 0;
    final serverIncoming = serverTimers?[1] ?? 0;
    if (!(_heartbeatOutgoing == 0 || serverIncoming == 0)) {
      final timeDuration = max(_heartbeatOutgoing, serverIncoming);
      print('ping every $timeDuration ms');
      Timer.periodic(Duration(milliseconds: timeDuration), (timer) {
        _pingTimer = timer;
        $sendPing();
        print('>>> PING');
      });
    }
    if (!(_heartbeatIncoming == 0 || serverOutgoing == 0)) {
      final timeDuration = max(_heartbeatIncoming, serverOutgoing);
      print('pong every $timeDuration ms');
      Timer.periodic(Duration(milliseconds: timeDuration), (timer) {
        _pongTimer = timer;
        final inactiveTime =
            DateTime.now().millisecondsSinceEpoch - _serverActivity;
        if (inactiveTime > timeDuration * 2) {
          $closeSocket();
          $closeConnection();
        }
      });
    }
  }

  @protected
  void $listener(String payload) {
    _serverActivity = DateTime.now().millisecondsSinceEpoch;
    if (payload == breakByte) {
      print('>>> PONG');
      return;
    }

    final frame = Frame.fromString(payload);

    switch (frame.command) {
      case Command.CONNECTED:
        _connected = true;
        _session = frame.headers['session']!;
        $setupHeartbeat(frame.headers);
        if (_onConnect != null) _onConnect!();
        break;
      case Command.MESSAGE:
        final subscriptionId = frame.headers['subscription']!;
        final subscription = _subscriptions[subscriptionId];
        if (subscription == null) {
          return print('Unhandled received MESSAGE: $frame');
        }
        subscription(frame);
        break;
      default:
        print('--- Unhandled frame ---');
        print(frame.toString());
        print('-----------------------');
    }
  }

  @protected
  void $closeSocket() {
    _connected = false;
    _pingTimer?.cancel();
    _pongTimer?.cancel();
  }

  bool get connected => _connected;

  String get session => _session;

  @protected
  void $sendPing();

  @protected
  void $closeConnection();

  @protected
  void $sendFrame(Frame frame);
}

class Subscription {
  Subscription(this.id, this.unsubscribe);
  String id;
  void Function() unsubscribe;
}
