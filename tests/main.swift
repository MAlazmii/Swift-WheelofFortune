import Foundation

precondition(GameRules.normalizedGuess("a") == "A")
for invalid in ["", " ", "'", "7", "AB", "ß", "é"] {
    precondition(GameRules.normalizedGuess(invalid) == nil)
}
precondition(GameRules.isComplete("SCHINDLER'S LIST", guessed: Set("SCHINDLERT".map(String.init))))
precondition(!GameRules.isComplete("SCHINDLER'S LIST", guessed: ["S"]))
var guessed = Set<String>()
precondition(GameRules.acceptGuess("z", guessed: &guessed) == "Z")
precondition(GameRules.acceptGuess("Z", guessed: &guessed) == nil)
guessed.removeAll()
precondition(GameRules.acceptGuess("Z", guessed: &guessed) == "Z")
let valid = Data(#"{"genre":"Movies","list":["Schindler's List"]}"#.utf8)
let decoded = try PhraseData.decode(valid)
precondition(decoded.list == ["Schindler's List"])
for invalid in ["bad json", #"{"genre":"x","list":[]}"#, #"{"genre":"x","list":[" "]}"#, #"{"genre":2,"list":["ABC"]}"#] {
    do { _ = try PhraseData.decode(Data(invalid.utf8)); preconditionFailure("Accepted invalid phrase data") }
    catch { }
}
precondition(PhraseData.load(from: nil) == nil)
let missing = URL(fileURLWithPath: "/nonexistent-wheel-phrases")
precondition(PhraseData.load(from: missing) == nil)
let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: folder) }
precondition(PhraseData.load(from: folder) == nil)
try Data("bad json".utf8).write(to: folder.appendingPathComponent("broken.json"))
precondition(PhraseData.load(from: folder) == nil)
try valid.write(to: folder.appendingPathComponent("valid.json"))
precondition(PhraseData.load(from: folder)?.genre == "Movies")
print("Wheel regression checks passed")
