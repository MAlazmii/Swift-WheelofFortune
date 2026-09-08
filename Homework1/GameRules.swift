import Foundation

enum GameRules {
    static func isLetter(_ character: Character) -> Bool {
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(character)
    }

    static func normalizedGuess(_ input: String) -> String? {
        let guess = input.uppercased()
        guard input.count == 1, guess.count == 1,
              let letter = guess.first, isLetter(letter) else { return nil }
        return guess
    }

    static func acceptGuess(_ input: String, guessed: inout Set<String>) -> String? {
        guard let guess = normalizedGuess(input), guessed.insert(guess).inserted else { return nil }
        return guess
    }

    static func isComplete(_ phrase: String, guessed: Set<String>) -> Bool {
        let letters = phrase.filter(isLetter)
        return !letters.isEmpty && letters.allSatisfy { guessed.contains(String($0)) }
    }
}

struct PhraseData: Decodable {
    let genre: String
    let list: [String]

    enum LoadError: Error { case emptyData }

    static func decode(_ data: Data) throws -> PhraseData {
        let decoded = try JSONDecoder().decode(PhraseData.self, from: data)
        let phrases = decoded.list.filter { $0.uppercased().contains(where: GameRules.isLetter) }
        guard !decoded.genre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !phrases.isEmpty else { throw LoadError.emptyData }
        return PhraseData(genre: decoded.genre, list: phrases)
    }

    static func load(from folder: URL?) -> PhraseData? {
        guard let folder = folder,
              let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else { return nil }
        for file in files.filter({ $0.pathExtension.lowercased() == "json" }).shuffled() {
            if let data = try? Data(contentsOf: file), let phrases = try? decode(data) {
                return phrases
            }
        }
        return nil
    }
}
