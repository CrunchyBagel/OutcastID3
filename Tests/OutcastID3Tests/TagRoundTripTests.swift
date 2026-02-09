//
//  TagRoundTripTests.swift
//  OutcastID3Tests
//
//  Full tag round-trip tests: write to temp file, read back, verify.
//

import XCTest
@testable import OutcastID3

class TagRoundTripTests: XCTestCase {

    private var tempUrls: [URL] = []

    override func tearDown() {
        for url in tempUrls {
            try? FileManager.default.removeItem(at: url)
        }
        tempUrls = []
        super.tearDown()
    }

    private func makeTempUrl(_ name: String) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("OutcastID3Test_\(name)_\(UUID().uuidString).mp3")
        tempUrls.append(url)
        return url
    }

    private func createDummySource(audioBytes: Data = Data([0xFF, 0xFB, 0x90, 0x00])) throws -> URL {
        let url = makeTempUrl("source")
        try audioBytes.write(to: url)
        return url
    }

    // MARK: - v2.3

    func testFullRoundTrip_v23() throws {
        let sourceUrl = try createDummySource()
        let outputUrl = makeTempUrl("output_v23")

        let tag = OutcastID3.ID3Tag(version: .v2_3, frames: [
            OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Test Title"),
            OutcastID3.Frame.StringFrame(type: .leadArtist, encoding: .isoLatin1, str: "Test Artist"),
            OutcastID3.Frame.UrlFrame(type: .officialAudioFileWebpage, urlString: "https://example.com/audio"),
        ])

        let mp3 = try OutcastID3.MP3File(localUrl: sourceUrl)
        try mp3.writeID3Tag(tag: tag, outputUrl: outputUrl)

        let mp3Out = try OutcastID3.MP3File(localUrl: outputUrl)
        let props = try mp3Out.readID3Tag()

        XCTAssertEqual(props.tag.version, .v2_3)
        XCTAssertEqual(props.tag.frames.count, 3)

        let titles = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.StringFrame }.filter { $0.type == .title }
        XCTAssertEqual(titles.first?.str, "Test Title")

        let artists = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.StringFrame }.filter { $0.type == .leadArtist }
        XCTAssertEqual(artists.first?.str, "Test Artist")

        let urls = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.UrlFrame }
        XCTAssertEqual(urls.first?.urlString, "https://example.com/audio")
    }

    // MARK: - v2.4

    func testFullRoundTrip_v24() throws {
        let sourceUrl = try createDummySource()
        let outputUrl = makeTempUrl("output_v24")

        let tag = OutcastID3.ID3Tag(version: .v2_4, frames: [
            OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "v2.4 Song"),
            OutcastID3.Frame.CommentFrame(encoding: .isoLatin1, language: "eng", commentDescription: "", comment: "A comment"),
            OutcastID3.Frame.UserUrlFrame(encoding: .isoLatin1, urlDescription: "Blog", urlString: "https://example.com/blog"),
        ])

        let mp3 = try OutcastID3.MP3File(localUrl: sourceUrl)
        try mp3.writeID3Tag(tag: tag, outputUrl: outputUrl)

        let mp3Out = try OutcastID3.MP3File(localUrl: outputUrl)
        let props = try mp3Out.readID3Tag()

        XCTAssertEqual(props.tag.version, .v2_4)
        XCTAssertEqual(props.tag.frames.count, 3)

        let titles = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.StringFrame }.filter { $0.type == .title }
        XCTAssertEqual(titles.first?.str, "v2.4 Song")

        let comments = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.CommentFrame }
        XCTAssertEqual(comments.first?.comment, "A comment")

        let userUrls = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.UserUrlFrame }
        XCTAssertEqual(userUrls.first?.urlString, "https://example.com/blog")
        XCTAssertEqual(userUrls.first?.urlDescription, "Blog")
    }

    // MARK: - Chapters

    func testFullRoundTrip_withChapters() throws {
        let sourceUrl = try createDummySource()
        let outputUrl = makeTempUrl("output_chapters")

        let chapters: [OutcastID3TagFrame] = [
            OutcastID3.Frame.ChapterFrame(
                elementId: "chp0",
                startTime: 0,
                endTime: 60,
                startByteOffset: nil,
                endByteOffset: nil,
                subFrames: [OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Intro")]
            ),
            OutcastID3.Frame.ChapterFrame(
                elementId: "chp1",
                startTime: 60,
                endTime: 180,
                startByteOffset: nil,
                endByteOffset: nil,
                subFrames: [OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Main Topic")]
            ),
            OutcastID3.Frame.ChapterFrame(
                elementId: "chp2",
                startTime: 180,
                endTime: 240,
                startByteOffset: nil,
                endByteOffset: nil,
                subFrames: [OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Outro")]
            ),
        ]

        let toc = OutcastID3.Frame.TableOfContentsFrame(
            elementId: "toc",
            isTopLevel: true,
            isOrdered: true,
            childElementIds: ["chp0", "chp1", "chp2"],
            subFrames: [OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Episodes")]
        )

        let tag = OutcastID3.ID3Tag(version: .v2_3, frames: [toc] + chapters)

        let mp3 = try OutcastID3.MP3File(localUrl: sourceUrl)
        try mp3.writeID3Tag(tag: tag, outputUrl: outputUrl)

        let mp3Out = try OutcastID3.MP3File(localUrl: outputUrl)
        let props = try mp3Out.readID3Tag()

        let tocFrames = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.TableOfContentsFrame }
        XCTAssertEqual(tocFrames.count, 1)
        let readToc = try XCTUnwrap(tocFrames.first)
        XCTAssertEqual(readToc.elementId, "toc")
        XCTAssertTrue(readToc.isTopLevel)
        XCTAssertTrue(readToc.isOrdered)
        XCTAssertEqual(readToc.childElementIds, ["chp0", "chp1", "chp2"])

        let chapterFrames = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.ChapterFrame }
        XCTAssertEqual(chapterFrames.count, 3)

        let sortedChapters = chapterFrames.sorted { $0.startTime < $1.startTime }
        XCTAssertEqual(sortedChapters[0].elementId, "chp0")
        XCTAssertEqual(sortedChapters[0].startTime, 0, accuracy: 0.001)
        XCTAssertEqual(sortedChapters[0].endTime, 60, accuracy: 0.001)

        let chp0Title = sortedChapters[0].subFrames.compactMap { $0 as? OutcastID3.Frame.StringFrame }.first
        XCTAssertEqual(chp0Title?.str, "Intro")

        XCTAssertEqual(sortedChapters[1].elementId, "chp1")
        let chp1Title = sortedChapters[1].subFrames.compactMap { $0 as? OutcastID3.Frame.StringFrame }.first
        XCTAssertEqual(chp1Title?.str, "Main Topic")

        XCTAssertEqual(sortedChapters[2].elementId, "chp2")
        let chp2Title = sortedChapters[2].subFrames.compactMap { $0 as? OutcastID3.Frame.StringFrame }.first
        XCTAssertEqual(chp2Title?.str, "Outro")
    }

    // MARK: - Overwrite

    func testFullRoundTrip_overwriteTag() throws {
        let sourceUrl = try createDummySource()
        let firstOutputUrl = makeTempUrl("output_first")
        let secondOutputUrl = makeTempUrl("output_second")

        let tag1 = OutcastID3.ID3Tag(version: .v2_3, frames: [
            OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Original Title"),
            OutcastID3.Frame.StringFrame(type: .leadArtist, encoding: .isoLatin1, str: "Original Artist"),
        ])

        let mp3 = try OutcastID3.MP3File(localUrl: sourceUrl)
        try mp3.writeID3Tag(tag: tag1, outputUrl: firstOutputUrl)

        let tag2 = OutcastID3.ID3Tag(version: .v2_3, frames: [
            OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "New Title"),
            OutcastID3.Frame.StringFrame(type: .year, encoding: .isoLatin1, str: "2024"),
        ])

        let mp3First = try OutcastID3.MP3File(localUrl: firstOutputUrl)
        try mp3First.writeID3Tag(tag: tag2, outputUrl: secondOutputUrl)

        let mp3Out = try OutcastID3.MP3File(localUrl: secondOutputUrl)
        let props = try mp3Out.readID3Tag()

        let strings = props.tag.frames.compactMap { $0 as? OutcastID3.Frame.StringFrame }

        let titles = strings.filter { $0.type == .title }
        XCTAssertEqual(titles.count, 1)
        XCTAssertEqual(titles.first?.str, "New Title")

        let artists = strings.filter { $0.type == .leadArtist }
        XCTAssertTrue(artists.isEmpty, "Original artist should not be present after overwrite")

        let years = strings.filter { $0.type == .year }
        XCTAssertEqual(years.first?.str, "2024")
    }

    // MARK: - Audio preserved

    func testFullRoundTrip_audioPreserved() throws {
        let audioBytes = Data([0xFF, 0xFB, 0x90, 0x00, 0xDE, 0xAD, 0xBE, 0xEF])
        let sourceUrl = try createDummySource(audioBytes: audioBytes)
        let outputUrl = makeTempUrl("output_audio")

        let tag = OutcastID3.ID3Tag(version: .v2_3, frames: [
            OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Audio Test"),
        ])

        let mp3 = try OutcastID3.MP3File(localUrl: sourceUrl)
        try mp3.writeID3Tag(tag: tag, outputUrl: outputUrl)

        let outputData = try Data(contentsOf: outputUrl)
        let mp3Out = try OutcastID3.MP3File(localUrl: outputUrl)
        let props = try mp3Out.readID3Tag()

        let audioStart = Int(props.endingByteOffset)
        let trailingData = outputData.subdata(in: audioStart ..< outputData.count)
        XCTAssertEqual(trailingData, audioBytes)
    }
}
