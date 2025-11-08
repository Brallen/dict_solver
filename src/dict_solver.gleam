import gleam/list
import gleam/result
import gleam/string
import gsv
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{div, input, p}
import lustre/event.{on_input}
import rsvp

// import simplifile

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

fn get_options(value: String, bank: List(String)) -> List(String) {
  let r_chars = {
    use #(a, a_rest) <- result.try(string.pop_grapheme(value))
    use #(b, b_rest) <- result.try(string.pop_grapheme(a_rest))
    use #(c, c_rest) <- result.try(string.pop_grapheme(b_rest))
    use #(d, d_rest) <- result.try(string.pop_grapheme(c_rest))
    use #(e, _e_rest) <- result.try(string.pop_grapheme(d_rest))
    Ok(#(a, b, c, d, e))
  }
  case r_chars {
    Ok(#(a, b, c, d, e)) -> [a, b, c, d, e]
    Error(_) -> []
  }
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ApiReturnedCSV(Ok(words)) -> #(Model(..model, bank: words), effect.none())
    ApiReturnedCSV(_) -> #(Model(..model, bank: []), effect.none())
    UserInput(value) -> #(
      Model(..model, options: get_options(value, model.bank)),
      effect.none(),
    )
  }
}

fn view(model: Model) -> Element(Msg) {
  div([], [
    input([on_input(fn(value) { UserInput(value) })]),
    div([], list.map(model.options, fn(option) { p([], [text(option)]) })),
  ])
}
