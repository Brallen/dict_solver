import gleam/list
import gleam/result
import gleam/string

pub fn get_options(value: String, bank: List(String)) -> List(String) {
  let lower = string.lowercase(value)
  let r_chars = get_first_five_chars_from_string(lower)

  case r_chars {
    Ok(chars) -> get_options_from_chars(chars, bank)
    Error(_) -> []
  }
}

fn get_first_five_chars_from_string(
  value: String,
) -> Result(#(String, String, String, String, String), Nil) {
  use #(a, a_rest) <- result.try(string.pop_grapheme(value))
  use #(b, b_rest) <- result.try(string.pop_grapheme(a_rest))
  use #(c, c_rest) <- result.try(string.pop_grapheme(b_rest))
  use #(d, d_rest) <- result.try(string.pop_grapheme(c_rest))
  use #(e, _e_rest) <- result.try(string.pop_grapheme(d_rest))
  Ok(#(a, b, c, d, e))
}

fn get_options_from_chars(
  chars: #(String, String, String, String, String),
  bank: List(String),
) -> List(String) {
  let #(a, b, c, d, e) = chars
  list.filter(bank, fn(bank_word) {
    let bank_chars = get_first_five_chars_from_string(bank_word)
    case bank_chars {
      Ok(#(bank_a, bank_b, bank_c, bank_d, bank_e)) -> {
        is_same_or_underscore(a, bank_a)
        && is_same_or_underscore(b, bank_b)
        && is_same_or_underscore(c, bank_c)
        && is_same_or_underscore(d, bank_d)
        && is_same_or_underscore(e, bank_e)
      }
      Error(_) -> False
    }
  })
}

fn is_same_or_underscore(
  possible_underscore_char: String,
  char_2: String,
) -> Bool {
  case possible_underscore_char {
    "_" -> True
    char -> char == char_2
  }
}
