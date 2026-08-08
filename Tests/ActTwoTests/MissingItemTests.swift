import Foundation
import Testing

@testable import ActTwo

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

