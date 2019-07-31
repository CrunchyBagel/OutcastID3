//
//  TableOfContentsFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 26/11/18.
//

import Foundation

extension OutcastID3.Frame {
    public struct TableOfContentsFrame: OutcastID3TagFrame {
        static let frameIdentifier = "CTOC"
        
        public let elementId: String
        public let isTopLevel: Bool
        public let isOrdered: Bool
        
        public let childElementIds: [String]

        public let subFrames: [OutcastID3TagFrame]
        
        public init(elementId: String, isTopLevel: Bool, isOrdered: Bool, childElementIds: [String], subFrames: [OutcastID3TagFrame]) {
            self.elementId = elementId
            self.isTopLevel = isTopLevel
            self.isOrdered = isOrdered
            self.childElementIds = childElementIds
            self.subFrames = subFrames
        }
        
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
}

extension OutcastID3.Frame.TableOfContentsFrame {
    public func frameData(version: OutcastID3.TagVersion) throws -> Data {
        switch version {
        case .v2_2:
            throw OutcastID3.MP3File.WriteError.unsupportedTagVersion
        case .v2_3:
            break
        case .v2_4:
            break
        }
        
        let fb = FrameBuilder(frameIdentifier: OutcastID3.Frame.TableOfContentsFrame.frameIdentifier)
        
        try fb.addString(str: self.elementId, encoding: .isoLatin1, includeEncodingByte: false, terminate: true)
        
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
            try fb.addString(str: elementId, encoding: .isoLatin1, includeEncodingByte: false, terminate: true)
        }
        
        for subFrame in self.subFrames {
            do {
                let subFrameData = try subFrame.frameData(version: version)
                fb.append(data: subFrameData)
            }
            catch {
                print("TOC DATA ERROR: \(error)")
            }
        }

        return try fb.data()
    }
}

extension OutcastID3.Frame.TableOfContentsFrame {
    public static func parse(version: OutcastID3.TagVersion, data: Data, useSynchSafeFrameSize: Bool) -> OutcastID3TagFrame? {
        
        let encoding: String.Encoding = .isoLatin1
        let terminator = version.stringTerminator(encoding: encoding)
        
        var offset = 10
        let elementId = data.readString(offset: &offset, encoding: encoding, terminator: terminator)
        
        let flags = data[offset]
        
        let isTopLevel = (flags & 0x2) > 0
        let isOrdered  = (flags & 0x1) > 0
        
        offset += 1
        
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
