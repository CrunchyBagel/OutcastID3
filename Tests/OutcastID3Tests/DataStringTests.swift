import XCTest
@testable import OutcastID3

/// Tests for Data.readString(offset:encoding:terminator:)
/// Regression tests for https://github.com/CrunchyBagel/OutcastID3/pull/11
/// which fixes an out-of-bounds crash caused by unconditional `offset += 1`
/// after the read loop, even when the loop exits at the end of the data.
final class DataStringTests: XCTestCase {

    // MARK: - Single terminator tests

    func testSingleTerminator_normalString() {
        // "Hi" followed by 0x00 terminator
        let data = Data([0x48, 0x69, 0x00])
        var offset = 0
        let result = data.readString(offset: &offset, encoding: .isoLatin1, terminator: .single)
        XCTAssertEqual(result, "Hi")
        XCTAssertEqual(offset, 3) // should advance past the null
    }

    func testSingleTerminator_emptyString() {
        // Immediately terminated
        let data = Data([0x00, 0x41])
        var offset = 0
        let result = data.readString(offset: &offset, encoding: .isoLatin1, terminator: .single)
        XCTAssertEqual(result, "")
        XCTAssertEqual(offset, 1)
    }

    /// Exposes the bug: when data has no null terminator, the while loop exits
    /// at offset == count, then `offset += 1` pushes offset past the end.
    func testSingleTerminator_noNullTerminator() {
        // No trailing 0x00 — data just ends
        let data = Data([0x48, 0x69])
        var offset = 0
        let result = data.readString(offset: &offset, encoding: .isoLatin1, terminator: .single)
        XCTAssertEqual(result, "Hi")
        // offset should NOT exceed data.count
        XCTAssertLessThanOrEqual(offset, data.count,
            "offset should not exceed data.count — out-of-bounds bug")
    }

    /// Exposes the bug: calling readString on empty data still does `offset += 1`.
    func testSingleTerminator_emptyData() {
        let data = Data()
        var offset = 0
        let result = data.readString(offset: &offset, encoding: .isoLatin1, terminator: .single)
        XCTAssertEqual(result, "")
        XCTAssertEqual(offset, 0,
            "offset should stay at 0 for empty data — out-of-bounds bug")
    }

    // MARK: - Double terminator tests

    func testDoubleTerminator_normalString() {
        // UTF-16BE "A" (0x00,0x41) terminated by 0x00,0x00
        let data = Data([0x00, 0x41, 0x00, 0x00])
        var offset = 0
        let result = data.readString(offset: &offset, encoding: .utf16BigEndian, terminator: .double)
        XCTAssertEqual(result, "A")
        XCTAssertEqual(offset, 4)
    }

    /// Exposes the bug: double null at start means bytes is empty,
    /// then bytes.removeLast() crashes.
    func testDoubleTerminator_immediateDoubleNull() {
        let data = Data([0x00, 0x00, 0x41])
        var offset = 0
        // This should not crash
        let result = data.readString(offset: &offset, encoding: .utf16BigEndian, terminator: .double)
        XCTAssertNotNil(result)
        XCTAssertEqual(offset, 2)
    }

    /// Exposes the bug: no double-null terminator, loop exits at end,
    /// then `offset += 1` goes out of bounds.
    func testDoubleTerminator_noTerminator() {
        let data = Data([0x00, 0x41, 0x00, 0x42])
        var offset = 0
        let _ = data.readString(offset: &offset, encoding: .utf16BigEndian, terminator: .double)
        XCTAssertLessThanOrEqual(offset, data.count,
            "offset should not exceed data.count — out-of-bounds bug")
    }

    func testDoubleTerminator_emptyData() {
        let data = Data()
        var offset = 0
        let result = data.readString(offset: &offset, encoding: .utf16BigEndian, terminator: .double)
        XCTAssertEqual(result, "")
        XCTAssertEqual(offset, 0,
            "offset should stay at 0 for empty data — out-of-bounds bug")
    }

    // MARK: - Offset preserved correctly for sequential reads

    func testSequentialReads() {
        // Two null-terminated latin strings back to back: "AB\0CD\0"
        let data = Data([0x41, 0x42, 0x00, 0x43, 0x44, 0x00])
        var offset = 0
        let first = data.readString(offset: &offset, encoding: .isoLatin1, terminator: .single)
        let second = data.readString(offset: &offset, encoding: .isoLatin1, terminator: .single)
        XCTAssertEqual(first, "AB")
        XCTAssertEqual(second, "CD")
        XCTAssertEqual(offset, 6)
    }
}
