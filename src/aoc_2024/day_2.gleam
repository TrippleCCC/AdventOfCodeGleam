import gleam/bool
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn is_report_valid(report: List(Int)) -> Bool {
  let diffs = report |> list.window_by_2 |> list.map(fn(p) { p.0 - p.1 })

  let valid_diffs =
    diffs
    |> list.map(int.absolute_value)
    |> list.all(fn(d) { d >= 1 && d <= 3 })

  // Early return
  use <- bool.guard(!valid_diffs, False)

  // validate all inc or all dec
  bool.or(list.all(diffs, fn(d) { d < 0 }), list.all(diffs, fn(d) { d > 0 }))
}

pub fn parse(input: String) -> List(List(Int)) {
  string.split(input, "\n")
  |> list.map(string.split(_, " "))
  |> list.map(fn(r) { r |> list.map(int.parse) |> result.values })
}

pub fn pt_1(input: List(List(Int))) {
  input
  |> list.map(is_report_valid)
  |> list.count(function.identity)
}

pub fn pt_2(input: List(List(Int))) {
  input
  |> list.map(fn(r) {
    r
    |> list.index_map(fn(_, i) {
      let #(l1, l2) = r |> list.split(i)
      l1 |> list.append(list.rest(l2) |> result.unwrap([]))
    })
    |> list.append([r])
    |> list.map(is_report_valid)
    |> list.any(function.identity)
  })
  |> list.count(function.identity)
}
