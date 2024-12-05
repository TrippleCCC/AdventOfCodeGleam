import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string

type Coord =
  #(Int, Int)

type WordSearch =
  dict.Dict(Coord, String)

fn get_value_at_coord(ws: WordSearch, coord: Coord) {
  ws |> dict.get(coord) |> result.unwrap("")
}

fn get_cords_in_direction(coord: Coord, direction: Coord) {
  [
    coord,
    #(coord.0 + direction.0 * 1, coord.1 + direction.1 * 1),
    #(coord.0 + direction.0 * 2, coord.1 + direction.1 * 2),
    #(coord.0 + direction.0 * 3, coord.1 + direction.1 * 3),
  ]
}

pub fn parse(input: String) -> WordSearch {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, index) {
    line
    |> string.to_graphemes()
    |> list.index_map(fn(c, i) { #(#(i, index), c) })
  })
  |> list.flatten
  |> dict.from_list
}

pub fn pt_1(ws: WordSearch) {
  ws
  |> dict.filter(fn(_, v) { v == "X" })
  |> dict.to_list
  |> list.map(fn(e) { e.0 })
  |> list.map(find_matches(ws, _))
  |> int.sum
}

fn find_matches(ws: WordSearch, coord: Coord) {
  let directions = [
    #(0, -1),
    #(1, -1),
    #(1, 0),
    #(1, 1),
    #(0, 1),
    #(-1, 1),
    #(-1, 0),
    #(-1, -1),
  ]

  directions
  |> list.map(get_cords_in_direction(coord, _))
  |> list.map(fn(coords) {
    coords |> list.map(get_value_at_coord(ws, _)) |> string.concat
  })
  |> list.filter(fn(w) { w == "XMAS" })
  |> list.length
}

pub fn pt_2(ws: WordSearch) {
  ws
  |> dict.filter(fn(_, v) { v == "A" })
  |> dict.to_list
  |> list.map(fn(e) { e.0 })
  |> list.map(find_x_mass(ws, _))
  |> list.count(function.identity)
}

fn find_x_mass(ws: WordSearch, coord: Coord) {
  let top_left_bottom_right = [#(-1, -1), #(1, 1)]
  let top_right_bottom_left = [#(1, -1), #(-1, 1)]

  [top_right_bottom_left, top_left_bottom_right]
  |> list.map(fn(diagonal_coords) {
    diagonal_coords
    |> list.map(fn(d) {
      let position = #(coord.0 + d.0, coord.1 + d.1)
      get_value_at_coord(ws, position)
    })
    |> set.from_list
    |> set.intersection(set.from_list(["M", "S"]))
    |> set.size
    == 2
  })
  |> list.all(function.identity)
}
