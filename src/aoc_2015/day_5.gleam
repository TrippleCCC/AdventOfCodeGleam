import gleam/bool
import gleam/function
import gleam/list
import gleam/option.{type Option}
import gleam/set
import gleam/string

type State {
  State(vowels: Int, doubles: Int)
}

type State2 {
  State2(two_pairs: Bool, between: Bool, pairs: set.Set(String))
}

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(is_nice_string)
  |> list.count(function.identity)
}

fn is_nice_string(str: String) {
  is_nice_string_helper(State(0, 0), option.None, str |> string.to_graphemes)
}

fn is_nice_string_helper(
  state: State,
  last_char: Option(String),
  remaining: List(String),
) {
  case remaining {
    [first, ..rest] -> {
      let last_char = last_char |> option.unwrap("")
      let invalid_pair =
        ["ab", "cd", "pq", "xy"] |> list.contains(last_char <> first)

      use <- bool.guard(invalid_pair, False)

      let state = case first {
        "a" | "e" | "i" | "o" | "u" -> State(..state, vowels: state.vowels + 1)
        _ -> state
      }

      let state = case last_char == first {
        True -> State(..state, doubles: state.doubles + 1)
        _ -> state
      }

      is_nice_string_helper(state, option.Some(first), rest)
    }
    [] -> {
      state.vowels >= 3 && state.doubles >= 1
    }
  }
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.filter(is_nice_string_2)
  |> list.length
}

fn is_nice_string_2(str: String) -> Bool {
  is_nice_string_helper_2(
    State2(False, False, set.new()),
    #("", ""),
    str |> string.to_graphemes,
  )
}

fn is_nice_string_helper_2(
  state: State2,
  last_2_chars: #(String, String),
  remaining: List(String),
) {
  case state, last_2_chars, remaining {
    State2(True, True, _), _, _ -> True

    state, #(first_char, second_char), [next, ..rest] -> {
      let state = case first_char <> second_char, second_char <> next {
        a, b if a != b ->
          State2(
            ..state,
            two_pairs: state.pairs |> set.contains(b),
            pairs: state.pairs |> set.insert(b),
          )
        _, _ -> state
      }

      let state = case first_char, next {
        a, b if a == b -> State2(..state, between: True)
        _, _ -> state
      }

      is_nice_string_helper_2(state, #(last_2_chars.1, next), rest)
    }
    s, _, [] -> {
      s.between && s.two_pairs
    }
  }
}
