//
//  ChapterFrame.swift
//  Chapters
//
//  Created by Quentin Zervaas on 23/11/18.
//  Copyright © 2018 Crunchy Bagel Pty Ltd. All rights reserved.
//

import Foundation

extension OutcastID3.Frame {
    /// An ID3 chapter frame (CHAP), representing a chapter with time offsets and optional sub-frames.
    public struct ChapterFrame: OutcastID3TagFrame {
        static let frameIdentifier = "CHAP"
        
        static let nullValue: UInt32 = 0xFFFFFFFF
        
        /// A unique identifier for this chapter element.
        public let elementId: String
        /// The start time of the chapter in seconds.
        public let startTime: TimeInterval
        /// The end time of the chapter in seconds.
        public let endTime: TimeInterval
        /// The byte offset where the chapter's audio begins, or `nil` if not specified.
        public let startByteOffset: UInt32?
        /// The byte offset where the chapter's audio ends, or `nil` if not specified.
        public let endByteOffset: UInt32?

        /// Additional frames embedded within this chapter (e.g. title, picture).
        public let subFrames: [OutcastID3TagFrame]
        
        /// Creates a new chapter frame.
        /// - Parameters:
        ///   - elementId: A unique identifier for this chapter element.
        ///   - startTime: The start time of the chapter in seconds.
        ///   - endTime: The end time of the chapter in seconds.
        ///   - startByteOffset: The byte offset where the chapter's audio begins, or `nil`.
        ///   - endByteOffset: The byte offset where the chapter's audio ends, or `nil`.
        ///   - subFrames: Additional frames embedded within this chapter.
        public init(elementId: String, startTime: TimeInterval, endTime: TimeInterval, startByteOffset: UInt32?, endByteOffset: UInt32?, subFrames: [OutcastID3TagFrame]) {
            self.elementId = elementId
            self.startTime = startTime
            self.endTime = endTime
            self.startByteOffset = startByteOffset
            self.endByteOffset = endByteOffset
            self.subFrames = subFrames
        }
    }
}

extension OutcastID3.Frame.ChapterFrame {
    /// Serializes this chapter frame to raw data suitable for writing to an ID3 tag.
    /// - Parameter version: The ID3v2 tag version to encode for.
    /// - Returns: The serialized frame data.
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3, .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.ChapterFrame.frameIdentifier)
        
        try fb.addString(
            str: self.elementId,
            encoding: .isoLatin1,
            includeEncodingByte: false,
            terminator: version.stringTerminator(encoding: .isoLatin1)
        )

        let startTime = UInt32(self.startTime * 1000)
        fb.append(data: startTime.bigEndian.toData)

        let endTime = UInt32(self.endTime * 1000)
        fb.append(data: endTime.bigEndian.toData)
        
        let startOffset = self.startByteOffset ?? OutcastID3.Frame.ChapterFrame.nullValue
        fb.append(data: startOffset.bigEndian.toData)
        
        let endOffset = self.endByteOffset ?? OutcastID3.Frame.ChapterFrame.nullValue
        fb.append(data: endOffset.bigEndian.toData)

        for subFrame in self.subFrames {
            let subFrameData = try subFrame.frameData(version: version)
            fb.append(data: subFrameData)
        }
        
        return try fb.data()
    }
}

extension OutcastID3.Frame.ChapterFrame {
    /// Parses a chapter frame from raw ID3 tag data.
    /// - Parameters:
    ///   - version: The ID3v2 tag version.
    ///   - data: The raw data for this frame, including the frame header.
    ///   - useSynchSafeFrameSize: Whether to interpret the frame size as synch-safe.
    /// - Returns: A parsed chapter frame, or `nil` if the data does not match.
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        let d = data as NSData
        
        var offset = 10
        
        let intSize = 4 // Hard-coded since it's defined by the spec, not by the size of UInt32
        
        let encoding: String.Encoding = .isoLatin1
        let terminator = version.stringTerminator(encoding: encoding)
        
        let elementId = data.readString(offset: &offset, encoding: encoding, terminator: terminator)
        
        guard offset + intSize * 4 <= data.count else {
            return nil
        }
        
        var startTimeMilliseconds: UInt32 = 0
        d.getBytes(&startTimeMilliseconds, range: NSMakeRange(offset, intSize))
        
        offset += intSize
        
        var endTimeMilliseconds: UInt32 = 0
        d.getBytes(&endTimeMilliseconds, range: NSMakeRange(offset, intSize))
        
        offset += intSize
        
        var startByteOffset: UInt32 = 0
        d.getBytes(&startByteOffset, range: NSMakeRange(offset, intSize))
        
        offset += intSize
        
        var endByteOffset: UInt32 = 0
        d.getBytes(&endByteOffset, range: NSMakeRange(offset, intSize))
        
        offset += intSize
        
        let subFrames: [OutcastID3TagFrame]

        if offset < data.count {
            do {
                let subFramesData = data.subdata(in: offset ..< data.count)
                subFrames = try OutcastID3.ID3Tag.framesFromData(version: version, data: subFramesData, useSynchSafeFrameSize: useSynchSafeFrameSize)
            }
            catch {
                subFrames = []
            }
        }
        else {
            subFrames = []
        }
        
        return OutcastID3.Frame.ChapterFrame(
            elementId: elementId ?? "",
            startTime: TimeInterval(startTimeMilliseconds.bigEndian) / 1000,
            endTime: TimeInterval(endTimeMilliseconds.bigEndian) / 1000,
            startByteOffset: startByteOffset.bigEndian == OutcastID3.Frame.ChapterFrame.nullValue ? nil : startByteOffset.bigEndian,
            endByteOffset: endByteOffset.bigEndian == OutcastID3.Frame.ChapterFrame.nullValue ? nil : endByteOffset.bigEndian,
            subFrames: subFrames
        )
    }
}

extension OutcastID3.Frame.ChapterFrame: CustomDebugStringConvertible {
    public var debugDescription: String {

        var parts: [String] = [
            "elementId=\(self.elementId)",
            "startTime=\(self.startTime)",
            "endTime=\(self.endTime)"
        ]

        if let count = self.startByteOffset {
            parts.append("startByteOffset=\(count)")
        }

        if let count = self.endByteOffset {
            parts.append("endByteOffset=\(count)")
        }

        if self.subFrames.count > 0 {
            let str = subFrames.compactMap { $0.debugDescription }
            parts.append("subFrames: \(str)")
        }

        return parts.joined(separator: " ")
    }
}
