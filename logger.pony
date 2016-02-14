primitive Debug   fun apply(): String => "DEBUG"
primitive Info    fun apply(): String => "INFO"
primitive Warning fun apply(): String => "WARN"
primitive Failure fun apply(): String => "FAIL"
type LogLevel is (Debug | Info | Warning | Failure)

actor Logger
  let output: StdStream
  var level: LogLevel

  new create(output': StdStream, level': LogLevel = Info) =>
    output = output'
    level = level'

  be set_log_level(level': LogLevel) =>
    level = level'

  be log(message: String) =>
    output.print(message)

  be debug(message: String) =>
    maybe_log(Debug() + ": " + message, Debug)

  be info(message: String) =>
    maybe_log(Info() + ": " + message, Info)

  be warn(message: String) =>
    maybe_log(Warning() + ": " + message, Warning)

  be fail(message: String) =>
    maybe_log(Failure() + ": " + message, Failure)

  fun maybe_log(message: String, message_level: LogLevel) =>
    match (message_level(), level())
    | (level(), level())      => this.log(message)
    | (_, Debug())            => this.log(message)
    | (Warning(), Info())     => this.log(message)
    | (Failure(), Info())     => this.log(message)
    | (Failure(), Warning())  => this.log(message)
    end
