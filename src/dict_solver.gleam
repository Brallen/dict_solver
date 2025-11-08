import dict_solver/utils
import gleam/list
import gleam/result
import gsv
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{div, input, p}
import lustre/event.{on_input}
import rsvp

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  let model = Model([], [])
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
  Model(bank: List(String), options: List(String))
}

type Msg {
  ApiReturnedCSV(Result(List(String), rsvp.Error))
  UserInput(value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ApiReturnedCSV(Ok(words)) -> #(Model(..model, bank: words), effect.none())
    ApiReturnedCSV(_) -> #(Model(..model, bank: []), effect.none())
    UserInput(value) -> #(
      Model(..model, options: utils.get_options(value, model.bank)),
      effect.none(),
    )
  }
}

fn view(model: Model) -> Element(Msg) {
  div([attribute.class("wrapper")], [
    input([
      attribute.class("word_input"),
      on_input(fn(value) { UserInput(value) }),
    ]),
    div(
      [attribute.class("answer_wrapper")],
      list.map(model.options, fn(option) { p([], [text(option)]) }),
    ),
  ])
}
