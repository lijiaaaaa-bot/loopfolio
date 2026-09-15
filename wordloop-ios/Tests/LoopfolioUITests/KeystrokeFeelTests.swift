import Testing
@testable import LoopfolioUI

struct KeystrokeFeelTests {
    @Test func correctPrefixFlashesAndNeverMentionsCinema() {
        var session = FakeTypingSession(target: "lucid", mastery: 0.30)
        #expect(session.ingest("l") == .correctChar)
        #expect(session.flashToken == 1)
        #expect(session.ingest("lu") == .correctChar)
        #expect(session.ingest("luc") == .correctChar)
        #expect(session.ingest("luci") == .correctChar)
        #expect(session.ingest("lucid") == .wordComplete)
        #expect(session.wordsCleared == 1)
        #expect(session.mastery > 0.30)
    }

    @Test func wrongLetterDoesNotAdvanceMastery() {
        var session = FakeTypingSession(target: "lucid", mastery: 0.40)
        _ = session.ingest("l")
        let mastery = session.mastery
        let flashes = session.flashToken
        #expect(session.ingest("lx") == .wrong)
        #expect(session.typed == "l")
        #expect(session.mastery == mastery)
        #expect(session.flashToken == flashes)
    }

    @Test func nextWordKeepsTheMeter() {
        var session = FakeTypingSession(target: "lucid", mastery: 0.50)
        for end in 1...5 {
            _ = session.ingest(String("lucid".prefix(end)))
        }
        session.loadNextWord("aether")
        #expect(session.target == "aether")
        #expect(session.typed.isEmpty)
        #expect(session.mastery >= 0.50)
        #expect(session.wordsCleared == 1)
    }

    @Test func wordBankCycles() {
        #expect(LabWordBank.next(after: "aether") == "ephemeral")
        #expect(LabWordBank.next(after: "unknown") == "ephemeral")
    }
}
