import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/otp/task
import gleam/pair
import gleam/set
import gleam/string

type Position =
  #(Int, Int)

type Grid =
  dict.Dict(Position, Tile)

type Direction {
  Up
  Down
  Left
  Right
}

type Tile {
  Obstacle
  Guard(String)
  Free
}

fn map_char_to_tile(char: String) {
  case char {
    "#" -> Obstacle
    "." -> Free
    _ -> Guard(char)
  }
}

fn map_char_to_direction(char: String) {
  case char {
    "^" -> Up
    "v" -> Down
    "<" -> Left
    ">" -> Right
    _ -> panic as "invalid direction"
  }
}

fn input_to_grid(input: String) {
  let positions =
    input
    |> string.split("\n")
    |> list.index_map(fn(line, row) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, col) {
        #(#(row, col), char |> map_char_to_tile)
      })
    })
    |> list.flatten

  let assert Ok(#(start, Guard(dir))) =
    positions
    |> list.find(fn(p) {
      case p.1 {
        Guard(_) -> True
        _ -> False
      }
    })

  #(
    positions |> dict.from_list |> dict.insert(start, Free),
    start,
    dir |> map_char_to_direction,
  )
}

pub fn pt_1(input: String) {
  let #(grid, start, dir) = input_to_grid(input)

  traverse_map(start, dir, set.new(), grid)
}

fn next_position(curr_pos: Position, curr_direction: Direction) {
  case curr_direction {
    Up -> #(curr_pos.0 - 1, curr_pos.1)
    Down -> #(curr_pos.0 + 1, curr_pos.1)
    Left -> #(curr_pos.0, curr_pos.1 - 1)
    Right -> #(curr_pos.0, curr_pos.1 + 1)
  }
}

fn next_direction(direction: Direction) {
  case direction {
    Right -> Down
    Down -> Left
    Left -> Up
    Up -> Right
  }
}

fn traverse_map(
  curr_pos: Position,
  curr_dir: Direction,
  seen: set.Set(Position),
  grid: Grid,
) {
  let next_pos = next_position(curr_pos, curr_dir)
  let next_dir = next_direction(curr_dir)

  case grid |> dict.get(next_pos) {
    Ok(Obstacle) -> traverse_map(curr_pos, next_dir, seen, grid)
    Ok(Free) ->
      traverse_map(next_pos, curr_dir, seen |> set.insert(curr_pos), grid)
    _ -> seen |> set.size |> int.add(1)
  }
}

pub fn pt_2(input: String) {
  let #(grid, start, dir) = input_to_grid(input)

  let assert Ok(rows) =
    grid |> dict.keys |> list.map(pair.first) |> list.reduce(int.max)
  let assert Ok(cols) =
    grid |> dict.keys |> list.map(pair.second) |> list.reduce(int.max)

  list.range(0, rows)
  |> list.map(fn(r) { list.range(0, cols) |> list.map(fn(c) { #(r, c) }) })
  |> list.flatten
  |> list.map(fn(p) { grid |> dict.insert(p, Obstacle) })
  |> list.map(fn(g) {
    task.async(fn() { traverse_map_with_memory(start, dir, set.new(), g) })
  })
  |> list.map(task.await_forever)
  |> list.count(function.identity)
}

fn traverse_map_with_memory(
  curr_pos: Position,
  curr_dir: Direction,
  seen: set.Set(#(Position, Direction)),
  grid: Grid,
) -> Bool {
  let next_pos = next_position(curr_pos, curr_dir)
  let next_dir = next_direction(curr_dir)

  case grid |> dict.get(next_pos) {
    Ok(Obstacle) -> {
      case seen |> set.contains(#(curr_pos, next_dir)) {
        True -> True
        False ->
          traverse_map_with_memory(
            curr_pos,
            next_dir,
            seen
              |> set.insert(#(curr_pos, curr_dir)),
            grid,
          )
      }
    }
    Ok(Free) -> {
      case seen |> set.contains(#(next_pos, curr_dir)) {
        True -> True
        False ->
          traverse_map_with_memory(
            next_pos,
            curr_dir,
            seen
              |> set.insert(#(curr_pos, curr_dir)),
            grid,
          )
      }
    }
    _ -> False
  }
}
