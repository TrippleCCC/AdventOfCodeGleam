import gleam/int
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(l) {
    let assert [ls, ws, hs] = string.split(l, "x")
    let assert Ok(l) = int.parse(ls)
    let assert Ok(w) = int.parse(ws)
    let assert Ok(h) = int.parse(hs)

    let side_1 = l * w
    let side_2 = w * h
    let side_3 = h * l

    int.sum([side_1, side_2, side_3])
    |> int.multiply(2)
    |> int.add(int.min(side_1, side_2) |> int.min(side_3))
  })
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(l) {
    let assert [ls, ws, hs] = string.split(l, "x")
    let assert Ok(l) = int.parse(ls)
    let assert Ok(w) = int.parse(ws)
    let assert Ok(h) = int.parse(hs)

    let assert [smallest, second_smallest, ..] =
      list.sort([l, w, h], int.compare)

    int.add(smallest, second_smallest) |> int.multiply(2) |> int.add(l * w * h)
  })
  |> int.sum
}
