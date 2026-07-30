@testable import ActTwo
import Foundation
import Testing

private let startRoomName = "start"
private let exampleRoomName = "example"
private let lockedRoomName = "locked"
private let hallRoomName = "hall"
private let unknownRoomName = "nowhere"

private let triangleKey = "TriangleKey"

private let moveToExampleDescription = "Move to another room"
private let pickUpKeyDescription = "Pick the key up"
private let openDoorDescription = "Try to open the door"
private let returnToStartDescription = "Return to start"
private let goNorthDescription = "Go north"
private let fallIntoVoidDescription = "Fall into the void"

private let moveToExampleFields = [moveToExampleDescription, exampleRoomName, ""]
private let pickUpKeyFields = [pickUpKeyDescription, triangleKey]
private let openDoorFields = [openDoorDescription, lockedRoomName, triangleKey]
private let returnToStartFields = [returnToStartDescription, exampleRoomName]
private let goNorthFields = [goNorthDescription, hallRoomName, ""]

func testWorld() -> GameWorld {
    GameWorld(
        version: .v1,
        rooms: [
            Room(name: startRoomName, scene: "Starting room.", actions: [
                RoomAction(variant: .move, fields: moveToExampleFields),
            ]),
            Room(name: exampleRoomName, scene: "Example room.", actions: [
                RoomAction(variant: .pickUp, fields: pickUpKeyFields),
                RoomAction(variant: .move, fields: openDoorFields),
            ]),
            Room(name: lockedRoomName, scene: "Final room.", actions: [
                RoomAction(variant: .move, fields: returnToStartFields),
            ]),
        ]
    )
}

let moveParsingCases: [(action: RoomAction, expected: ParsedAction)] = [
    (
        RoomAction(variant: .move, fields: openDoorFields),
        .move(
            description: openDoorDescription,
            destination: lockedRoomName,
            requiredItem: triangleKey)
        ),
    (
        RoomAction(variant: .move, fields: goNorthFields),
        .move(
            description: goNorthDescription,
            destination: hallRoomName,
            requiredItem: nil
        )
    )
]

let incompleteActions: [RoomAction] = [
    RoomAction(variant: .move, fields: [goNorthDescription]),
    RoomAction(variant: .pickUp, fields: [pickUpKeyDescription])
]

@Suite
struct ParsedActionTests {
    @Test(arguments: moveParsingCases)
    func moveParses(action: RoomAction, expected: ParsedAction) {
        #expect(ParsedAction(from: action) == expected)
    }

    @Test(arguments: incompleteActions)
    func incompleteActionFailsToPrase(action: RoomAction) {
        #expect(ParsedAction(from: action) == nil)
    }

    @Test func pickUp() {
        let action = RoomAction(variant: .pickUp, fields: pickUpKeyFields)

        #expect(
            ParsedAction(from: action) ==
                .pickUp(description: pickUpKeyDescription, item: triangleKey)
        )
    }

    @Test func prompt() {
        let move = ParsedAction.move(
            description: openDoorDescription,
            destination: lockedRoomName,
            requiredItem: nil
        )
        let pickUp = ParsedAction.pickUp(
            description: pickUpKeyDescription,
            item: triangleKey
        )

        #expect(move.prompt == openDoorDescription)
        #expect(pickUp.prompt == pickUpKeyDescription)
    }
}
