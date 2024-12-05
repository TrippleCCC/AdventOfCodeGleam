import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let chars = input |> string.to_graphemes
  let up = chars |> list.count(fn(c) { c == "(" })
  let down = chars |> list.count(fn(c) { c == ")" }) |> int.multiply(-1)
  up + down
}

pub fn pt_2(input: String) {
  solve_2(0, 1, string.to_graphemes(input))
}

pub fn solve_2(current_level: Int, current_index: Int, remaining: List(String)) {
  case current_level, current_index, remaining {
    0, i, [")", ..] -> i
    l, i, [")", ..rest] -> solve_2(l - 1, i + 1, rest)
    l, i, ["(", ..rest] -> solve_2(l + 1, i + 1, rest)
    _, i, _ -> i
  }
}
