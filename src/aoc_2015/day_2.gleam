import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(dimensions) {
    let assert [l, w, h] =
      dimensions |> string.split("x") |> list.map(int.parse) |> result.values

    let side_1 = l * w
    let side_2 = w * h
    let side_3 = h * l

    { side_1 + side_2 + side_3 }
    |> int.multiply(2)
    |> int.add(side_1 |> int.min(side_2) |> int.min(side_3))
  })
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(dimensions) {
    let assert [l, w, h] =
      dimensions |> string.split("x") |> list.map(int.parse) |> result.values

    let assert [smallest, second_smallest, ..] =
      [l, w, h] |> list.sort(int.compare)

    { smallest + second_smallest } |> int.multiply(2) |> int.add(l * w * h)
  })
  |> int.sum
}
