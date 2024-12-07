import gleam/int
import gleam/list
import gleam/otp/task
import gleam/pair
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(#(Int, List(Int))) {
  input
  |> string.split("\n")
  |> list.map(string.replace(_, ":", ""))
  |> list.map(string.split(_, " "))
  |> list.map(fn(nums) {
    let assert [target, ..nums] = nums |> list.map(int.parse) |> result.values
    #(target, nums)
  })
}

pub fn pt_1(input: List(#(Int, List(Int)))) {
  input
  |> list.filter(fn(i) {
    let assert [first, ..rest] = i.1
    can_get_to_target(i.0, first, rest)
  })
  |> list.map(pair.first)
  |> int.sum
}

pub fn pt_2(input: List(#(Int, List(Int)))) {
  input
  |> list.map(fn(i) {
    task.async(fn() {
      let assert [first, ..rest] = i.1
      #(i.0, can_get_to_target_p2(i.0, first, rest))
    })
  })
  |> list.map(task.await_forever)
  |> list.filter(pair.second)
  |> list.map(pair.first)
  |> int.sum
}

fn can_get_to_target(target: Int, curr_result: Int, remaining: List(Int)) {
  case curr_result, remaining {
    r, [] -> r == target
    r, [_, ..] if r > target -> False
    r, [first, ..rest] ->
      can_get_to_target(target, r + first, rest)
      || can_get_to_target(target, r * first, rest)
  }
}

fn can_get_to_target_p2(target: Int, curr_result: Int, remaining: List(Int)) {
  case curr_result, remaining {
    r, [] -> r == target
    r, [_, ..] if r > target -> False
    r, [first, ..rest] ->
      can_get_to_target_p2(target, r + first, rest)
      || can_get_to_target_p2(target, r * first, rest)
      || {
        [r, first]
        |> list.map(int.to_string)
        |> string.concat
        |> int.parse
        |> result.unwrap(r)
        |> can_get_to_target_p2(target, _, rest)
      }
  }
}
