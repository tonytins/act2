use std::collections::HashMap;
use serde::Deserialize;
use crate::game::*;

#[derive(Clone, Deserialize)]
pub struct JsonGame {
    rooms: Vec<JsonRoom>
}

#[derive(Clone, Deserialize)]
pub struct JsonRoom {
    pub name: String,
    pub scene: String,
    pub actions: Vec<JsonAction>
}

#[derive(Clone, Deserialize)]
pub struct JsonAction {
    pub variant: String,
    fields: Vec<String>
}

impl JsonAction {
    pub fn process(&self) -> Action {
        match &*self.variant {
            "PickUp" => {
                Action::PickUp(self.fields[0].clone(),
                               self.fields[1].clone(),
                               self.fields[2].clone())
            },
            "Move" => {
                Action::Move(self.fields[0].clone(),
                             self.fields[1].clone(),
                             self.fields[2].clone())
            },
            _ => panic!(""),
        }
    }
}

impl JsonRoom {
    pub fn process_actions(&self) -> Vec<Action> {
        let mut actions: Vec<Action> = Vec::new();
        for a in self.actions.clone() {
            actions.push(a.process())
        }
        actions
    }
}
impl JsonGame {
    pub fn process(&self) -> Game {
        let mut r_hash: HashMap<String, Room> = HashMap::new();
        for r in self.rooms.clone() {
            r_hash.insert(r.name.clone(), Room {
                scene: r.scene.clone(),
                actions: r.process_actions()
            });
        };

        let character = Character {
            inventory: HashMap::new(),
            room: "start".into(),
        };

        Game {
            rooms: r_hash,
            character
        }
    }
}