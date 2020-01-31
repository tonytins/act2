/*
 * This project is licensed under the MIT license.
 * See the LICENSE file in the project root for more information.
 */
pub mod game;
mod jmodels;

use game::Game;
use jmodels::JsonGame;

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
