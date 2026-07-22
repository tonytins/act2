import Testing
import Foundation
@testable import ActTwo

let json = """
{"version":"v1","rooms":[{"name":"start","scene":"Im a starting room! Welcome to this example game.","actions":[{"variant":"Move","fields":["Move to another room","example",""]}]},{"name":"example","scene":"You enter an example room, with a big, triangular key in it. There's also a door with a keyhole in triangular shape.","actions":[{"variant":"PickUp","fields":["Pick the key up","TriangleKey"]},{"variant":"Move","fields":["Try to open the door","locked","TriangleKey"]}]},{"name":"locked","scene":"You picked an item up and used it to open the door! This is the final room. Congratz!","actions":[{"variant":"Move","fields":["Return to start","example"]}]}]}
"""

func startGame(jsonFile: String, startRoom: String) -> GameEngine? {
    let jsonData = Data(jsonFile.utf8)
    let world = try! JSONDecoder().decode(GameWorld.self, from: jsonData)
    let engine = GameEngine(world: world, startRoomName:startRoom)
    
    return engine
}

@Test func startRoom() async throws {

    let engine = try #require(startGame(jsonFile: json, startRoom: "start"))

    #expect(engine.currentRoom.scene == "Im a starting room! Welcome to this example game.")
}
