enum GameVersion: String, Codable {
    case v1 = "1.0"
}

enum ActionVariant: String, Codable {
    case move = "Move"
    case pickUp = "PickUp"
}

struct RoomAction: Codable {
    let variant: ActionVariant
    let fields: [String]
}

struct Room: Codable {
    let name: String
    let scene: String
    let actions: [RoomAction]
}

struct GameWorld: Codable {
    let version: GameVersion
    let rooms: [Room]
}

extension Set where Element == String {
    func missingItem(from candidate: String?) -> String? {
        guard let candidate, !contains(candidate) else { return nil }
        return candidate
    }
}

extension GameWorld {
    var roomByName: [String: Room] {
        Dictionary(rooms.map { ($0.name, $0) },
                   uniquingKeysWith: { _, last in last })
    }
}

enum ActionResult: Equatable {
    case moved(to: String)
    case blocked(missingItem: String)
    case pickedUp(item: String)
    case destinationUnknown(name: String)
}

struct GameEngine {
    let roomLookup: [String: Room]
    private(set) var currentRoomName: String
    private(set) var inventory: Set<String> = []

    var currentRoom: Room {
        roomLookup[currentRoomName]!
    }


    init?(world: GameWorld, startRoomName: String) {
        let lookup = world.roomByName
        guard lookup[startRoomName] != nil else { return nil }

        roomLookup = lookup
        currentRoomName = startRoomName
    }

    func hasItem(_ item: String) -> Bool {
        inventory.contains(item)
    }

    mutating func attempt(_ action: ParsedAction) -> ActionResult {
        switch action {
        case let .move(_, destination, requiredItem):
            if let missing = inventory.missingItem(from: requiredItem) {
                return .blocked(missingItem: missing)
            }

            guard roomLookup[destination] != nil else {
                return .destinationUnknown(name: destination)
            }

            currentRoomName = destination

            return .moved(to: destination)
        case let .pickUp(_, item):
            inventory.insert(item)
            return .pickedUp(item: item)
        }
    }
}
