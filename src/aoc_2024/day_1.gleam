import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  let lines = input |> string.split("\n")
  lines
  |> list.map(fn(l) {
    let assert [n1, n2] = string.split(l, "   ")

    let assert Ok(n1) = int.parse(n1)
    let assert Ok(n2) = int.parse(n2)

    #(n1, n2)
  })
  |> list.unzip
}

pub fn pt_1(input: #(List(Int), List(Int))) {
  list.zip(list.sort(input.0, int.compare), list.sort(input.1, int.compare))
  |> list.map(fn(p) { int.absolute_value(p.1 - p.0) })
  |> int.sum
}

pub fn pt_2(input: #(List(Int), List(Int))) {
  input.0
  |> list.map(fn(n) { list.count(input.1, fn(a) { a == n }) * n })
  |> int.sum
}
