// This project is licensed under the MIT license.
// See the LICENSE file in the project root for more information.
import ArgumentParser
import Foundation

struct Adventure: Codable {
    let rooms: [Room]
}

struct Room: Codable {
    let name: String
    let scene: String
    let actions: [Action]
}

/// An Action is composed of three strings.
/// The first one is the text that will be shown to the user.
/// The second is what the action will do.  For example, in a PickUp action, it would be the item that would be given to the user.
/// The third one is the requirement. This will check if the user  has the item specified, and only if true will proceed.
struct Action: Codable {
    let variant: String
    let fields: [String]
}

class AdventureEngine {
    var rooms: [String: Room] = [:]
    var currentRoomName: String = ""
    var inventory: Set<String> = []

    init(from json: String) throws {
        let data = json.data(using: .utf8)!
        let adventure = try JSONDecoder().decode(Adventure.self, from: data)

        for room in adventure.rooms {
            rooms[room.name] = room
        }
    }

    func start(in roomName: String) {
        currentRoomName = roomName
        renderRoom()
    }

    func renderRoom() {
        guard let room = rooms[currentRoomName] else {
            print("Room not found!")
            return
        }

        print(room.scene)

        for (index, action) in room.actions.enumerated() {
            print("[\(index + 1)] \(action.fields[0])")
        }
        print("\nEnter action number (or 'quit' to exit):")
    }

    func executeActiom(_ index: Int) -> Bool {
        guard let room = rooms[currentRoomName] else {
            print("Room not found!")
            return false
        }

        guard index > 0, index <= room.actions.count else {
            print("Invalid action!")
            return true
        }

        let action = room.actions[index - 1]

        switch action.variant {
        case "Move":
            return handMove(action)
        case "PickUp":
            return handPickUp(action)
        default:
            print("Unknown action: \(action.variant)")
            return true
        }
    }

    func handPickUp(_ action: Action) -> Bool {
        guard action.fields.count >= 2 else {
            print("Invalid action")
            return true
        }

        let descrption = action.fields[0]
        let itemName = action.fields[1]

        let pickUp = """
        > \(descrption)
        > You picked up \(itemName)!
        """

        inventory.insert(itemName)
        print(pickUp)

        return true
    }

    func handMove(_ action: Action) -> Bool {
        guard action.fields.count >= 2 else {
            print("Invalid action")
            return true
        }

        let descrption = action.fields[0]
        let destination = action.fields[1]
        let requiredItem = action.fields.count >= 3 ? action.fields[2] : ""

        print("> \(descrption)")

        if !requiredItem.isEmpty, !inventory.contains(requiredItem) {
            print("Opening this room requires \(requiredItem).")
            return true
        }

        if !destination.isEmpty {
            currentRoomName = destination
            renderRoom()
            return true
        }

        return true
    }
}

@main
struct ActTwo: ParsableCommand {
    mutating func run() throws {
        let jsonInput = """
        {"rooms":[{"name":"start","scene":"Im a starting room! Welcome to this example game.","actions":[{"variant":"Move","fields":["Move to another room","example",""]}]},{"name":"example","scene":"You enter an example room, with a big, triangular key in it. There's also a door with a keyhole in triangular shape.","actions":[{"variant":"PickUp","fields":["Pick the key up","TriangleKey"]},{"variant":"Move","fields":["Try to open the door","locked","TriangleKey"]}]},{"name":"locked","scene":"You picked an item up and used it to open the door! This is the final room. Congratz!","actions":[{"variant":"Move","fields":["Return to start","example"]}]}]}
        """

        let engine = try AdventureEngine(from: jsonInput)
        let title = """
        ▄▖  ▗   ▄▖
        ▌▌▛▘▜▘  ▄▌
        ▛▌▙▖▐▖  ▙▖

        Act 2 Text Adventure Engine


        """

        print(title)

        do {
            engine.start(in: "start")

            var isRunning = true
            while isRunning {
                if let input = readLine()?.lowercased() {
                    if input == "quit" {
                        break
                    }
                    if let actionNum = Int(input) {
                        isRunning = engine.executeActiom(actionNum)
                    } else {
                        print("Enter a valid action or 'quit'.")
                    }
                }
            }
        }
    }
}
