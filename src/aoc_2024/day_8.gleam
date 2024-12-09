import gleam/dict

// import gleam/function
import gleam/int
import gleam/list
import gleam/set
import gleam/string

type Coordinate =
  #(Int, Int)

type Frequency =
  String

pub type Antenne {
  Antenne(coord: Coordinate, freq: Frequency)
}

pub fn parse(input: String) {
  let all_points =
    input
    |> string.split("\n")
    |> list.index_map(fn(r, row) {
      r
      |> string.to_graphemes
      |> list.index_map(fn(f, col) { Antenne(#(row, col), f) })
    })

  let rows =
    all_points
    |> list.flatten
    |> list.map(fn(a) { a.coord.0 })
    |> list.fold(0, int.max)
    |> int.add(1)

  let cols =
    all_points
    |> list.flatten
    |> list.map(fn(a) { a.coord.1 })
    |> list.fold(0, int.max)
    |> int.add(1)

  let valid_antenne =
    all_points |> list.flatten |> list.filter(fn(a) { a.freq != "." })

  #(rows, cols, valid_antenne)
}

pub fn pt_1(input: #(Int, Int, List(Antenne))) {
  input.2
  |> list.group(fn(a) { a.freq })
  |> dict.to_list
  |> list.map(fn(e) { e.1 |> list.combinations(2) })
  |> list.flatten
  |> list.map(fn(pair) {
    let assert [a1, a2] = pair
    find_antinodes(a1, a2)
  })
  |> list.flatten
  |> set.from_list
  |> set.to_list
  |> list.count(is_valid_coordinate(_, input.0, input.1))
}

pub fn pt_2(input: #(Int, Int, List(Antenne))) {
  input.2
  |> list.group(fn(a) { a.freq })
  |> dict.to_list
  |> list.map(fn(e) { e.1 |> list.combinations(2) })
  |> list.flatten
  |> list.map(fn(pair) {
    let assert [a1, a2] = pair
    find_antinodes_2(a1, a2, input.0, input.1)
  })
  |> list.flatten
  |> set.from_list
  |> set.to_list
  |> list.filter(is_valid_coordinate(_, input.0, input.1))
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  // |> function.tap(list.map(_, io.debug))
  |> list.length
}

fn find_antinodes(a1: Antenne, a2: Antenne) {
  let #(a1, a2) = case a1, a2 {
    a, b if a.coord.1 < b.coord.1 -> #(a, b)
    a, b -> #(b, a)
  }

  let col_change =
    { a2.coord.1 - a1.coord.1 }
    |> int.absolute_value
  let row_change = {
    a2.coord.0 - a1.coord.0
  }

  let antinode1 = #(a1.coord.0 - row_change, a1.coord.1 - col_change)
  let antinode2 = #(a2.coord.0 + row_change, a2.coord.1 + col_change)

  [antinode1, antinode2]
}

fn find_antinodes_2(a1: Antenne, a2: Antenne, rows: Int, cols: Int) {
  let #(a1, a2) = case a1, a2 {
    a, b if a.coord.1 < b.coord.1 -> #(a, b)
    a, b -> #(b, a)
  }

  let col_change =
    { a2.coord.1 - a1.coord.1 }
    |> int.absolute_value
  let row_change = {
    a2.coord.0 - a1.coord.0
  }

  let row_coords_1 =
    list.range(1, rows)
    |> list.map(int.multiply(_, -row_change))
    |> list.map(int.add(_, a1.coord.0))
  let col_coords_1 =
    list.range(1, cols)
    |> list.map(int.multiply(_, -col_change))
    |> list.map(int.add(_, a1.coord.1))

  let row_coords_2 =
    list.range(1, rows)
    |> list.map(int.multiply(_, row_change))
    |> list.map(int.add(_, a2.coord.0))
  let col_coords_2 =
    list.range(1, cols)
    |> list.map(int.multiply(_, col_change))
    |> list.map(int.add(_, a2.coord.1))

  list.zip(row_coords_1, col_coords_1)
  |> list.append({ row_coords_2 |> list.zip(col_coords_2) })
  |> list.append([a1.coord, a2.coord])
}

fn is_valid_coordinate(coord: Coordinate, rows: Int, cols: Int) {
  coord.0 >= 0 && coord.0 < rows && coord.1 >= 0 && coord.1 < cols
}
