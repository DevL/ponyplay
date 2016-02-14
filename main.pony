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
    let log: Logger = Logger.create(env.out, Debug)
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
    log.info("We should see this.")
    log.set_log_level(Warning)
    log.info("Maybe not this.")
    log.warn("This we should see though.")


actor Breeder
  let log: Logger

  new create(log': Logger) =>
    log = log'
    log.debug("Breeder created.")

  be apply(name: String, breed: String) =>
    log.info("Spawning a pony (" + breed + ") named " + name + "...")
    let pony = Pony.spawn(name, 0, breed, Stallion)


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


