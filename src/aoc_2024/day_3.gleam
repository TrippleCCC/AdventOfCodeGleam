import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string

pub fn parse(input: String) -> String {
  input |> string.split("\n") |> string.concat
}

pub fn pt_1(input: String) {
  input |> calculate_sum
}

pub fn pt_2(input: String) {
  loop(0, input)
}

fn loop(sum: Int, remaining: String) -> Int {
  case remaining {
    "" -> sum
    r -> {
      let #(before, after) =
        r |> string.split_once("don't()") |> result.unwrap(#(r, ""))

      let new_sum = before |> calculate_sum |> int.add(sum)
      let #(_, rest) =
        after |> string.split_once("do()") |> result.unwrap(#("", ""))

      loop(new_sum, rest)
    }
  }
}

fn calculate_sum(code: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  regexp.scan(re, code)
  |> list.map(fn(m) {
    let assert [Some(num1_str), Some(num2_str)] = m.submatches
    let assert Ok(num1) = int.parse(num1_str)
    let assert Ok(num2) = int.parse(num2_str)
    num1 * num2
  })
  |> int.sum
}
