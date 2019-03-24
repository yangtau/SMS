enum Level { info, warnning, error }

var _default = Level.info;

log(String msg, {Level level = Level.info}) {
  if (level.index >= _default.index) {
    print('${DateTime.now()} $level: $msg');
  }
}
