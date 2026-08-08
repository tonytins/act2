import Foundation
import Testing

@testable import ActTwo

@Suite("World")
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
                Room(name: name,
                     scene: "first",
                     actions: []),
                Room(name: name,
                     scene: "second",
                     actions: []),
            ])
        
        #expect(world.roomByName[name]?.scene == "second")
    }
}
