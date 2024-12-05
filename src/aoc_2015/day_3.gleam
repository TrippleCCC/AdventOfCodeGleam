import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/string

pub fn pt_1(input: String) {
  solve_1(dict.from_list([#(#(0, 0), 1)]), #(0, 0), string.to_graphemes(input))
  |> dict.size
}

fn solve_1(
  visited: dict.Dict(#(Int, Int), Int),
  current_cord: #(Int, Int),
  remaining_choices: List(String),
) {
  let new_cord = case remaining_choices {
    [] -> current_cord
    [">", ..] -> #(current_cord.0 + 1, current_cord.1)
    ["<", ..] -> #(current_cord.0 - 1, current_cord.1)
    ["^", ..] -> #(current_cord.0, current_cord.1 + 1)
    ["v", ..] -> #(current_cord.0, current_cord.1 - 1)
    _ -> current_cord
  }

  case new_cord {
    c if c == current_cord -> visited
    c -> {
      let assert Ok(rest) = list.rest(remaining_choices)
      solve_1(
        dict.upsert(visited, c, fn(o) {
          case o {
            option.Some(s) -> s + 1
            option.None -> 1
          }
        }),
        c,
        rest,
      )
    }
  }
}

pub fn pt_2(input: String) {
  let #(santa, robo_santa) =
    input
    |> string.to_graphemes
    |> list.index_map(fn(d, i) { #(i + 1, d) })
    |> list.partition(fn(p) { int.is_even(p.0) })

  let santa = santa |> list.map(fn(p) { p.1 })
  let robo_santa = robo_santa |> list.map(fn(p) { p.1 })

  let assert Ok(combined_maps) =
    [santa, robo_santa]
    |> list.map(fn(d) { solve_1(dict.from_list([#(#(0, 0), 1)]), #(0, 0), d) })
    |> list.reduce(dict.merge)

  combined_maps |> dict.size
}
