public enum TruthValue: String, Codable, Equatable {
    case isTrue = "true"
    case isFalse = "false"
    case isUnknown = "none"
}

public indirect enum SyntaxExpression {
    case numberLiteral(Double)
    case boolean(TruthValue)
    case variable(String)
    case binary(operator: String, left: SyntaxExpression, right: SyntaxExpression)
    case unaryNegation(SyntaxExpression)
    case call(name: String, arguments: [SyntaxExpression])
}

public struct SwitchCase {
    public let value: SyntaxExpression
    public let body: [Statement]
    
    public init(value: SyntaxExpression, body: [Statement]) {
        self.value = value
        self.body = body
    }
}

public indirect enum Statement {
    case assignment(name: String, value: SyntaxExpression)
    case mutableDeclaration(name: String, value: SyntaxExpression)
    case mutation(name: String, value: SyntaxExpression)
    case print(SyntaxExpression)
    case conditional(condition: SyntaxExpression, thenBranch: [Statement], elseBranch: [Statement])
    case whileLoop(condition: SyntaxExpression, body: [Statement])
    case switchStatement(scrutinee: SyntaxExpression, cases: [SwitchCase], elseBranch: [Statement])
    case function(name: String, parameters: [String], body: [Statement])
    case moduleDeclaration(name: String, functions: [Statement])
    case stateDeclaration(name: String, handlers: [Statement])
    case transition(target: String)
    case returnStatement(SyntaxExpression?)
    case expressionStatement(SyntaxExpression)
}

public enum Opcode: String, Codable {
    case declare = "let"
    case declareMutable = "mut"
    case mutate = "="
    case print
    case conditional = "if"
    case whileLoop = "while"
    case switchStatement = "match"
    case function = "fn"
    case moduleDeclaration = "mod"
    case stateDeclaration = "state" // future LSL-style stach machine
    case transition = "goto"
    case call = "invoke"
    case returnStatement = "return"
    case expressionStatement = "drop"
    
    case numberLiteral = "num"
    case boolean = "bool"
    case variable = "val"
    case negate = "neg"
}

extension SyntaxExpression: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self {
        case let .numberLiteral(value):
            try container.encode(Opcode.numberLiteral)
            try container.encode(value)
        case let .boolean(value):
            try container.encode(Opcode.boolean)
            try container.encode(value)
        case let .variable(name):
            try container.encode(Opcode.variable)
            try container.encode(name)
        case let .binary(op, left, right):
            try container.encode(op)
            try container.encode(left)
            try container.encode(right)
        case let .unaryNegation(operand):
            try container.encode(Opcode.negate)
            try container.encode(operand)
        case let .call(name, arguments):
            try container.encode(Opcode.call)
            try container.encode(name)
            try container.encode(arguments)
        }
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let tag = try container.decode(String.self)
        switch Opcode(rawValue: tag) {
        case .numberLiteral:
            self = try .numberLiteral(container.decode(Double.self))
        case .boolean:
            self = try .boolean(container.decode(TruthValue.self))
        case .variable:
            self = try .variable(container.decode(String.self))
        case .negate:
            self = try .unaryNegation(container.decode(SyntaxExpression.self))
        case .call:
            let name = try container.decode(String.self)
            let arguments = try container.decode([SyntaxExpression].self)
            self = .call(name: name, arguments: arguments)
        default:
            guard Self.binaryOperators.contains(tag) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown expression tag '\(tag)'")
            }
            let left = try container.decode(SyntaxExpression.self)
            let right = try container.decode(SyntaxExpression.self)
            self = .binary(operator: tag, left: left, right: right)
        }
    }
    
    private static let binaryOperators: Set<String> = ["+", "-", "*", "/", "%", "==", "!=", "<", ">", "<=", ">="]
}

extension SwitchCase: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(value)
        try container.encode(body)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decode(SyntaxExpression.self)
        body = try container.decode([Statement].self)
    }
}

extension Statement: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self {
        case let .assignment(name, value):
            try container.encode(Opcode.declare)
            try container.encode(name)
            try container.encode(value)
        case let .mutableDeclaration(name, value):
            try container.encode(Opcode.declareMutable)
            try container.encode(name)
            try container.encode(value)
        case let .mutation(name, value):
            try container.encode(Opcode.mutate)
            try container.encode(name)
            try container.encode(value)
        case let .print(value):
            try container.encode(Opcode.print)
            try container.encode(value)
        case let .conditional(condition, thenBranch, elseBranch):
            try container.encode(Opcode.conditional)
            try container.encode(condition)
            try container.encode(thenBranch)
            try container.encode(elseBranch)
        case let .whileLoop(condition, body):
            try container.encode(Opcode.whileLoop)
            try container.encode(condition)
            try container.encode(body)
        case let .switchStatement(scrutinee, cases, elseBranch):
            try container.encode(Opcode.switchStatement)
            try container.encode(scrutinee)
            try container.encode(cases)
            try container.encode(elseBranch)
        case let .function(name, parameters, body):
            try container.encode(Opcode.function)
            try container.encode(name)
            try container.encode(parameters)
            try container.encode(body)
        case let .moduleDeclaration(name, functions):
            try container.encode(Opcode.moduleDeclaration)
            try container.encode(name)
            try container.encode(functions)
        case let .stateDeclaration(name, handlers):
            try container.encode(Opcode.stateDeclaration)
            try container.encode(name)
            try container.encode(handlers)
        case let .transition(target):
            try container.encode(Opcode.transition)
            try container.encode(target)
        case let .returnStatement(value):
            try container.encode(Opcode.returnStatement)
            if let value {
                try container.encode(value)
            }
        case let .expressionStatement(expression):
            try container.encode(Opcode.expressionStatement)
            try container.encode(expression)
        }
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let tag = try container.decode(String.self)
        switch Opcode(rawValue: tag) {
        case .declare:
            let name = try container.decode(String.self)
            let value = try container.decode(SyntaxExpression.self)
            self = .assignment(name: name, value: value)
        case .declareMutable:
            let name = try container.decode(String.self)
            let value = try container.decode(SyntaxExpression.self)
            self = .mutableDeclaration(name: name, value: value)
        case .mutate:
            let name = try container.decode(String.self)
            let value = try container.decode(SyntaxExpression.self)
            self = .mutation(name: name, value: value)
        case .print:
            self = try .print(container.decode(SyntaxExpression.self))
        case .conditional:
            let condition = try container.decode(SyntaxExpression.self)
            let thenBranch = try container.decode([Statement].self)
            let elseBranch = try container.decode([Statement].self)
            self = .conditional(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
        case .whileLoop:
            let condition = try container.decode(SyntaxExpression.self)
            let body = try container.decode([Statement].self)
            self = .whileLoop(condition: condition, body: body)
        case .switchStatement:
            let scrutinee = try container.decode(SyntaxExpression.self)
            let cases = try container.decode([SwitchCase].self)
            let elseBranch = try container.decode([Statement].self)
            self = .switchStatement(scrutinee: scrutinee, cases: cases, elseBranch: elseBranch)
        case .function:
            let name = try container.decode(String.self)
            let parameters = try container.decode([String].self)
            let body = try container.decode([Statement].self)
            self = .function(name: name, parameters: parameters, body: body)
        case .moduleDeclaration:
            let name = try container.decode(String.self)
            let functions = try container.decode([Statement].self)
            self = .moduleDeclaration(name: name, functions: functions)
        case .stateDeclaration:
            let name = try container.decode(String.self)
            let handlers = try container.decode([Statement].self)
            self = .stateDeclaration(name: name, handlers: handlers)
        case .transition:
            self = try .transition(target: container.decode(String.self))
        case .returnStatement:
            let value = container.isAtEnd ? nil : try container.decode(SyntaxExpression.self)
            self = .returnStatement(value)
        case .expressionStatement:
            self = try .expressionStatement(container.decode(SyntaxExpression.self))
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown statement tag '\(tag)'")
        }
    }
}
