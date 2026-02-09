//
//  FrameRoundTripTests.swift
//  OutcastID3Tests
//
//  Frame-level round-trip tests for text, URL, picture, and raw frames.
//

import XCTest
@testable import OutcastID3

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

class FrameRoundTripTests: XCTestCase {

    // MARK: - StringFrame

    func testStringFrame_isoLatin1() throws {
        let frame = OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "Hello World")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.StringFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.StringFrame)
        XCTAssertEqual(result.type, .title)
        XCTAssertEqual(result.encoding, .isoLatin1)
        XCTAssertEqual(result.str, "Hello World")
    }

    func testStringFrame_utf16() throws {
        let frame = OutcastID3.Frame.StringFrame(type: .title, encoding: .utf16, str: "Caf\u{00e9} \u{2603}")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.StringFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.StringFrame)
        XCTAssertEqual(result.type, .title)
        XCTAssertEqual(result.encoding, .utf16)
        XCTAssertEqual(result.str, "Caf\u{00e9} \u{2603}")
    }

    func testStringFrame_allTypes() throws {
        let allTypes: [OutcastID3.Frame.StringFrame.StringType] = [
            .albumTitle, .contentType, .copyright, .date, .playlistDelay,
            .encodedBy, .textWriter, .fileType, .time, .contentGroupDescription,
            .title, .description, .initialKey, .audioLanguage, .length,
            .mediaType, .originalTitle, .originalFilename, .originalTextWriter,
            .originalArtistPerformer, .originalReleaseYear, .fileOwner,
            .leadArtist, .band, .composer, .conductor, .interpretedBy,
            .partOfASet, .publisher, .track, .recordingDate,
            .internetRadioStationName, .internetRadioStationOwner,
            .fileSizeInBytes, .internationalStandardRecordingCode,
            .encodingSettings, .year, .category, .keywords,
            .movementName, .movementIndex, .movementCount, .podcastDescription
        ]

        for type in allTypes {
            let frame = OutcastID3.Frame.StringFrame(type: type, encoding: .isoLatin1, str: "test-\(type.rawValue)")
            let data = try frame.frameData(version: .v2_3)
            let parsed = OutcastID3.Frame.StringFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

            let result = try XCTUnwrap(parsed as? OutcastID3.Frame.StringFrame, "Failed for \(type.rawValue)")
            XCTAssertEqual(result.type, type, "Type mismatch for \(type.rawValue)")
            XCTAssertEqual(result.str, "test-\(type.rawValue)", "String mismatch for \(type.rawValue)")
        }
    }

    // MARK: - UrlFrame

    func testUrlFrame() throws {
        let frame = OutcastID3.Frame.UrlFrame(type: .commercialInformation, urlString: "https://example.com/buy")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.UrlFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.UrlFrame)
        XCTAssertEqual(result.type, .commercialInformation)
        XCTAssertEqual(result.urlString, "https://example.com/buy")
    }

    func testUrlFrame_allTypes() throws {
        let allTypes: [OutcastID3.Frame.UrlFrame.UrlType] = [
            .commercialInformation, .copyrightLegalInformation,
            .officialAudioFileWebpage, .officialArtistPerformerWebpage,
            .officialAudioSourceWebpage, .officialInternetRadioStationWebpage,
            .payment, .officialPublisherWebpage
        ]

        for type in allTypes {
            let frame = OutcastID3.Frame.UrlFrame(type: type, urlString: "https://example.com/\(type.rawValue)")
            let data = try frame.frameData(version: .v2_3)
            let parsed = OutcastID3.Frame.UrlFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

            let result = try XCTUnwrap(parsed as? OutcastID3.Frame.UrlFrame, "Failed for \(type.rawValue)")
            XCTAssertEqual(result.type, type, "Type mismatch for \(type.rawValue)")
            XCTAssertEqual(result.urlString, "https://example.com/\(type.rawValue)", "URL mismatch for \(type.rawValue)")
        }
    }

    // MARK: - UserUrlFrame

    func testUserUrlFrame_isoLatin1() throws {
        let frame = OutcastID3.Frame.UserUrlFrame(encoding: .isoLatin1, urlDescription: "My Website", urlString: "https://example.com")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.UserUrlFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.UserUrlFrame)
        XCTAssertEqual(result.encoding, .isoLatin1)
        XCTAssertEqual(result.urlDescription, "My Website")
        XCTAssertEqual(result.urlString, "https://example.com")
    }

    func testUserUrlFrame_utf16() throws {
        let frame = OutcastID3.Frame.UserUrlFrame(encoding: .utf16, urlDescription: "Beschreibung", urlString: "https://example.de")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.UserUrlFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.UserUrlFrame)
        XCTAssertEqual(result.encoding, .utf16)
        XCTAssertEqual(result.urlDescription, "Beschreibung")
        XCTAssertEqual(result.urlString, "https://example.de")
    }

    // MARK: - CommentFrame

    func testCommentFrame() throws {
        let frame = OutcastID3.Frame.CommentFrame(encoding: .isoLatin1, language: "eng", commentDescription: "Desc", comment: "This is a comment")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.CommentFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.CommentFrame)
        XCTAssertEqual(result.encoding, .isoLatin1)
        XCTAssertEqual(result.language, "eng")
        XCTAssertEqual(result.commentDescription, "Desc")
        XCTAssertEqual(result.comment, "This is a comment")
    }

    func testCommentFrame_utf16() throws {
        let frame = OutcastID3.Frame.CommentFrame(encoding: .utf16, language: "deu", commentDescription: "Titel", comment: "Ein Kommentar")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.CommentFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.CommentFrame)
        XCTAssertEqual(result.encoding, .utf16)
        XCTAssertEqual(result.language, "deu")
        XCTAssertEqual(result.commentDescription, "Titel")
        XCTAssertEqual(result.comment, "Ein Kommentar")
    }

    // MARK: - TranscriptionFrame

    func testTranscriptionFrame() throws {
        let frame = OutcastID3.Frame.TranscriptionFrame(encoding: .isoLatin1, language: "eng", lyricsDescription: "Lyrics", lyrics: "Verse 1\nChorus\nVerse 2")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.TranscriptionFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.TranscriptionFrame)
        XCTAssertEqual(result.encoding, .isoLatin1)
        XCTAssertEqual(result.language, "eng")
        XCTAssertEqual(result.lyricsDescription, "Lyrics")
        XCTAssertEqual(result.lyrics, "Verse 1\nChorus\nVerse 2")
    }

    func testTranscriptionFrame_utf16() throws {
        let frame = OutcastID3.Frame.TranscriptionFrame(encoding: .utf16, language: "deu", lyricsDescription: "Liedtext", lyrics: "Strophe eins")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.TranscriptionFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.TranscriptionFrame)
        XCTAssertEqual(result.encoding, .utf16)
        XCTAssertEqual(result.language, "deu")
        XCTAssertEqual(result.lyricsDescription, "Liedtext")
        XCTAssertEqual(result.lyrics, "Strophe eins")
    }

    // MARK: - PictureFrame

    #if canImport(AppKit)
    func testPictureFrame() throws {
        let image = NSImage(size: NSSize(width: 2, height: 2))
        image.lockFocus()
        NSColor.red.drawSwatch(in: NSRect(x: 0, y: 0, width: 2, height: 2))
        image.unlockFocus()

        let frame = OutcastID3.Frame.PictureFrame(
            encoding: .isoLatin1,
            mimeType: "image/png",
            pictureType: .coverFront,
            pictureDescription: "Cover",
            picture: OutcastID3.Frame.PictureFrame.Picture(image: image)
        )
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.PictureFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.PictureFrame)
        XCTAssertEqual(result.encoding, .isoLatin1)
        XCTAssertEqual(result.mimeType, "image/png")
        XCTAssertEqual(result.pictureType, .coverFront)
        XCTAssertEqual(result.pictureDescription, "Cover")
        XCTAssertEqual(result.picture.image.size, NSSize(width: 2, height: 2))
    }
    #elseif canImport(UIKit)
    func testPictureFrame() throws {
        UIGraphicsBeginImageContext(CGSize(width: 2, height: 2))
        defer { UIGraphicsEndImageContext() }
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 2, height: 2))
        let image = try XCTUnwrap(UIGraphicsGetImageFromCurrentImageContext())

        let frame = OutcastID3.Frame.PictureFrame(
            encoding: .isoLatin1,
            mimeType: "image/png",
            pictureType: .coverFront,
            pictureDescription: "Cover",
            picture: OutcastID3.Frame.PictureFrame.Picture(image: image)
        )
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.PictureFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.PictureFrame)
        XCTAssertEqual(result.encoding, .isoLatin1)
        XCTAssertEqual(result.mimeType, "image/png")
        XCTAssertEqual(result.pictureType, .coverFront)
        XCTAssertEqual(result.pictureDescription, "Cover")
        XCTAssertEqual(result.picture.image.size, CGSize(width: 2, height: 2))
    }
    #endif

    // MARK: - RawFrame

    func testRawFrame() throws {
        var fakeData = Data()
        fakeData.append("XXXX".data(using: .isoLatin1)!)
        let contentSize = UInt32(3).bigEndian
        fakeData.append(withUnsafeBytes(of: contentSize) { Data($0) })
        fakeData.append(contentsOf: [0x0, 0x0]) // flags
        fakeData.append(contentsOf: [0xDE, 0xAD, 0xBE]) // content

        let raw = OutcastID3.Frame.RawFrame(version: .v2_3, data: fakeData)
        let roundTripped = try raw.frameData(version: .v2_3)
        XCTAssertEqual(roundTripped, fakeData)
    }

    func testRawFrame_versionMismatch() {
        let raw = OutcastID3.Frame.RawFrame(version: .v2_3, data: Data([0x01]))
        XCTAssertThrowsError(try raw.frameData(version: .v2_4))
    }

    // MARK: - Version edge cases

    func testV22ThrowsOnWrite() {
        let frame = OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "test")
        XCTAssertThrowsError(try frame.frameData(version: .v2_2))
    }

    func testStringFrame_v24_isoLatin1() throws {
        let frame = OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "v2.4 Title")
        let data = try frame.frameData(version: .v2_4)
        let parsed = OutcastID3.Frame.StringFrame.parse(version: .v2_4, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.StringFrame)
        XCTAssertEqual(result.str, "v2.4 Title")
    }

    func testCommentFrame_v24_isoLatin1() throws {
        let frame = OutcastID3.Frame.CommentFrame(encoding: .isoLatin1, language: "eng", commentDescription: "Desc", comment: "v2.4 comment")
        let data = try frame.frameData(version: .v2_4)
        let parsed = OutcastID3.Frame.CommentFrame.parse(version: .v2_4, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.CommentFrame)
        XCTAssertEqual(result.encoding, .isoLatin1)
        XCTAssertEqual(result.language, "eng")
        XCTAssertEqual(result.commentDescription, "Desc")
        XCTAssertEqual(result.comment, "v2.4 comment")
    }

    func testStringFrame_v24_utf8() throws {
        let frame = OutcastID3.Frame.StringFrame(type: .title, encoding: .utf8, str: "Caf\u{00e9} \u{2603}")
        let data = try frame.frameData(version: .v2_4)
        let parsed = OutcastID3.Frame.StringFrame.parse(version: .v2_4, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.StringFrame)
        XCTAssertEqual(result.encoding, .utf8)
        XCTAssertEqual(result.str, "Caf\u{00e9} \u{2603}")
    }

    // MARK: - Empty values

    func testStringFrame_emptyString() throws {
        let frame = OutcastID3.Frame.StringFrame(type: .title, encoding: .isoLatin1, str: "")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.StringFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.StringFrame)
        XCTAssertEqual(result.type, .title)
        XCTAssertEqual(result.str, "")
    }

    func testCommentFrame_emptyDescription() throws {
        let frame = OutcastID3.Frame.CommentFrame(encoding: .isoLatin1, language: "eng", commentDescription: "", comment: "No description")
        let data = try frame.frameData(version: .v2_3)
        let parsed = OutcastID3.Frame.CommentFrame.parse(version: .v2_3, data: data, useSynchSafeFrameSize: false)

        let result = try XCTUnwrap(parsed as? OutcastID3.Frame.CommentFrame)
        XCTAssertEqual(result.commentDescription, "")
        XCTAssertEqual(result.comment, "No description")
    }
}
