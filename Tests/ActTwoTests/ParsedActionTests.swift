import Foundation
import Testing

@testable import ActTwo

@Suite("Parsed actions")
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
