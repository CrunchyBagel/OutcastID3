//
//  TableOfContentsFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 26/11/18.
//

import Foundation

extension OutcastID3.Frame {
    /// An ID3 table of contents frame (CTOC), listing chapter elements and their ordering.
    public struct TableOfContentsFrame: OutcastID3TagFrame {
        static let frameIdentifier = "CTOC"
        
        /// A unique identifier for this table of contents element.
        public let elementId: String
        /// Whether this is the root table of contents entry.
        public let isTopLevel: Bool
        /// Whether the child elements are in a meaningful order.
        public let isOrdered: Bool

        /// The element IDs of child chapters or nested tables of contents.
        public let childElementIds: [String]

        /// Additional frames embedded within this table of contents (e.g. title).
        public let subFrames: [OutcastID3TagFrame]
        
        /// Creates a new table of contents frame.
        /// - Parameters:
        ///   - elementId: A unique identifier for this table of contents element.
        ///   - isTopLevel: Whether this is the root table of contents entry.
        ///   - isOrdered: Whether the child elements are in a meaningful order.
        ///   - childElementIds: The element IDs of child chapters or nested tables of contents.
        ///   - subFrames: Additional frames embedded within this table of contents.
        public init(elementId: String, isTopLevel: Bool, isOrdered: Bool, childElementIds: [String], subFrames: [OutcastID3TagFrame]) {
            self.elementId = elementId
            self.isTopLevel = isTopLevel
            self.isOrdered = isOrdered
            self.childElementIds = childElementIds
            self.subFrames = subFrames
        }
    }
}

extension OutcastID3.Frame.TableOfContentsFrame {
    /// Serializes this table of contents frame to raw data suitable for writing to an ID3 tag.
    /// - Parameter version: The ID3v2 tag version to encode for.
    /// - Returns: The serialized frame data.
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3, .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.TableOfContentsFrame.frameIdentifier)
        
        try fb.addString(
            str: self.elementId,
            encoding: .isoLatin1,
            includeEncodingByte: false,
            terminator: version.stringTerminator(encoding: .isoLatin1)
        )
        
        var flags: UInt8 = 0
        
        if self.isTopLevel {
            flags += 0x2
        }
        
        if self.isOrdered {
            flags += 0x1
        }
        
        fb.append(byte: flags)

        fb.append(byte: UInt8(self.childElementIds.count))
        
        for elementId in self.childElementIds {
            try fb.addString(
                str: elementId,
                encoding: .isoLatin1,
                includeEncodingByte: false,
                terminator: version.stringTerminator(encoding: .isoLatin1)
            )
        }
        
        for subFrame in self.subFrames {
            let subFrameData = try subFrame.frameData(version: version)
            fb.append(data: subFrameData)
        }

        return try fb.data()
    }
}

extension OutcastID3.Frame.TableOfContentsFrame {
    /// Parses a table of contents frame from raw ID3 tag data.
    /// - Parameters:
    ///   - version: The ID3v2 tag version.
    ///   - data: The raw data for this frame, including the frame header.
    ///   - useSynchSafeFrameSize: Whether to interpret the frame size as synch-safe.
    /// - Returns: A parsed table of contents frame, or `nil` if the data does not match.
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        let encoding: String.Encoding = .isoLatin1
        let terminator = version.stringTerminator(encoding: encoding)
        
        var offset = 10
        let elementId = data.readString(offset: &offset, encoding: encoding, terminator: terminator)

        guard offset < data.count else {
            return nil
        }

        let flags = data[offset]

        let isTopLevel = (flags & 0x2) > 0
        let isOrdered  = (flags & 0x1) > 0

        offset += 1

        guard offset < data.count else {
            return nil
        }

        let numEntries = data[offset]
        offset += 1
        
        var childElementIds: [String] = []
        
        for _ in 0 ..< numEntries {
            guard let str = data.readString(offset: &offset, encoding: encoding, terminator: terminator) else {
                continue
            }
            
            childElementIds.append(str)
        }
        
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

        return OutcastID3.Frame.TableOfContentsFrame(
            elementId: elementId ?? "",
            isTopLevel: isTopLevel,
            isOrdered: isOrdered,
            childElementIds: childElementIds,
            subFrames: subFrames
        )
    }
}

extension OutcastID3.Frame.TableOfContentsFrame: CustomDebugStringConvertible {
    public var debugDescription: String {
        var parts: [String] = [
            "elementId=\(self.elementId)",
            "isTopLevel=\(self.isTopLevel)",
            "isOrdered=\(self.isOrdered)",
            "childElementIds=\(self.childElementIds)"
        ]

        if self.subFrames.count > 0 {
            let str = subFrames.compactMap { $0.debugDescription }
            parts.append("subFrames: \(str)")
        }

        return parts.joined(separator: " ")
    }
}
