import Foundation

enum Value {
    case number(Double)
    case truth(TruthValue)
}

extension Value: CustomStringConvertible {
    var description: String {
        switch self {
        case let .number(value):
            value
                .truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
        case let .truth(truthValue):
            truthValue.rawValue
        }
    }
}

extension Value: Equatable, Sendable {}

private struct ReturnSignal: Error {
    let value: Value
}

final class Environment {
    private struct Binding {
        var value: Value
        let isMutable: Bool
    }
    
    private var scopes: [[String: Binding]] = [[:]]
    
    private var root: Environment?
    
    init() {
        root = nil
    }
    
    private init(root: Environment) {
        self.root = root
    }
    
    private var effectiveRoot: Environment {
        root ?? self
    }
    
    func pushScope() {
        scopes.append([:])
    }
    
    func popScope() {
        guard scopes.count > 1 else {
            return
        }
        scopes.removeLast()
    }
    
    func value(for name: String) throws -> Value {
        for scope in scopes.reversed() {
            if let binding = scope[name] {
                return binding.value
            }
        }
        
        if root != nil, let value = effectiveRoot.globalValue(for: name) {
            return value
        }
        
        throw InterpreterError.undefinedVariable(name)
    }
    
    func declare(_ value: Value, as name: String, mutable: Bool) throws {
        guard scopes[scopes.count - 1][name] == nil else {
            throw InterpreterError.alreadyDeclared(name)
        }
        
        scopes[scopes.count - 1][name] = Binding(
            value: value,
            isMutable: mutable,
        )
    }
    
    private func globalValue(for name: String) -> Value? {
        scopes[0][name]?.value
    }
    
    private func mutateGlobal(_ value: Value, as name: String) throws -> Bool {
        guard let binding = scopes[scopes.count - 1][name] else {
            return false
        }
        guard binding.isMutable else {
            throw InterpreterError.immutableMutation(name)
        }
        
        scopes[0][name] = Binding(
            value: value,
            isMutable: true,
        )
        
        return true
    }
}

final class FunctionTable {
    struct Declaration {
        let parameters: [String]
        let body: [Statement]
    }
    
    private var functions: [String: Declaration] = [:]
    
    func declare(name: String, param: [String], body: [Statement]) throws {
        guard functions[name] == nil else {
            throw InterpreterError.alreadyDeclared(name)
        }
        
        functions[name] = Declaration(parameters: param, body: body)
    }
}

enum InterpreterError: Error, CustomStringConvertible {
    case undefinedVariable(String)
    case undefinedFunction(String)
    case alreadyDeclared(String)
    case immutableMutation(String)
    case typeMismatch(String)
    case unsupportedOperator(String)
    case divisionByZero
    
    var description: String {
        switch self {
        case .undefinedVariable:
            ""
        case .undefinedFunction:
            ""
        case .alreadyDeclared:
            ""
        case .immutableMutation:
            ""
        case .typeMismatch:
            ""
        case .unsupportedOperator:
            ""
        case .divisionByZero:
            ""
        }
    }
}
