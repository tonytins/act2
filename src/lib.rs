//!
//! Act 2 is a simple engine for making text-based adventure games using JSON.
//!
//! It's on [crates.io](https://crates.io/crates/act2) and on [GitHub](https://github.com/tonytins/act2)!
mod json_models;
pub mod game;

use json_models::JsonGame;
use game::Game;

pub fn load_game(input: &str) -> Result<Game, serde_json::error::Error> {
    let rg: JsonGame = serde_json::from_str(input).unwrap();

    Ok(rg.process())
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
