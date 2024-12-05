import gleam/bit_array
import gleam/crypto
import gleam/int

pub fn pt_1(input: String) {
  solve_1(1, input)
}

fn solve_1(i: Int, key: String) {
  let full_key = key <> int.to_string(i)

  case i, crypto.hash(crypto.Md5, bit_array.from_string(full_key)) {
    i, <<0x00, 0x00, 0:4, _:bits>> -> i
    _, _ -> solve_1(i + 1, key)
  }
}

pub fn pt_2(input: String) {
  solve_2(1, input)
}

fn solve_2(i: Int, key: String) {
  let full_key = key <> int.to_string(i)

  case i, crypto.hash(crypto.Md5, bit_array.from_string(full_key)) {
    i, <<0x00, 0x00, 0x00, _:bits>> -> i
    _, _ -> solve_2(i + 1, key)
  }
}
