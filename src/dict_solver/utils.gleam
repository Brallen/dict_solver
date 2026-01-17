import gleam/list
import gleam/result
import gleam/string

pub fn get_options(
  word_letters: String,
  bank: List(String),
  unused_letters: List(String),
) -> List(String) {
  let lower = string.lowercase(word_letters)
  let r_chars = get_first_five_chars_from_string(lower)

  case r_chars {
    Ok(chars) -> get_options_from_chars(chars, bank, unused_letters)
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

pub fn get_list_of_chars_from_string(
  value: String,
  list: List(String),
) -> List(String) {
  let r_res = string.pop_grapheme(value)
  case r_res {
    Ok(#(char, rest)) -> get_list_of_chars_from_string(rest, [char, ..list])
    Error(_) -> list
  }
}

fn get_options_from_chars(
  chars: #(String, String, String, String, String),
  bank: List(String),
  unused_letters: List(String),
) -> List(String) {
  let #(a, b, c, d, e) = chars
  list.filter(bank, fn(bank_word) {
    let bank_chars = get_first_five_chars_from_string(bank_word)
    case bank_chars {
      Ok(#(bank_a, bank_b, bank_c, bank_d, bank_e)) -> {
        is_same_or_wildcard(a, bank_a)
        && is_same_or_wildcard(b, bank_b)
        && is_same_or_wildcard(c, bank_c)
        && is_same_or_wildcard(d, bank_d)
        && is_same_or_wildcard(e, bank_e)
        && !list.any(unused_letters, fn(letter) {
          string.contains(bank_word, letter)
        })
      }
      Error(_) -> False
    }
  })
}

fn is_same_or_wildcard(possible_wildcard_char: String, char_2: String) -> Bool {
  case possible_wildcard_char {
    "-" -> True
    char -> char == char_2
  }
}
