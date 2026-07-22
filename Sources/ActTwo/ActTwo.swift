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

enum ParsedAction: Equatable {
    case move(description: String, destination: String, requiredItem: String?)
    case pickUp(description: String, item: String)
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
    
    var availableActions: [ParsedAction] {
        currentRoom.actions.compactMap(parsed(from:))
    }
    
    init?(world: GameWorld, startRoomName: String)
    {
        let lookup = roomByName(in: world)
        guard lookup[startRoomName] != nil else { return nil }
        
        
        roomLookup = lookup
        currentRoomName = startRoomName
    }
    
    func hasItem(_ item: String) -> Bool {
        inventory.contains(item)
    }
    
    mutating func attempt(_ action: ParsedAction) -> ActionResult {
        switch action {
        case .move(_, let destination, let requiredItem):
            if isMovedBlocked(requiredItem: requiredItem, inventory: inventory) {
                return .blocked(missingItem: requiredItem!)
            }
            
            guard roomLookup[destination] != nil else {
                return .destinationUnknown(name: destination)
            }
            
            currentRoomName = destination
            
            return .moved(to: destination)
        case .pickUp(_, let item):
            inventory.insert(item)
            return .pickedUp(item: item)
        }
    }
}
