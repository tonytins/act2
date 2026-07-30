extension Set where Element == String {
    func missingItem(from candidate: String?) -> String? {
        guard let candidate, !contains(candidate) else { return nil }
        return candidate
    }
}
