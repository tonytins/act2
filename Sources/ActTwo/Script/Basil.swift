enum BasilKeywords: String, CaseIterable, Equatable, Sendable {
    // precedes a declaration to make it mutable
    case mutable = "mut"
    
    // declares a binding; immutable unless
    // preceded by mutableModifier
    case val
    
    // Although "print" alone doesn't conflict with the
    // language, it does confuse the syntax highlighters
    case printKeyword = "print"
    case conditionalIf = "if"
    case conditionalThen = "then"
    case elseKeyword = "else"
    case whileLoop = "while"
    case switchKeyword  = "match"
    case switchCase = "case"
    case function = "func"
    case returnKeyword = "return"
    case module = "mod"
    case state
    
    // There is no "begin" in Basil.
    case end
    
    case boolTrue = "true"
    case boolFalse = "false"
    case boolUnknown = "none"
    case remark = "rem"
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct BasilLexer {
    
}
