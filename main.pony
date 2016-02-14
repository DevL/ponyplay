use "term"
use "promises"


class CLIHandler is ReadlineNotify
  let state: State

  new create() =>
    state = State.create()

  fun ref apply(line: String, prompt: Promise[String]) =>
    if line == "quit" then
      prompt.reject()
    else
      prompt(state.handle(line))
    end


primitive EnterName
primitive EnterBreed
type CommandState is (EnterName | EnterBreed)

class State
  var _state: CommandState
  var _name: String
  var _breed: String

  new create() =>
    _state = EnterName
    _name = ""
    _breed = ""

  fun ref handle(input: String) : String =>
    match _state
    | EnterName => name_entered(input)
    | EnterBreed => breed_entered(input)
    else
      "This will never be called, yet we must ensure a String is returned."
    end

  fun ref name_entered(name: String) : String =>
    _state = EnterBreed
    _name = name
    "Enter breed: "

  fun ref breed_entered(breed: String) : String =>
    _state = EnterName
    _breed = breed
    "Enter name: "


actor Main
  new create(env: Env) =>
    let log: Log = Log.create(env.out, Info)
    let breeder = Breeder(log)
    let terminal = ANSITerm(Readline(recover CLIHandler end, env.out), env.input)
    terminal.prompt("You may have a pony! > ")

    breeder("Timmen", "Tinker")

    let notify = object iso
      let term: ANSITerm = terminal
      fun ref apply(data: Array[U8] iso) => term(consume data)
      fun ref dispose() => term.dispose()
    end

    env.input(consume notify)


actor Breeder
  let log: Log

  new create(log': Log) =>
    log = log'
    log.warn("Breeder created.")

  be apply(name: String, breed: String) =>
    log.info("Spawning a pony (" + breed + ") named " + name + "...")
    let pony = Pony.spawn(name, 0, breed, Stallion)


// Logging
primitive Info    fun apply(): String => "INFO"
primitive Warning fun apply(): String => "WARN"
primitive Failure fun apply(): String => "FAIL"
type LogLevel is (Info | Warning | Failure)

actor Log
  let output: StdStream
  let level: LogLevel

  new create(output': StdStream, level': LogLevel = Info) =>
    output = output'
    level = level'

  be info(message: String) =>
    if level() == Info() then
      log(Info() + ": " + message)
    end

  be warn(message: String) =>
    match level
    | Info => log(Warning() + ": " + message)
    | Warning => log(Warning() + ": " + message)
    else
      None
    end
    // if (level() == Info()) or (level() == Warning()) then
    //   log(Warning() + ": " + message)
    // end

  be fail(message: String) =>
    log(Failure() + ": " + message)

  fun log(message: String) =>
    output.print(message)


// Ponies
primitive Mare
primitive Gelding
primitive Stallion
type Gender is (Mare | Gelding | Stallion)

class Pony
  let name: String
  let age: U8
  let breed: String
  let gender: Gender

  new spawn(name': String, age': U8, breed': String, gender': Gender) =>
    name = name'
    age = age'
    breed = breed'
    gender = gender'


