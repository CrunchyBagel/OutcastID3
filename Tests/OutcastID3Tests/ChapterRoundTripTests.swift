//
//  ChapterRoundTripTests.swift
//  OutcastID3Tests
//
//  Round-trip tests for ChapterFrame and TableOfContentsFrame.
//

import XCTest
@testable import OutcastID3

class ChapterRoundTripTests: XCTestCase {

    // MARK: - ChapterFrame

    func testChapterFrame_basic() throws {
        let frame = OutcastID3.Frame.ChapterFrame(
            elementId: "chp0",
            startTime: 0,
            endTime: 60,
            startByteOffset: nil,
            endByteOffset: nil,
            subFrames: []
        )
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.ChapterFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.ChapterFrame)
        XCTAssertEqual(result.elementId, "chp0")
        XCTAssertEqual(result.startTime, 0, accuracy: 0.001)
        XCTAssertEqual(result.endTime, 60, accuracy: 0.001)
        XCTAssertNil(result.startByteOffset)
        XCTAssertNil(result.endByteOffset)
        XCTAssertTrue(result.subFrames.isEmpty)
    }

    func testChapterFrame_withSubFrames() throws {
        let titleFrame = OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Chapter One")
        let frame = OutcastID3.Frame.ChapterFrame(
            elementId: "chp1",
            startTime: 0,
            endTime: 120.5,
            startByteOffset: nil,
            endByteOffset: nil,
            subFrames: [titleFrame]
        )
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.ChapterFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.ChapterFrame)
        XCTAssertEqual(result.elementId, "chp1")
        XCTAssertEqual(result.startTime, 0, accuracy: 0.001)
        XCTAssertEqual(result.endTime, 120.5, accuracy: 0.001)
        XCTAssertNil(result.startByteOffset)
        XCTAssertNil(result.endByteOffset)

        let subString = try XCTUnwrap(result.subFrames.first as? OutcastID3.Frame.StringFrame)
        XCTAssertEqual(subString.type, .title)
        XCTAssertEqual(subString.str, "Chapter One")
    }

    func testChapterFrame_byteOffsets() throws {
        let frame = OutcastID3.Frame.ChapterFrame(
            elementId: "chp2",
            startTime: 10,
            endTime: 20,
            startByteOffset: 1000,
            endByteOffset: 2000,
            subFrames: []
        )
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.ChapterFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.ChapterFrame)
        XCTAssertEqual(result.elementId, "chp2")
        XCTAssertEqual(result.startTime, 10, accuracy: 0.001)
        XCTAssertEqual(result.endTime, 20, accuracy: 0.001)
        XCTAssertEqual(result.startByteOffset, 1000)
        XCTAssertEqual(result.endByteOffset, 2000)
        XCTAssertTrue(result.subFrames.isEmpty)
    }

    // MARK: - TableOfContentsFrame

    func testTableOfContents_basic() throws {
        let frame = OutcastID3.Frame.TableOfContentsFrame(
            elementId: "toc",
            isTopLevel: true,
            isOrdered: true,
            childElementIds: ["chp0", "chp1", "chp2"],
            subFrames: []
        )
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.TableOfContentsFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.TableOfContentsFrame)
        XCTAssertEqual(result.elementId, "toc")
        XCTAssertTrue(result.isTopLevel)
        XCTAssertTrue(result.isOrdered)
        XCTAssertEqual(result.childElementIds, ["chp0", "chp1", "chp2"])
        XCTAssertTrue(result.subFrames.isEmpty)
    }

    func testTableOfContents_withSubFrames() throws {
        let titleFrame = OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Table of Contents")
        let frame = OutcastID3.Frame.TableOfContentsFrame(
            elementId: "toc",
            isTopLevel: true,
            isOrdered: false,
            childElementIds: ["ch1"],
            subFrames: [titleFrame]
        )
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.TableOfContentsFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.TableOfContentsFrame)
        XCTAssertEqual(result.elementId, "toc")
        XCTAssertTrue(result.isTopLevel)
        XCTAssertFalse(result.isOrdered)
        XCTAssertEqual(result.childElementIds, ["ch1"])

        let subString = try XCTUnwrap(result.subFrames.first as? OutcastID3.Frame.StringFrame)
        XCTAssertEqual(subString.type, .title)
        XCTAssertEqual(subString.str, "Table of Contents")
    }

    func testTableOfContents_flagCombinations() throws {
        for (topLevel, ordered) in [(true, true), (true, false), (false, true), (false, false)] {
            let frame = OutcastID3.Frame.TableOfContentsFrame(
                elementId: "toc",
                isTopLevel: topLevel,
                isOrdered: ordered,
                childElementIds: ["ch1"],
                subFrames: []
            )
            let data = try frame.frameData(version: .v2_3)
            let parsed = OutcastID3.Frame.TableOfContentsFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

            let result = try XCTUnwrap(parsed as? OutcastID3.Frame.TableOfContentsFrame, "Failed for topLevel=\(topLevel) ordered=\(ordered)")
            XCTAssertEqual(result.isTopLevel, topLevel, "topLevel mismatch")
            XCTAssertEqual(result.isOrdered, ordered, "ordered mismatch")
        }
    }

    func testTableOfContents_emptyChildIds() throws {
        let frame = OutcastID3.Frame.TableOfContentsFrame(
            elementId: "toc",
            isTopLevel: true,
            isOrdered: false,
            childElementIds: [],
            subFrames: []
        )
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.TableOfContentsFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.TableOfContentsFrame)
        XCTAssertEqual(result.elementId, "toc")
        XCTAssertTrue(result.isTopLevel)
        XCTAssertFalse(result.isOrdered)
        XCTAssertTrue(result.childElementIds.isEmpty)
        XCTAssertTrue(result.subFrames.isEmpty)
    }
}
