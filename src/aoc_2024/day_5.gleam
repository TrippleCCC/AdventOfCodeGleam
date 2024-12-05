import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/set
import gleam/string

type Rules =
  dict.Dict(Int, List(Int))

type Update =
  List(Int)

type Input =
  #(Rules, List(Update))

pub fn parse(input: String) {
  let assert [rules, updates] = input |> string.split("\n\n")

  let rules =
    rules
    |> string.split("\n")
    |> list.map(string.split(_, "|"))
    |> list.map(fn(r) {
      let assert [first, second] = r |> list.map(int.parse) |> result.values
      #(first, second)
    })
    |> list.fold(dict.new(), fn(m, p) {
      m
      |> dict.upsert(p.0, fn(e) {
        case e {
          option.Some(afters) -> [p.1, ..afters]
          option.None -> [p.1]
        }
      })
    })

  let updates =
    updates
    |> string.split("\n")
    |> list.map(string.split(_, ","))
    |> list.map(fn(nums) { nums |> list.map(int.parse) |> result.values })

  #(rules, updates)
}

fn get_middle(l: List(a)) {
  l
  |> list.length
  |> int.subtract(1)
  |> int.divide(2)
  |> result.unwrap(0)
  |> list.drop(l, _)
  |> list.first
}

pub fn pt_1(input: Input) {
  let #(rules, updates) = input

  updates
  |> list.filter(valid_update(set.new(), rules, _))
  |> list.map(fn(u) { get_middle(u) |> result.unwrap(0) })
  |> int.sum
}

pub fn pt_2(input: Input) {
  let #(rules, updates) = input

  updates
  |> list.filter(fn(a) { !valid_update(set.new(), rules, a) })
  |> list.map(correct_update_order(rules, _))
  |> list.map(fn(u) { get_middle(u) |> result.unwrap(0) })
  |> int.sum
}

fn valid_update(seen: set.Set(Int), rules: Rules, remaining: List(Int)) -> Bool {
  case remaining {
    [first, ..rest] -> {
      let must_appear_afters = rules |> dict.get(first) |> result.unwrap([])

      let failed =
        must_appear_afters
        |> list.map(fn(a) { seen |> set.contains(a) })
        |> list.any(function.identity)

      case failed {
        True -> False
        False -> valid_update(seen |> set.insert(first), rules, rest)
      }
    }
    [] -> True
  }
}

fn correct_update_order(rules: Rules, update: List(Int)) {
  update |> list.sort(fn(a, b) { compare_page_numbers(rules, a, b) })
}

fn compare_page_numbers(rules: Rules, pg_1: Int, pg_2: Int) -> order.Order {
  let pg_1_afters = rules |> dict.get(pg_1) |> result.unwrap([])
  let pg_2_afters = rules |> dict.get(pg_2) |> result.unwrap([])

  case pg_1_afters |> list.contains(pg_2), pg_2_afters |> list.contains(pg_1) {
    False, True -> order.Gt
    True, False -> order.Lt
    False, False -> order.Eq

    // True, True should never happen, but we would just return Eq here
    _, _ -> order.Eq
  }
}
