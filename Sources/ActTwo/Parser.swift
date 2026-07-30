enum ParsedAction: Equatable {
    case move(description: String, destination: String, requiredItem: String?)
    case pickUp(description: String, item: String)
}

extension ParsedAction {
    var prompt: String {
        switch self {
                case let .move(description, _, _): description
                case let .pickUp(description, _): description
                }
    }
    
    init?(from action: RoomAction) {
        guard let description = action.fields.first else {
            return nil
        }
        
        switch action.variant {
        case .move:
            guard action.fields.count >= 2 else {
                return nil
            }
            let destination = action.fields[1]
            let requiredItem = action.fields.count >= 3 ? action.fields[2] : ""
            self = .move(
                description: description,
                destination: destination,
                requiredItem: requiredItem.isEmpty ? nil : requiredItem
            )
        case .pickUp:
            guard action.fields.count >= 2 else {
                return nil
            }
            self = .pickUp(description: description, item: action.fields[1])
        }
    }
    
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
}
