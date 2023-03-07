// ignore_for_file: constant_identifier_names

enum Command {
  CONNECTED,
  CONNECT,
  SUBSCRIBE,
  ERROR,
  MESSAGE,
  SEND,
  UNSUBSCRIBE,
  UNKNOWN
}

Command stringToCommand(String commandStr) =>
    Command.values.firstWhere((command) => commandStr == command.name,
        orElse: () => Command.UNKNOWN);
