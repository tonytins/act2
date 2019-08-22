use std::collections::HashMap;
use std::{thread, time, io};

///
///An Action is composed of three strings.
///The first one is the text that will be shown to the user.
///The second is what the action will do.  For example, in a PickUp action, it would be the item that would be given to the user.
///The third one is the requirement. This will check if the user  has the item specified, and only if true will proceed.
#[derive(Clone, Debug)]
pub enum Action {
    PickUp(String, String, String),
    Move(String, String, String),
}

#[derive(Clone)]
pub struct Room {
    pub scene: String,
    pub actions: Vec<Action>,
}

pub struct Character {
    pub inventory: HashMap<String, String>,
    pub room: String,
}

pub struct Game {
    pub rooms: HashMap<String, Room>,
    pub character: Character,
}

impl Action {
    pub fn text(&self) -> String {
        match &self {
            &&Action::Move(ref s, _, _) => s.clone(),
            &&Action::PickUp(ref s, _, _) => s.clone(),
        }
    }
}

impl Game {
    pub fn action(&mut self, a: Action) {
        match a {
            Action::PickUp(_, i, r) => {
                if self.character.inventory.contains_key(&r) || &r == "" {
                    self.character.inventory.insert(i.clone(), i);
                    self.clear();
                }
            }
            Action::Move(_, r, i) => {
                if self.character.inventory.contains_key(&i) || &i == "" {
                    self.character.room = r;
                } else {
                    println!("Opening this room requires {}", i);
                    self.clear();
                }
            }
        }
    }

    pub fn render_room(&mut self, r: Room) {
        for c in r.scene.lines() {
            println!("{}", c);
        }
        for (i, a) in r.actions.iter().enumerate() {
            println!("{}. {}\n", i, a.text());
        }
    }

    pub fn clear(&self) {

        print!("{}[2J", 27 as char);
    }

    pub fn play(&mut self) {
        print!("
    :::      :::::::: :::::::::::       ::::::::
  :+: :+:   :+:    :+:    :+:          :+:    :+:
 +:+   +:+  +:+           +:+                +:+
+#++:++#++: +#+           +#+              +#+
+#+     +#+ +#+           +#+            +#+
#+#     #+# #+#    #+#    #+#           #+#
###     ###  ########     ###          ##########
\n");
        println!("Made with Act 2. Make your own game at github.com/tonytins/act2");
        thread::sleep(time::Duration::from_millis(4000));
        self.clear();
        'outer: loop {
            let rooms = self.rooms.clone();
            let r = rooms.get(&self.character.room).unwrap();
            self.render_room(r.clone());
            let mut s = String::new();
            io::stdin().read_line(&mut s).unwrap();

            match s.chars().nth(0).unwrap().to_digit(10) {
                Some(u) => {
                    let a = match r.actions.iter().nth(u as usize) {
                        Some(x) => x,
                        None => { continue 'outer; }
                    };
                    self.action(a.clone());
                }
                None => { continue 'outer }
            }
        }
    }
}