import dict_solver/utils
import gleam/list
import gleam/result
import gsv
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{div, input, label, p}
import lustre/event.{on_input}
import rsvp

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  let model = Model([], [], "", [])
  let effect = fetch_csv()

  #(model, effect)
}

fn fetch_csv() -> Effect(Msg) {
  let url = "./priv/static/word-bank.csv"
  let handler =
    rsvp.expect_text(fn(response) {
      case response {
        Ok(results) -> {
          let res =
            gsv.to_lists(results, separator: ",")
            |> result.map(list.flatten)
            |> result.unwrap([])
          ApiReturnedCSV(Ok(res))
        }
        Error(_e) -> ApiReturnedCSV(Ok([]))
      }
    })
  rsvp.get(url, handler)
}

type Model {
  Model(
    bank: List(String),
    options: List(String),
    word_letters: String,
    unused_letters: List(String),
  )
}

type Msg {
  ApiReturnedCSV(Result(List(String), rsvp.Error))
  WordInput(value: String)
  UnusedLettersInput(value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ApiReturnedCSV(Ok(words)) -> #(Model(..model, bank: words), effect.none())
    ApiReturnedCSV(_) -> #(Model(..model, bank: []), effect.none())
    WordInput(value) -> #(
      Model(
        ..model,
        word_letters: value,
        options: utils.get_options(value, model.bank, model.unused_letters),
      ),
      effect.none(),
    )
    UnusedLettersInput(value) -> {
      let letters = utils.get_list_of_chars_from_string(value, [])
      #(
        Model(
          ..model,
          unused_letters: letters,
          options: utils.get_options(model.word_letters, model.bank, letters),
        ),
        effect.none(),
      )
    }
  }
}

fn view(model: Model) -> Element(Msg) {
  div([attribute.class("wrapper")], [
    div([attribute.class("inputs")], [
      div([attribute.class("input_wrapper")], [
        label([attribute.for("word_input")], [text("Wordle Letters")]),
        input([
          attribute.name("word_input"),
          attribute.class("word_input"),
          on_input(fn(value) { WordInput(value) }),
        ]),
      ]),
      div([attribute.class("input_wrapper")], [
        label([attribute.for("unused_letters_input")], [text("Unused Letters")]),
        input([
          attribute.name("unused_letters_input"),
          attribute.class("unused_letters_input"),
          on_input(fn(value) { UnusedLettersInput(value) }),
        ]),
      ]),
    ]),
    div(
      [attribute.class("answer_wrapper")],
      list.map(model.options, fn(option) { p([], [text(option)]) }),
    ),
  ])
}
