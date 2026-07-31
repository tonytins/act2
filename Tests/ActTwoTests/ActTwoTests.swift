import Foundation
import Testing

@testable import ActTwo

let startRoomName = "start"
let exampleRoomName = "example"
let lockedRoomName = "locked"
let hallRoomName = "hall"
let unknownRoomName = "nowhere"

let triangleKey = "TriangleKey"

let moveToExampleDescription = "Move to another room"
let pickUpKeyDescription = "Pick the key up"
let openDoorDescription = "Try to open the door"
let returnToStartDescription = "Return to start"
let goNorthDescription = "Go north"
let fallIntoVoidDescription = "Fall into the void"

let moveToExampleFields = [moveToExampleDescription, exampleRoomName, ""]
let pickUpKeyFields = [pickUpKeyDescription, triangleKey]
let openDoorFields = [openDoorDescription, lockedRoomName, triangleKey]
let returnToStartFields = [returnToStartDescription, exampleRoomName]
let goNorthFields = [goNorthDescription, hallRoomName, ""]

let missingItemCases: [(inventory: Set<String>, candidate: String?, expected: String?)] = [
   (inventory: [], candidate: nil, expected: nil),
   (inventory: [triangleKey], candidate: triangleKey, expected: nil),
   (inventory: [], candidate: triangleKey, expected: triangleKey),
]

func testWorld() -> GameWorld {
   GameWorld(
      version: .v1,
      rooms: [
         Room(
            name: startRoomName, scene: "Starting room.",
            actions: [
               RoomAction(variant: .move, fields: moveToExampleFields)
            ]),
         Room(
            name: exampleRoomName, scene: "Example room.",
            actions: [
               RoomAction(variant: .pickUp, fields: pickUpKeyFields),
               RoomAction(variant: .move, fields: openDoorFields),
            ]),
         Room(
            name: lockedRoomName, scene: "Final room.",
            actions: [
               RoomAction(variant: .move, fields: returnToStartFields)
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
   ),
]

let incompleteActions: [RoomAction] = [
   RoomAction(variant: .move, fields: [goNorthDescription]),
   RoomAction(variant: .pickUp, fields: [pickUpKeyDescription]),
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
         ParsedAction(from: action) == .pickUp(description: pickUpKeyDescription, item: triangleKey)
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

@Suite("Misisng item lookup")
struct MissingItemTests {
   @Test(arguments: missingItemCases) func misisngItem(
      inventory: Set<String>,
      candiate: String?,
      expected: String?
   ) {
      #expect(inventory.missingItem(from: candiate) == expected)
   }
}

@Suite("World tests")
struct WorldTests {
   @Test func roomByName() {
      #expect(
         testWorld().roomByName.keys
            .sorted() == [exampleRoomName, lockedRoomName, startRoomName]
      )
   }

   @Test(arguments: [hallRoomName])
   func duplicateRoomNames(name: String) {
      let world = GameWorld(
         version: .v1,
         rooms: [
            Room(name: name, scene: "first", actions: []),
            Room(name: name, scene: "second", actions: []),
         ])

      #expect(world.roomByName[name]?.scene == "second")
   }
}

@Suite("Game engine")
struct GameEngineTests {
    @Test func unknownStartRoom() {
        #expect(GameEngine(world: testWorld(), startRoomName: unknownRoomName) == nil)
    }
    
    @Test func knownStartRoom() throws {
        let engine = try #require(
            GameEngine(world: testWorld(), startRoomName: startRoomName)
        )
        #expect(engine.currentRoom.name == startRoomName)
    }
    
    @Test func blockedMove() throws {
        var engine = try #require(
            GameEngine(world: testWorld(), startRoomName: exampleRoomName)
        )
        let openDoor = ParsedAction.move(
            description: openDoorDescription,
            destination: lockedRoomName,
            requiredItem: triangleKey
        )
        
        #expect(engine.attempt(openDoor) == .blocked(missingItem: triangleKey))
        #expect(engine.currentRoom.name == exampleRoomName)
    }
    
    @Test func pickUpThanMove() throws {
        var engine = try #require(
            GameEngine(world: testWorld(), startRoomName: exampleRoomName)
        )
        let takeKey = ParsedAction.pickUp(
            description: pickUpKeyDescription,
            item: triangleKey
        )
        let openDoor = ParsedAction.move(
            description: openDoorDescription,
            destination: lockedRoomName,
            requiredItem: triangleKey
        )
        
        #expect(engine.attempt(takeKey) == .pickedUp(item: triangleKey))
        #expect(engine.hasItem(triangleKey))
        #expect(engine.attempt(openDoor) == .moved(to: lockedRoomName))
        #expect(engine.currentRoom.name == lockedRoomName)
    }
}
