func parsed(from action: RoomAction) -> ParsedAction? {
    let description = action.fields[0]

    switch action.variant {
    case .move:
        guard action.fields.count >= 2 else { return nil }

        let destination = action.fields[1]
        let requiredItemField = action.fields.count >= 3 ? action.fields[2] : ""

        return .move(
            description: description,
            destination: destination,
            requiredItem: requiredItemField.isEmpty ? nil : requiredItemField,
        )
    case .pickUp:
        guard action.fields.count >= 2 else { return nil }

        let item = action.fields[1]

        return .pickUp(description: description, item: item)
    }
}

func prompt(for action: ParsedAction) -> String {
    switch action {
    case let .move(description, _, _):
        description
    case let .pickUp(description, _):
        description
    }
}

func roomByName(in world: GameWorld) -> [String: Room] {
    var lookup: [String: Room] = [:]
    for room in world.rooms {
        lookup[room.name] = room
    }
    return lookup
}

func room(named name: String, in lookup: [String: Room]) -> Room? {
    lookup[name]
}

func isMovedBlocked(requiredItem: String?, inventory: Set<String>) -> Bool {
    guard let requiredItem else { return false }
    return !inventory.contains(requiredItem)
}
