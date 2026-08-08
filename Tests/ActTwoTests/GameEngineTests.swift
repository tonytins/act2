import Foundation
import Testing

@testable import ActTwo

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
