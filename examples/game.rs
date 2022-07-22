// This project is licensed under the MIT license.
// See the LICENSE file in the project root for more information.
extern crate act2;

use act2::load_game;
use std::env;
use std::fs::File;
use std::io::prelude::*;

fn main() {
    let mut json_file = File::open(env::args().nth(1).expect("Usage: act <file>"))
        .expect("Couldn't open game file!");
    let mut json_string = String::new();
    json_file.read_to_string(&mut json_string).unwrap();
    let mut game = load_game(&json_string).unwrap();
    game.play();
}
